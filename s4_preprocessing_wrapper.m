%% Load Paths

load_paths_and_open_log;

%% grab newly transferred subjects for subj_list

subj_dir_list = get_file_path(correct_path([base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/data/3tb*']));
subj_dir_list = subj_dir_list(~contains(subj_dir_list, '.mat'));

%% Set number of cores to use (always sets to max) -----

n_cores = feature('numcores');
delete(gcp('nocreate'));
parpool(n_cores);

%% Preprocessing

spm_jobman('initcfg'); % initialize SPM

temp_out_dir = correct_path([base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/SSTemplate']); % sstemplate directory
gtemp_dir = correct_path([base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/GroupTemplate']); % the group template output directory
gtemp_seg_list = correct_path(get_file_path(correct_path([gtemp_dir '/c*_3mm.nii']))); % all segments
gtemp_seg_list = correct_path(gtemp_seg_list(contains(gtemp_seg_list(),{'c1','c2','c3V'})));                     % only gm, wm, and csf
gtemp_wb_mask = correct_path([gtemp_dir '/GroupTemplate_WB_mask.nii']); % wb mask
gtemp_seg_list(end+1) = {gtemp_wb_mask};                                % add wb to seg_list

radius = 50; % estimated head size for people 50 mm https://github.com/rordenlab/spmScripts/blob/master/nii_qa_moco.m
GS_perc_num = .75; % GS_perc_num (Global Signal change in percent) maybe .75 as a cutoff
Motion_from_origin = 2; % Motion_from_origin (Motion on any axis in mm from starting volume for that run) maybe 2mm as cutoff
FD_num = 1; % FD_num (Framewise Displacement) Powers et al uses .5 but maybe 1 for task. Powers et al., 2012 uses .9mm???
GS_std_num = 3; % GS_std_num (Global signal standard deviation from mean by frame) maybe 3 as a cutoff

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Specify which preprocessing steps you want to run %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% possibilities are {'realign','coregister','func2grp','smooth','3d_2_4d','nuisance_regressors'}

flag = {'realign','coregister','reslice','func2grp','smooth','3d_2_4d','nuisance_regressors'};
flag = {'nuisance_regressors'};%4/24/20
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% set overwrite flag, note this can be done individually for each function,
% but you can also set it here. Set to 'TRUE' or 'FALSE' (i.e., True - overwrite
% existing files, False - don't overwrite existing files)
% Note; Realign and Coregister don't have this call since the filename is
% unchanged after this process. Just don't use those flags if you want to
% skip those steps.
overwrite = 'TRUE';
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

parfor i = 1:size(subj_dir_list,1)
    
    subj = get_subj_mri_id(subj_dir_list{i});                               % subj id (i.e., mri id)
    subj_w_id = subj_dir_list{i}(end-11:end);                              % subj id with cog id
    
    % create the necessary variables for the subject
    try
        log_subj_process(subj, 'get BET', 0, 'processing', log_path, false);
        anat = {};
        anat = char(correct_path(get_file_path([subj_dir_list{i} '/' subj '_BET*_MPRAGE.nii'])));         % get brain extracted MPRAGE
        log_subj_process(subj, 'get BET', 0, 'complete', log_path, false);
    catch ME
        log_subj_process(subj, 'get BET', 1, ME.message, log_path, false);
    end
    
    [v_run_files] = get_functional_volumes(subj_dir_list{i}, 'vol');          % find paths to functional volumes for both tasks
    numfiles = 0;
    
    %Count files and create text file indicating if too much missing data
    %is present
    for m = 1:size(v_run_files, 2)
        numfiles = numfiles + size(v_run_files{1, m}, 1);
        if contains(v_run_files{1,m}{1,:},'DJ') && size(v_run_files{1, m}, 1) <= 178
            writematrix(0,[extractBefore(v_run_files{1,m}{1,:},'vol') 'too_much_missing_data.csv']);
        elseif contains(v_run_files{1,m}{1,:},'Nback') && size(v_run_files{1, m}, 1) <= 221
            writematrix(0,[extractBefore(v_run_files{1,m}{1,:},'vol') 'too_much_missing_data.csv']);
        end
    end
    
    if numfiles > 1 && ~isempty(anat)
        try
            % Realiign functional images -----
            % note, this is no longer a realign and write batch, just a realign batch.
            % Realignment of the functional images does not require writing out
            % additional images, the images that go in are realigned without any change
            % to the filename. Thus you will end up with realigned images that are
            % still vol_0*.
            if any(strcmp('realign',flag))
                log_subj_process(subj, 'realign: estimate', 0, sprintf('%d files being realigned', numfiles), log_path, false);
                realign_functionals(v_run_files);                                      % realign all func vols across both tasks to first vol within each run and then to first vol collected
                log_subj_process(subj, 'realign: estimate', 0, 'complete', log_path, false);
            else
                fprintf('Skipping realignment. Use flag "realign" to run this step.\n');
            end
            
            %% Coregister functional vols to wave-specific T1 -----
            if any(strcmp('coregister',flag))
                log_subj_process(subj, 'coregister func to t1', 0, 'processing', log_path, false);
                coregister_func_to_t1(anat, vertcat(v_run_files{:}));
                log_subj_process(subj, 'coregister func to t1', 0, 'complete', log_path, false);
            else
                fprintf('Skipping coregistration. Use flag "coregister" to run this step.\n');
            end
            
            %% reslice functional vols to implement realign and coregister -----
            if any(strcmp('reslice',flag))
                log_subj_process(subj, 'reslice funcs', 0, 'processing', log_path, false);
                reslice_func(vertcat(v_run_files{:}),gtemp_dir,overwrite);
                log_subj_process(subj, 'reslice funcs', 0, 'complete', log_path, false);
            else
                fprintf('Skipping reslice. Use flag "coregister" to run this step.\n');
            end
            
            %% Move functional vols to group template -----
            if any(strcmp('func2grp',flag))
                log_subj_process(subj, 'move func to group template', 0, 'processing', log_path, false);
                warp_func_to_group_template(subj_dir_list{i}, id_list, temp_out_dir, gtemp_dir, overwrite);
                log_subj_process(subj, 'move func to group template', 0, 'complete', log_path, false);
            else
                fprintf('Skipping process of moving funcs to group template. Use flag "fun2grp" to run this step.\n');
            end
            
            %% Smooth all functional vols -----
            if any(strcmp('smooth',flag))
                [gw_run_files] = get_functional_volumes(subj_dir_list{i}, 'gwrvol');    % find paths to warped functional volumes for both tasks
                
                log_subj_process(subj, 'smooth func', 0, 'processing', log_path, false);
                fsl_smooth_images(vertcat(gw_run_files{:}), 8, overwrite); %note that for FSL smooth, 8 will be converted to FWHM in the function. See notes in function.
                log_subj_process(subj, 'smooth func', 0, 'complete', log_path, false);
            else
                fprintf('Skipping smoothing. Use flag "smooth" to run this step.\n');
            end
            
            %% Create 4D files -----
            % 3d to 4d files
            if any(strcmp('3d_2_4d',flag))
                task_list = get_task_dir(subj_dir_list{i});
                [gw_run_files] = get_functional_volumes(subj_dir_list{i}, 'gwrvol');    % find paths to warped functional volumes for both tasks
                for j = 1:size(task_list, 1)
                    
                    
                    % obtain all warped volumes within task
                    task = erase(extractAfter(task_list{j},subj_w_id),["/","\"]);
                    out_4d = correct_path([subj_dir_list{i} '\func_4D\' task '_gwrvol_4D.nii']);
                    
                    if ~exist([subj_dir_list{i} '/func_4D'], 'dir')
                        mkdir([subj_dir_list{i} '/func_4D']);
                    end
                    
                    log_subj_process(subj, 'make func 4D', 0, 'processing', log_path, false);
                    fsl_concat_3d_to_4d(gw_run_files{j}, out_4d, overwrite);
                    log_subj_process(subj, 'make func 4D', 0, 'complete', log_path, false);
                end
            else
                fprintf('Skipping process of converting 3d to 4d files. Use flag "3d_2_4d" to run this step.\n');
            end
            
            %% nuisance regressor creation
            if any(strcmp('nuisance_regressors',flag))
                task_list = get_task_dir(subj_dir_list{i});
                
                [gw_run_files] = get_functional_volumes(subj_dir_list{i}, 'gwrvol');    % find paths to warped functional volumes for both tasks
                
                for j = 1:size(task_list, 1)
                    
                    % extract wm, csf, and whole brain (wb) time series
                    %log_subj_process(subj, 'ts for gwrvol_wm_csf and gwrvol_gm_wb', 0, 'processing', log_path, false);
                    %get_brain_segment_time_series(gtemp_seg_list(2:3), subj_dir_list{i}, task_list(j), 'gwrvol', 'gwrvol_wm_csf',overwrite);
                    %get_brain_segment_time_series(gtemp_seg_list([1,4]), subj_dir_list{i}, task_list(j), 'gwrvol', 'gwrvol_gm_wb',overwrite);
                    %log_subj_process(subj, 'ts for gwrvol_wm_csf', 0, 'complete', log_path, false);
                    
                    % get 6 parameter motion file
                    motion_file = correct_path(strcat(task_list(j), '/rp_vol_0000.txt'));
                    
                    % calculate framewise displacement
                    %log_subj_process(subj, 'frawewise displacement', 0, 'processing', log_path, false);
                    %calculate_framewise_displacement(motion_file{:}, correct_path([task_list{j} '/fd.csv']),radius,overwrite);
                    %log_subj_process(subj, 'frawewise displacement', 0, 'complete', log_path, false);
                    
                    % get nuisance segment ts and motion ts paths
                    seg_ts_path = correct_path(strcat(task_list(j), {'/gwrvol_*_ts.csv'}));
                    seg_ts = get_file_path(seg_ts_path{:});
                    nuisance_files = [motion_file; seg_ts];
                    
                    % temporal derivatives and its squared
                    for k = 1:size(nuisance_files, 1)
                        in_file_m = nuisance_files{k};
                        [file_path, file_name] = fileparts(nuisance_files{k});
                        out_file_m = strcat(file_path, '/', file_name, '_td1_poly2.csv');
                        log_subj_process(subj, ['derivatives: ' in_file_m], 0, 'processing', log_path, false);
                        create_parameter_derivatives_polynomial(in_file_m, 1, 2, out_file_m, overwrite);
                        log_subj_process(subj, ['derivatives: ' in_file_m], 0, 'complete', log_path, false);
                    end
                    
                    % combine and create regressors (if necessary)
                    if exist(correct_path([task_list{j} '/nuisance_regressors.txt']),'file') && any(contains(overwrite,'f','IgnoreCase',true))
                        fprintf('skipping nuisance regressor creation for %s, file already exists',task_list{j})
                    else
                        m_paths = [get_file_path([task_list{j} '/*.csv']);get_file_path([task_list{j} '/*.txt'])];
                        
                        log_subj_process(subj, 'Dummy Motion', 0, 'processing', log_path, false);
                        % if needed, create a list of dummy variables for volumes
                        % associated with excessive motion or signal change
                        number = [];
                        dummy_list = [];
                        [number,dummy_list] = create_dummy_motion_regressors(m_paths,GS_perc_num,Motion_from_origin,FD_num,GS_std_num,radius);
                        log_subj_process(subj, 'Dummy Motion', 0, 'complete', log_path, false);
                        
                        log_subj_process(subj, 'Create Nuisance Matrix', 0, 'processing', log_path, false);
                        % combine all nuisance regressors.
                        nuisance_matrix = [];
                        [nuisance_matrix] = create_nuisance_regressors(m_paths,dummy_list);
                        
                        % save to file in subjects task run folder
                        writematrix(nuisance_matrix,correct_path([task_list{j} '/nuisance_regressors.txt']));
                        
                        % check for the existance of too_much_motion.csv file anddelete
                        if exist([task_list{j} '/too_much_motion.csv'],'file')
                            delete([task_list{j} '/too_much_motion.csv'])
                        end
                        % if too much motion, create text file that can be checked later, to not include that run
                        proportion = number/size(nuisance_matrix,1);
                        
                        % set proportion accordingly.
                        if proportion > .15
                            tmp = 0;
                            writematrix(tmp,[task_list{j} '/too_much_motion.csv']);
                        end
                        log_subj_process(subj, 'Create Nuisance Matrix', 0, 'complete', log_path, false);
                    end
                end
            else
                fprintf('Skipping creation of nuisance regressors. Use flag "nuisance_regressors" to run this step.\n');
            end
            
        catch ME
            log_subj_process(subj, 'preprocessing error', 1, ME.message, log_path, false);
        end
    end
end