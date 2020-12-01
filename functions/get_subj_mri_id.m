function [subj] = get_subj_mri_id(in_path)
%get_subj_mri_id get the subj mri id (i.e., 3tb number) from a file or directory
%  path
%
%   input:
%      in_path     file or directory 
%
%   output:
%      subj        subject's mri id (i.e., 3tb number)
%
id_start = strfind(in_path, '3tb');
id_end = id_start + 6;
subj = in_path(id_start:id_end);
end

