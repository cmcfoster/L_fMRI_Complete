function [] = spm_concat_3d_to_4d(images, output_4d_image)
%spm_concat_3d_to_4d Create 4d nifti image from list of 3d nifti images
%
% input:
%   images            path list of 3d nifti images
%   output_4d_image   path output of 4d nifti image
%
% output:
%   4d nifti file in output_4d_image path

% initialize matlabbatch
matlabbatch = {};

% concatenate files to 4d file
matlabbatch{1}.spm.util.cat.vols = images;
matlabbatch{1}.spm.util.cat.name = output_4d_image;
matlabbatch{1}.spm.util.cat.dtype = 4;
matlabbatch{1}.spm.util.cat.RT = NaN;
spm_jobman('run', matlabbatch);

end
