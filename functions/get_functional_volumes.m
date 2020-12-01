function [combined_list, dj_list, nback_list] = get_functional_volumes(subj_dir, prefix)
%get_functional_volumes grab functional volumes by all functionals within a
%   subject's directory and by task
%
%   input:
%      subj_dir          subj_dir directory
%      prefix            specificy nifti file prefix to include/exclude certain files
%
%   output:
%      combined_list     list of all functional volumes
%      dj_list           list of all functional volumes for distance judgement task
%      nback_list        list of all functional volumes for n-back task
%

% ensure that subj_dir exists
if ~exist(subj_dir, 'dir')
    error_msg = sprintf('%s file does not exist', subj_dir);
    error(error_msg)
end

combined_list = {}; dj_list = {}; nback_list = {};
runsdj = dir(correct_path(sprintf('%s/DJ*',subj_dir)));
runsnback = dir(correct_path(sprintf('%s/Nb*',subj_dir)));
runs = [runsdj; runsnback];
ncounter = 1;
djcounter = 1;
if size(runs,1) > 0
    if exist(correct_path(sprintf('%s\\%s\\%s_0000.nii', runs(1).folder, runs(1).name, prefix)),'file') %if you are trying to run in parfor use this line of code
        for j = 1:size(runs,1)
            files = dir(correct_path(sprintf('%s/%s/%s*.nii',subj_dir,runs(j).name,prefix)));
            combined_list{1,j} = correct_path(strcat({files.folder}',{'\'},{files.name}'));
            if strfind(files(1).folder,'DJ') > 1
                dj_list{1,djcounter} = correct_path(strcat({files.folder}',{'\'},{files.name}'));
                djcounter = djcounter + 1;
            elseif strfind(files(1).folder,'Nback') > 1
                nback_list{1,ncounter} = correct_path(strcat({files.folder}',{'\'},{files.name}'));
                ncounter = ncounter + 1;
            end
        end
    end
end
