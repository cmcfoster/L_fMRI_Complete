function[] = fsl_smooth_images(image,smoothing_distance,overwrite)
%smooth_images This function smooths the images by the smoothing distance (mm).
% input:
%   image                 nifti volume
%   smoothing_distance    smoothing distance in mm to be used to create the 3d cube smoothing kernel
% output:
%   smoothed image with the prefix s
% fsl does not convert to a gaussian at FWHM so we must do that. What
% follows is a rough approximation of FWHM
% https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;8ac7a10d.0707
% http://mathworld.wolfram.com/GaussianFunction.html
fwhm = smoothing_distance/2.355;
setenv('FSLOUTPUTTYPE','NIFTI');
% tmp = [];
% for i = 1:size(image,2)
%     tmp = [tmp;image{i}];
% end
% image = tmp;
for i = 1:size(image,1)
    image_out = strrep(image{i},'gwrvol','sgwrvol');
    if exist(image_out,'file') && any(contains(overwrite,'f','IgnoreCase',true))
        fprintf('skipping %s, already exists',image_out)
    else
        fsl_command = sprintf('fslmaths %s -s %d %s',image{i},fwhm,image_out);
        system(fsl_command);
    end
end