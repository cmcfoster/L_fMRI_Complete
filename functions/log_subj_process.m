function [text_log] = log_subj_process(subj, process, error, note, log_path, quiet)
%log_subj_process logs process of subj
%
%   input:
%       subj        subject id (i.e., 3tb mri id)
%       process     name of process
%       error       1 if error 0 if not
%       note        note (e.g., running, intermediate step, complete, summary)
%       log_path    complete path to log file
%       quiet       do not display text log to command window (default: false)
%
%   output:
%       log_path file of columns: date, time, subj, process, error, note

% command to print
text_log = sprintf('%s, %s, %s, %i, %s', datetime('now', 'Format', 'uuuu-MM-dd'', ''HH:mm:ss'), subj, process, error, note);

% print text to screen if quiet is not false
if quiet == false
    fprintf('%s \n', text_log)
end

% does file exist, create file with column names
if ~exist(log_path, 'file')
    file_id = fopen(log_path, 'a+');
    colnames_log = sprintf('date, time, subj, process, error, note');
    fprintf(file_id, '%s \n', colnames_log);
    fclose(file_id);
end

% append text to file
file_id = fopen(log_path, 'a+');
fprintf(file_id, '%s \n', text_log);
fclose(file_id);

end
