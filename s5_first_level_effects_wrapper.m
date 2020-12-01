%% Load Paths

load_paths_and_open_log;

%% grab newly transferred subjects for subj_list

subj_dir_list = get_file_path(correct_path([base_path '/Longitudinal_Data/' wave_dir '/MRI/FMRI/data/3tb*']));
subj_dir_list = subj_dir_list(~contains(subj_dir_list, '.mat'));

%% Set number of cores to use (always sets to max) -----

n_cores = feature('numcores');
delete(gcp('nocreate'));
parpool(n_cores);

%% Create Timing Files

spm_jobman('initcfg'); % initialize SPM

for i = 1:size(subj_dir_list,1)
    
    % DJ Run 1        
    names = cell(1,4); onsets = cell(1,4); durations = cell(1,4);
    names{1} = 'Control';
    onsets{1} = [81 222];
    durations{1} = [15];
    
    names{2} = 'Easy';
    onsets{2} = [3 48 129 159 192];
    durations{2} = [15];
    
    names{3} = 'Medium';
    onsets{3} = [18 96 144 237 300];
    durations{3} = [15];
    
    names{4} = 'Hard';
    onsets{4} = [66 111 207 255 285];
    durations{4} = [15];
    
    try
         save([char(get_file_path([subj_dir_list{i} '//DJ1*'])) '//onsets.mat'], 'names','durations','onsets');
    catch
         fprintf('no DJ1 directory for %s\n',subj_dir_list{i});
    end

    %DJ Run 2
    names = cell(1,4); onsets = cell(1,4); durations = cell(1,4);
    names{1} = 'Control';
    onsets{1} = [111 207];
    durations{1} = [15];
    
    names{2} = 'Easy';
    onsets{2} = [3 33 159 255 300];
    durations{2} = [15];
    
    names{3} = 'Medium';
    onsets{3} = [18 48 129 174 222];
    durations{3} = [15];
    
    names{4} = 'Hard';
    onsets{4} = [66 96 192 237 285];
    durations{4} = [15];

    try
         save([char(get_file_path([subj_dir_list{i} '//DJ2*'])) '//onsets.mat'], 'names','durations','onsets');
    catch
         fprintf('no DJ2 directory for %s\n',subj_dir_list{i});
    end

    %DJ Run 3
    names = cell(1,4); onsets = cell(1,4); durations = cell(1,4);
    names{1} = 'Control';
    onsets{1} = [18 159 270];
    durations{1} = [15];
    
    names{2} = 'Easy';
    onsets{2} = [3 66 96 174 285];
    durations{2} = [15];
    
    names{3} = 'Medium';
    onsets{3} = [48 81 144 207 255];
    durations{3} = [15];
    
    names{4} = 'Hard';
    onsets{4} = [33 129 192 237 300];
    durations{4} = [15];

    try
         save([char(get_file_path([subj_dir_list{i} '//DJ3*'])) '//onsets.mat'], 'names','durations','onsets');
    catch
         fprintf('no DJ3 directory for %s\n',subj_dir_list{i});
    end

    
    % Nback Run 1        
    names = cell(1,4); onsets = cell(1,4); durations = cell(1,4);
    names{1} = '0-back';
    onsets{1} = [115 255];
    durations{1} = [25];
    
    names{2} = '2-back';
    onsets{2} = [145];
    durations{2} = [105];
    
    names{3} = '3-back';
    onsets{3} = [5];
    durations{3} = [105];
    
    names{4} = '4-back';
    onsets{4} = [285];
    durations{4} = [105];
    
    try
         save([char(get_file_path([subj_dir_list{i} '//Nback1*'])) '//onsets.mat'], 'names','durations','onsets');
    catch
         fprintf('no Nback1 directory for %s\n',subj_dir_list{i});
    end

    %Nback Run 2
    names = cell(1,4); onsets = cell(1,4); durations = cell(1,4);
    names{1} = '0-back';
    onsets{1} = [115 255];
    durations{1} = [25];
    
    names{2} = '2-back';
    onsets{2} = [5];
    durations{2} = [105];
    
    names{3} = '3-back';
    onsets{3} = [285];
    durations{3} = [105];
    
    names{4} = '4-back';
    onsets{4} = [145];
    durations{4} = [105];
    
    try
         save([char(get_file_path([subj_dir_list{i} '//Nback2*'])) '//onsets.mat'], 'names','durations','onsets');
    catch
         fprintf('no Nback2 directory for %s\n',subj_dir_list{i});
    end

    %Nback Run 3
    names = cell(1,4); onsets = cell(1,4); durations = cell(1,4);
    names{1} = '0-back';
    onsets{1} = [115 255];
    durations{1} = [25];
    
    names{2} = '2-back';
    onsets{2} = [145];
    durations{2} = [105];
    
    names{3} = '3-back';
    onsets{3} = [285];
    durations{3} = [105];
    
    names{4} = '4-back';
    onsets{4} = [5];
    durations{4} = [105];
    
    try
         save([char(get_file_path([subj_dir_list{i} '//Nback3*'])) '//onsets.mat'], 'names','durations','onsets');
    catch
         fprintf('no Nback3 directory for %s\n',subj_dir_list{i});
    end

