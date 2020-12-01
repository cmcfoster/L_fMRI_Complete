%% load paths

load_paths_and_open_log;

%% get cores

n_cores = feature('numcores');
delete(gcp('nocreate'));
parpool(n_cores);

%% Import raw data -----

    subj_dir_list = dir([strrep(base_path,'/KK_KR_JLBS','') 'incoming/nii/3tb*']);    % raw data folder where both waves subjects stored; converted using EEP script 3.26.2020
    parfor i = 1:size(subj_dir_list, 1)                                            % loop through each subject
        subj = subj_dir_list(i).name;
        longf = [base_path, '/', 'Longitudinal_Data/', wave_dir, '/MRI/FMRI/data'];         % new longitudinal data folder
        try
            import_raw_data_from_incoming(base_path, longf, subj, log_path);
        catch ME
            log_subj_process(subj, 'import raw data', 1, ME.message, log_path, false);
        end
    end