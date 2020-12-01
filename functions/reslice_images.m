function [] = reslice_images(images)
%reslice_images reslice images
%   reslice images based on their header files

% initialize matlabbatch
matlabbatch = {};

% reslice
matlabbatch{1}.spm.spatial.realign.write.data = images;
matlabbatch{1}.spm.spatial.realign.write.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.write.roptions.interp = 7;
matlabbatch{1}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.write.roptions.prefix = 'r';
spm_jobman('run',matlabbatch);
end

