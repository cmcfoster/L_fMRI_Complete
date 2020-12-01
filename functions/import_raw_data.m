function [] = import_raw_data(base_path, long_dir, subj, wave, log_path)
%import_raw_data transfers the raw functional and anatomical files to
% the longitudinal directory
%
% input:
%   base_path     base path
%   long_dir      output longitudinal directory
%   subj          3tb mri id
%   wave          wave number
%   log_path      full path to process log file
%
% output:
%   import raw data to longitudinal fmri folder
%

% initialize log
log_process = 'import raw data';
log_subj_process(subj, log_process, 0, 'running', log_path, false);

countfilestransferred = 0;                                          % count total number of files transferred per subject
subj_dir = [base_path wave '/MRI/NII/' subj];         						% raw folder

% ensure folder exists
if ~exist(subj_dir)
	log_note = sprintf('%s directory does not exist', subj_dir);
	%log_subj_process(subj, log_process, 1, log_note, log_path, false);
	error(log_note);
end

% raw files
csubfiles = dir([subj_dir '/**/*.nii']);

% check to be sure there are files to transfer
if size(csubfiles,1) <= 0
	log_note = sprintf('%s has 0 files in the directory', subj_dir);
	%log_subj_process(subj, log_process, 1, log_note, log_path, false);
	error(log_note);
end

for k = 1:size(csubfiles,1)                                     %loop through files
    if strcmp(csubfiles(k).name(1:3),'vol') || strcmp(csubfiles(k).name(1:3),'MPR') %only transfer functional images that start with vol (i.e., not 4d images) and T1 mprage files
        oldfile = fullfile(csubfiles(k).folder,csubfiles(k).name);% old file to be transferred
        parts = split(csubfiles(k).folder,{'\','/'});           % all parts of directory
        if strcmp(csubfiles(k).name(1:3),'vol')                 % make newfile depend upon whether functional or t1
            newfile = fullfile(long_dir, subj,parts{end,1}, csubfiles(k).name);
        else
            newfile = fullfile(long_dir, parts{end,1},[subj '_' csubfiles(k).name]);
        end
        newdir = fileparts(newfile);                            % new file and filepath
        if ~exist(newdir,'dir')                                 % only make new directory once
            mkdir(newdir)
        end
        if ~exist(newfile,'file')
						try
							copyfile(oldfile, newfile) % potentially add a try catch
						catch ME
							log_subj_process(subj, log_process, 1, ME.message, log_path, false);
						end
            countfilestransferred = countfilestransferred + 1;
        end
    end
end

log_note = sprintf('complete: %d files transferred', countfilestransferred);
log_subj_process(subj, log_process, 0, log_note, log_path, false);

end
