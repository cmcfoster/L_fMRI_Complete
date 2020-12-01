function [] = reslice_func(vols,gtemp_dir,overwrite)
%reslice_func This function reslices the functional images. Note that doing 
%this after realignment and coregistration is critical so that it will apply 
%both steps simultaneously. 
%We did this so that ants will properly read the file. 
%In an ideal world we would only interpolate
%the image once, but interpolating only based on a rigid registration is
%extremely minimal. ANTs reads header info differently and thus does not
%realize that the images have been realigned and coregistered and will
%never get the images in the right spot. 

gtemp3mm = correct_path([gtemp_dir '/template0_3mm.nii']); % group template resampled to 3mm.
%if ~exist(gtemp3mm,'file')
%    gunzip(strrep(gtemp3mm,'3mm.nii','3mm.nii.gz'))
%end
if contains(overwrite,'f','IgnoreCase',true)
    for i = size(vols,1):-1:1
        if exist(strrep(vols{i},'vol_','rvol_'),'file')
            vols(i) = [];
        end
    end
    if isempty(vols)
        error('all vols have been resliced. Change overwrite to true if you want to redo them')
    end
end
matlabbatch = {};    
matlabbatch{1}.spm.spatial.coreg.write.ref = {gtemp3mm};
%%
matlabbatch{1}.spm.spatial.coreg.write.source = vols;
%%
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
spm_jobman('run',matlabbatch);
end

