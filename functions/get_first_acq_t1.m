function [anat] = get_first_acq_t1(subj_dir)
%get_first_acq_t1 get the file path for the first acquired T1
%
%   input:
%      subj_dir     subject's directory to search for T1s
%
%   output:
%      anat         full path of the first aquired T1
%

% ensure the directory exists
if ~exist(subj_dir, 'dir')
    error_msg = sprintf('%s directory does not exist', subj_dir);
    error(error_msg);
end

%   grab all t1s (some people have more than one)
anat_files = dir([char(subj_dir) '/3tb*MPRAGE2100*.nii']);

% ensure there are files in the directory
if size(anat_files, 1) <= 0
   error_msg = sprintf('%s anat file does not exist', subj_dir);
   error(error_msg);
end

% if they just have 1, then use that T1
if size(anat_files, 1) == 1
    anat = strcat(anat_files.folder,'\', anat_files.name);

% if they have more than one, grab the first acquired T1 regardless of
% number acquired
elseif size(anat_files, 1) > 1
    anat_files = dir([char(subj_dir) '/3tb*MPR*acq*.nii']);
    tmp = split({anat_files.name}', '_');
    tmp = split(tmp(contains(tmp, 'acq')), 'q', 2);
    [~,index] = min(str2double(tmp(:, 2)));
    anat = strcat(anat_files(index).folder, '\', anat_files(index).name);
end

end
