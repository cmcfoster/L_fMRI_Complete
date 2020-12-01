function [] = fsl_concat_3d_to_4d(in_vols,out_4d,overwrite)
%   fsl_concat_3d_to_4d Summary of this function goes here
%   Detailed explanation goes here
tmp = strjoin(in_vols');
if exist(out_4d,'file') && any(contains(overwrite,'f','IgnoreCase',true))
    fprintf('skipping 3d to 4d for %s, already exists',out_4d)
else
    fsl_command = ['fslmerge -t ',out_4d,' ',tmp];
    system(fsl_command);
end
end

