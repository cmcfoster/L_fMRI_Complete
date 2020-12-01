% to do:
% 1. edit actual file names to warps (directories should be correct, but should check)

function [] = warp_func_to_group_template(subj_dir, id_list, sstemp_dir, gtemp_dir, overwrite)
%warp_func_to_group_template warp functional volumes to group template
%   input:
%       subj_dir        subject's directory
%       id_list         3tb subject list for both waves
%       sstemp_dir      directory to subject-specific template
%       gtemp_dir       directory to group template
%   output:
%       warped functional files (gwvol_*.nii) as the same input functional
%       volumes (vol_*.nii)

% set subj
subj = strsplit(subj_dir, {'/','\'});
subj = subj{end}(1:7);

% get row index of id_list
% this is to obtain their subject-specific template directory
[id_idx,~,~] = find(contains(id_list, subj));

% get func list
%we should move func vols and group template to main wrapper so that all
%hrd coded info lives there
all_func_vols = get_file_path([subj_dir '/*/rvol*.nii']);

% set group template, delete .nii if needed. Will interfere with warps
group_template = correct_path([gtemp_dir '/template0_3mm.nii.gz']);
%if exist(strrep(group_template,'.nii.gz','.nii'),'file')
%    delete(strrep(group_template,'.nii.gz','.nii'))
%end

% mean func to wave specific anat warp
%does this want both waves? and is it an m file? Or should it be text?
%func_to_wave_specific_anat_linear = [subj_dir '/Affine.m']; % I, cmf,
%really do not think that we need this, not 100% sure though. Don't think
%we need it because funcs are coregistered to t1

if ~isempty(id_idx)
    
    % combine 3tb ids
    subj_ids = strcat(id_list{id_idx, 1}, '_', id_list{id_idx, 2});
    
    % obtain subject's actual subject-specific template directory
    sstemp_subj_dir = [sstemp_dir '/' subj_ids];
    
    % obtain wave specific anat to ss temp anat warps
    %Might need to update file names
    wave_specific_anat_to_ss_temp_linear = get_file_path([sstemp_subj_dir '/' subj_ids subj '*BET*Affine.txt']);
    wave_specific_anat_to_ss_temp_nonlinear = get_file_path([sstemp_subj_dir '/' subj_ids subj '*0Warp.nii.gz']);
    if  isempty(wave_specific_anat_to_ss_temp_nonlinear{1,1})
        wave_specific_anat_to_ss_temp_nonlinear = get_file_path([sstemp_subj_dir '/' subj_ids subj '*1Warp.nii.gz']);
    end
    
    % obtain ss temp anat to group temp warps
    %Might need to update file names
    ss_template_to_group_template_linear = get_file_path([gtemp_dir '/*' subj_ids '*Affine.txt']);
    ss_template_to_group_template_nonlinear = get_file_path([gtemp_dir '/*' subj_ids 'template*Warp.nii.gz']);
    try
    ss_template_to_group_template_nonlinear = ss_template_to_group_template_nonlinear(2,:); % this may not be the best way to do this, what if there are more than 2 (says christina)
    catch
        warning('no group template warp for %s \n',subj);
    end
    % for loop through each functional volume
    for i = 1:size(all_func_vols, 1)
        
        % set input and output functional volumes
        in_func = all_func_vols{i};
        out_func = strrep(in_func, 'rvol_', 'gwrvol_');
        
        if exist(out_func,'file') && any(contains(overwrite,'f','IgnoreCase',true))
            fprintf('skipping %s, already exists',out_func);
        elseif  exist(in_func,'file')
            % write ants command and perform warp
            if i == 1
                ants_cmd = ['module load sge; module load ants/2.1.0; antsApplyTransforms -d 3 -i ' in_func ' -r ' group_template ' -o ' out_func ' -n Linear -t ' char(ss_template_to_group_template_nonlinear) ' ' char(ss_template_to_group_template_linear) ' ' char(wave_specific_anat_to_ss_temp_nonlinear) ' ' char(wave_specific_anat_to_ss_temp_linear)];
                %ants_cmd = ['module load sge; module load ants/2.1.0; antsApplyTransforms -d 3 -i ' in_func ' -r ' group_template ' -o ' out_func ' -n Linear -t ' char(wave_specific_anat_to_ss_temp_nonlinear) ' [' char(wave_specific_anat_to_ss_temp_linear) ',1] -v'];
            else
                ants_cmd = ['module load sge; module load ants/2.1.0; antsApplyTransforms -d 3 -i ' in_func ' -r ' group_template ' -o ' out_func ' -n Linear -t ' char(ss_template_to_group_template_nonlinear) ' ' char(ss_template_to_group_template_linear) ' ' char(wave_specific_anat_to_ss_temp_nonlinear) ' ' char(wave_specific_anat_to_ss_temp_linear)];
            end
            system(ants_cmd);
            %fprintf('%s \n',ants_cmd);
            %fprintf('%s \n',subj_dir);
        end
    end
else
    % warp wave specific anat to group template
    % if only Wave1 data exists create new warps
    in_anat = {};
    in_anat = get_file_path([subj_dir '/' subj '_BET*']);
    out_anat =strrep(in_anat, 'BET', 'gw_BET');
    
    if size(in_anat, 1) >= 1 && ~exist([char(out_anat) 'Warped.nii.gz'],'file')
        ants_cmd = ['module load sge; module load ants/2.1.0; antsRegistrationSyN.sh -d 3 -o ' char(out_anat) ' -m ' char(in_anat) ' -f ' char(group_template) ' -t s'];
        system(ants_cmd);
        fprintf('%s \n',ants_cmd);
    end
    if size(in_anat,1) >= 1 && exist([char(out_anat) 'Warped.nii.gz'],'file')
        
        
        % obtain wave specific anat to group temp warps
        %Might need to update file names
        wave_specific_anat_to_group_template_linear =char(strrep(out_anat, 'MPRAGE.nii', 'MPRAGE.nii0GenericAffine.mat'));
        wave_specific_anat_to_group_template_nonlinear = char(strrep(out_anat, 'MPRAGE.nii', 'MPRAGE.nii1Warp.nii.gz'));
        
        % for loop through each functional volume
        for i = 1:size(all_func_vols, 1)
            
            % set input and output functional volumes
            in_func = all_func_vols{i};
            out_func = strrep(in_func, '/rvol_', '/gwrvol_');
            
            if exist(out_func,'file') && any(contains(overwrite,'f','IgnoreCase',true))
                fprintf('skipping %s, already exists',out_func);            
            elseif exist(in_func,'file')
                % write ants command and perform warp
                if i == 1
                    ants_cmd = ['antsApplyTransforms -d 3 -i ' in_func ' -r ' group_template ' -o ' out_func ' -n Linear -t ' wave_specific_anat_to_group_template_nonlinear ' ' wave_specific_anat_to_group_template_linear];
                else
                    ants_cmd = ['antsApplyTransforms -d 3 -i ' in_func ' -r ' group_template ' -o ' out_func ' -n Linear -t ' wave_specific_anat_to_group_template_nonlinear ' ' wave_specific_anat_to_group_template_linear];
                end
                system(ants_cmd);
                %fprintf('%s \n',ants_cmd);
            end
        end
    end
end