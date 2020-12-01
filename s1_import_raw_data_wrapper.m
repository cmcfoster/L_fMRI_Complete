%% load paths

load_paths_and_open_log;

%% get cores

n_cores = feature('numcores');
delete(gcp('nocreate'));
parpool(n_cores);

%% Import raw data -----

for i = 1:size(wave_list, 2)
    subj_dir_list = dir([base_path wave_list{1, i} '/MRI/NII/3tb*']);           % raw data folder where all subjects stored
    parfor j = 1:size(subj_dir_list, 1)                                            % loop through each subject in each specified wave
        subj = subj_dir_list(j).name;
        wave = wave_list{1,i};
        longf = [base_path, '/', 'Longitudinal_Data/', wave_dir, '/MRI/FMRI/data'];         % new longitudinal data folder
        try
            import_raw_data(base_path, longf, subj, wave, log_path);
        catch ME
            log_subj_process(subj, 'import raw data', 1, ME.message, log_path, false);
        end
    end
end