%% Load Paths

load_paths_and_open_log;

%% grab newly transferred subjects for subj_list

subj_dir_list = get_file_path(correct_path([base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/data/3tb*']));
subj_dir_list = subj_dir_list(~contains(subj_dir_list, '.mat'));

%% get number of cores

n_cores = feature('numcores');
delete(gcp('nocreate'));
parpool(n_cores);


%% Create subject specific half-way space -----

parfor i = 1:size(id_list,1)
    
    log_subj_process(id_list{i, 1}, 'ants halfway', 0, 'processing', log_path, false); % log process
    
    temp_out_dir = [base_path 'Longitudinal_Data/' wave_dir '/MRI/FMRI/SSTemplate']; % sstemplate folder
    temp_out_path = [temp_out_dir '/' id_list{i, 1} '_' id_list{i, 2}];       % add subject id to create subject specific folder
    
    
    temp_w1_t1_path_tmp = get_file_path([base_path 'Longitudinal_Data/' wave_dir '/MRI/FMRI/data/' id_list{i, 2} '*']); % path to W1 BET T1
    temp_w1_t1_path = get_file_path([temp_w1_t1_path_tmp{1} '/3tb*_BET*.nii']); % path to W1 BET T1
    
    if isempty(temp_w1_t1_path{1})
        log_subj_process(id_list{i, 2}, 'ants halfway', 1, 'There is no T1 for this W1 subject', log_path, false); % record error if no W1 T1
    end
    
    temp_w2_t1_path_tmp = get_file_path([base_path 'Longitudinal_Data/' wave_dir '/MRI/FMRI/data/' id_list{i, 1} '*']); % path to W2 BET T1
    temp_w2_t1_path = get_file_path([temp_w2_t1_path_tmp{1} '/3tb*_BET*.nii']); % path to W2 BET T1
    
    if isempty(temp_w2_t1_path{1})
        log_subj_process(id_list{i, 1}, 'ants halfway', 1, 'There is no T1 for this W2 subject', log_path, false); % record error if no W2 T1
    end
    
    if exist(temp_w1_t1_path{1}, 'file') && exist(temp_w2_t1_path{1}, 'file')  % make a subject specific folder to store SS-template
        if ~exist(temp_out_path, 'dir')
            mkdir(temp_out_path)
        end
        % create subject-specific half-way T1 using ants; runs in bash
            ants_cmd = sprintf('module load sge; module load ants/2.1.0; antsMultivariateTemplateConstruction.sh -r 1 -d 3 -c 0 -o %s %s %s', [temp_out_path '/' id_list{i,1} '_' id_list{i,2}], temp_w1_t1_path{1}, temp_w2_t1_path{1});
            unix(ants_cmd)
    else
            log_subj_process(id_list{i, 1}, 'ants halfway', 0, 'no SStemp created', log_path, false);
    end
end


%% Create group template -----

log_subj_process('group', 'ants group template', 0, 'processing', log_path, false);

gtemp_dir = [base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/GroupTemplate/'];  % the group template output directory
sstemp_path = [base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/SSTemplate'];   % the subject specific directory

sstemp_path_list = get_file_path([sstemp_path '/3tb*_3tb*/3tb*_3tb*template0.nii.gz']);             % grab all subject specific templates
%sstemp_path_list = sstemp_path_list(~contains(sstemp_path_list, {'Group', 'group'})); % do not include any pre-existing group templates

%save list of subject specific templates included in group template
tmp_path = [base_path 'Longitudinal_Data/' wave_dir '/MRI/FMRI/'];
tmp_file = [tmp_path 'gtemp_ids.txt'];
gtemp_id = fopen(tmp_file, 'w+');
fprintf(gtemp_id, '%s \n', sstemp_path_list{:});
fclose(gtemp_id);

%make group template folder if it doesn't exist
if ~exist(gtemp_dir,'dir')
    mkdir(gtemp_dir)
end

%create group template using subject-specific half-way T1s; runs in bash
try
    ants_cmd = sprintf('module load sge; module load ants/2.1.0; antsMultivariateTemplateConstruction.sh -d 3 -c 1 -o %s %s', gtemp_dir, tmp_file);
    unix(ants_cmd); 
    log_subj_process('group', 'ants group template', 0, 'complete', log_path, false);
catch ME
    log_subj_process('group', 'ants group template', 1, ME.message, log_path, false);
end




%% Segment group template -----

gtemp_dir = [base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/GroupTemplate/'];  % the group template output directory

gtemp_path = get_file_path([gtemp_dir 'template0.nii.gz']);
gunzip(gtemp_path);
gtemp_path = get_file_path([gtemp_dir 'template0.nii']);

try
    log_subj_process('group', 'segment group template', 0, 'processing', log_path, false);
    segment_brain(gtemp_path{1}, spm_path);
    log_subj_process('group', 'segment group template', 0, 'complete', log_path, false);
catch ME
    log_subj_process('group', 'segment group template', 1, ME.message, log_path, false);
end


%% Resample group template and its segments -----

% resample group template to 3x3x3mm; 
% runs in bash

% resample group template
gtemp_dir = [base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/GroupTemplate/'];  % the group template output directory

in_file = get_file_path([gtemp_dir 'template0.nii.gz']);
out_file = strrep(in_file, '.nii.gz', '_3mm.nii.gz');
try
    log_subj_process('group', 'resample group template', 0, 'processing', log_path, false);
    ants_cmd = sprintf('module load sge; module load ants/2.1.0; ResampleImage 3 %s %s 3x3x3', in_file{1}, out_file{1});
    unix(ants_cmd); 
    log_subj_process('group', 'resample group template', 0, 'complete', log_path, false);
catch ME
    log_subj_process('group', 'resample group template', 1, ME.message, log_path, false);
end 



% resample group template segments
gtemp_seg_list = get_file_path(correct_path([gtemp_dir '/c*.nii']));
for i = 1:size(gtemp_seg_list, 1)
    in_file = gtemp_seg_list{i};
    out_file = strrep(in_file, '.nii', '_3mm.nii.gz');
    try
        log_subj_process('group', 'resample group template segments', 0, 'processing', log_path, false);
        ants_cmd = sprintf('module load sge; module load ants/2.1.0; ResampleImage 3 %s %s 3x3x3', in_file, out_file);
        unix(ants_cmd);
        log_subj_process('group', 'resample group template segments', 0, 'complete', log_path, false);
    catch ME
        log_subj_process('group', 'resample group template segments', 1, ME.message, log_path, false);
    end
end

gtemp_seg_list_gz = get_file_path(correct_path([gtemp_dir '/c*_3mm.nii.gz']));
%gtemp_seg_list_gz = [gtemp_seg_list_gz;get_file_path(correct_path([gtemp_dir '/template0*_3mm.nii.gz']))];

%gunzip .nii.gz files
for i = 1:size(gtemp_seg_list_gz, 1)
   gunzip(gtemp_seg_list_gz{i})
end

%% create whole brain mask from group template
gtemp = correct_path([gtemp_dir '/template0_3mm.nii.gz']);
gtemp_wb_mask_gz = correct_path([gtemp_dir '/GroupTemplate_WB_mask.nii.gz']);
fsl_cmd = sprintf('module load fsl/5.0.8; fslmaths %s -thr 1 -bin %s', gtemp, gtemp_wb_mask_gz);
system(fsl_cmd);

gunzip(gtemp_wb_mask_gz);
