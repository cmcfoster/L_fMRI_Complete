function [] = resample(image_defining_space,masks)
%resample Resamples images to size of voxels of image_defining_space image

matlabbatch = {};
matlabbatch{1}.spm.spatial.coreg.write.ref = image_defining_space;
matlabbatch{1}.spm.spatial.coreg.write.source = cellstr(masks);
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 7;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
spm_jobman('run',matlabbatch);
end

