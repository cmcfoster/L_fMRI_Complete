function [] = smooth_images(image, smoothing_distance)
%smooth_images This function smooths the images by the smoothing distance (mm).
% input:
%   image                 nifti volume
%   smoothing_distance    smoothing distance in mm to be used to create the 3d cube smoothing kernel
% output:
%   smoothed image with the prefix s
    matlabbatch = {};
    smoothing_kernel = repmat(smoothing_distance, 1, 3);
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(image);
    matlabbatch{1}.spm.spatial.smooth.fwhm = smoothing_kernel;
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    spm_jobman('run',matlabbatch);

end
