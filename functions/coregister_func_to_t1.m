function [] = coregister_func_to_t1(anat, func_images)
%coregister_func_to_t1 Coregister the mean functional image to the t1
%and then apply that to all other functional images, which need to have been
%realigned to the mean image first
%
% input:
%     anat          full path to t1 mprage
%     func_images   full path list of all functional volumes (not including the mean functional image)
%
% output:
%     co-registered mean functional image and functional images in the header files
%

if ~exist(anat,'file')
  error('%s file does not exist', anat);
end

matlabbatch{1}.spm.spatial.coreg.estimate.ref = {anat};
matlabbatch{1}.spm.spatial.coreg.estimate.source = func_images(1);
matlabbatch{1}.spm.spatial.coreg.estimate.other = func_images;
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
save(correct_path([fileparts(anat) '\batch_coregister_func_to_t1.mat']), 'matlabbatch');
spm_jobman('run',matlabbatch);
end