end


%% First Level Effects Nback*
overwrite = 'True';
mask = 'True';
parfor i = 17:size(subj_dir_list,1)
    warning('off','MATLAB:DELETE:FileNotFound');
    subj = get_subj_mri_id(subj_dir_list{i});
    %conpath = dir([subj_dir_list{i} '/first_level_nback/con_0010.nii']);
    %d = datetime(2020,05,28,1,1,1);
    %if isempty(conpath)
    %    try
    %        log_subj_process(subj, 'First Level N-Back', 0, 'processing', log_path, false);
    %        [~,out_dir] = first_level_nback(subj_dir_list{i},mask,overwrite);
    %        if exist([out_dir 'con_0010.nii'],'file') && contains(overwrite,'f','IgnoreCase',true)
    %            error('Skipping %s, already completed first level processing',subj)
    %        else
    %            delete([out_dir 'SPM.mat']);
    %            fprintf('running %s\n',subj);
    %            spm_jobman('run',[out_dir 'first_level_batch.mat']);
    %        end
    %        log_subj_process(subj, 'First Level N-Back', 0, 'complete', log_path, false);
    %    catch ME
    %        log_subj_process(subj, 'First Level N-Back', 1, ME.message, log_path, false);
    %    end
    %elseif conpath.date > d
    %    fprintf('skipping %s\n',subj);
    %else
        try
            log_subj_process(subj, 'First Level N-Back', 0, 'processing', log_path, false);
            [~,out_dir] = first_level_nback(subj_dir_list{i},mask,overwrite);
            if exist([out_dir 'con_0010.nii'],'file') && contains(overwrite,'f','IgnoreCase',true)
                error('Skipping %s, already completed first level processing',subj)
            else
                delete([out_dir 'SPM.mat']);
                fprintf('running %s\n',subj);
                spm_jobman('run',[out_dir 'first_level_batch.mat']);
            end
            log_subj_process(subj, 'First Level N-Back', 0, 'complete', log_path, false);
        catch ME
            log_subj_process(subj, 'First Level N-Back', 1, ME.message, log_path, false);
        end
    %end
end

%% First Level Effects DJ
overwrite = 'True';
mask = 'True';
parfor i = 1:size(subj_dir_list,1)  
    warning('off','MATLAB:DELETE:FileNotFound');
    subj = get_subj_mri_id(subj_dir_list{i});
    try
        log_subj_process(subj, 'First Level DJ', 0, 'processing', log_path, false);
        [~,out_dir] = first_level_dj(subj_dir_list{i},mask,overwrite);
        if exist([out_dir 'con_0012.nii'],'file') && contains(overwrite,'f','IgnoreCase',true)
            error('Skipping %s, already completed first level processing',subj)
        else
           delete([out_dir 'SPM.mat']);
           spm_jobman('run',[out_dir 'first_level_batch.mat']);
        end
        log_subj_process(subj, 'First Level DJ', 0, 'complete', log_path, false);
    catch ME
        log_subj_process(subj, 'First Level DJ', 1, ME.message, log_path, false);
    end
end