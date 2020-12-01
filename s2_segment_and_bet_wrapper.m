%% Load Paths

load_paths_and_open_log;

%% grab newly transferred subjects for subj_list

subj_dir_list = get_file_path(correct_path([base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/data/3tb*']));
subj_dir_list = subj_dir_list(~contains(subj_dir_list, '.mat'));

%% Set number of cores to use (always sets to max) -----

n_cores = feature('numcores');
delete(gcp('nocreate'));
parpool(n_cores);

%% Segment brain and Brain Extraction (i.e., BET and BET2) -----
% QC BET and BET2 after this, create a list with subject folder name and
% binary decision of wich BET to keep Bet = 0, BET2 = 1. Run the QC script
% that will delete the appropriate BET info so the rest of the scripts can
% run.

parfor i = 1:size(subj_dir_list, 1)                                             % loop through subjects
    subj = get_subj_mri_id(subj_dir_list{i});
    anat = {};
    try
        log_subj_process(subj, 'get first acq t1', 0, 'processing', log_path, false);
        anat = correct_path(get_first_acq_t1(subj_dir_list{i}));                                % find T1 acquired first in time for those with >1 mprage imgs
        log_subj_process(subj, 'get first acq t1', 0, 'complete', log_path, false);
    catch ME
        log_subj_process(subj, 'get first acq t1', 1, ME.message, log_path, false);
    end
    if ~isempty(anat)
        % all functions take a last input as true or false indicating
        % whether to overwrite images if they've already been done
        try
            log_subj_process(subj, 'segment brain', 0, 'processing', log_path, false);
            segment_brain(anat, spm_path,'false'); % function to segment brain using SPM12 tpms
            log_subj_process(subj, 'segment brain', 0, 'complete', log_path, false);
        catch ME
            log_subj_process(subj, 'segment brain', 1, ME.message, log_path, false);
        end
        try
            log_subj_process(subj, 'brain extraction', 0, 'processing', log_path, false);
            brain_extraction(anat,'false');  % create brain extracted T1
            log_subj_process(subj, 'brain extraction', 0, 'complete', log_path, false);
        catch ME
            log_subj_process(subj, 'brain extraction', 1, ME.message, log_path, false);
        end
        try
            log_subj_process(subj, 'segment brain', 0, 'processing', log_path, false);
            segment_BET(anat, spm_path,'false'); % function to segment BET using SPM12 tpms
            log_subj_process(subj, 'segment brain', 0, 'complete', log_path, false);
        catch ME
            log_subj_process(subj, 'segment brain', 1, ME.message, log_path, false);
        end
        try
            log_subj_process(subj, 'brain extraction', 0, 'processing', log_path, false);
            BET = char(correct_path(get_file_path([fileparts(anat) '//3tb*BET_*.nii'])));
            brain_extraction2(BET,'false');  % create BET2
            log_subj_process(subj, 'brain extraction', 0, 'complete', log_path, false);
        catch ME
            log_subj_process(subj, 'brain extraction', 1, ME.message, log_path, false);
        end
    end
end