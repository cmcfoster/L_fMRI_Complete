function [] = brain_extraction(anat,overwrite)
%brain_extraction create brain extracted T1 by masking T1 image with binary
%   images of the gray, white, csf images
%
% input:
%   anat      full path to T1
%
% output:
%   brain extracted nitfi with the appended suffix of BET_MPRAGE.nii
%

% ensure that file exists
if ~exist(anat, 'file')
    error_msg = sprintf('%s file does not exist', anat);
    error(error_msg);
end

% subj path
subj_dir = fileparts(anat);

% subj id
subj = get_subj_mri_id(anat);

cname = dir([subj_dir correct_path('\c*.nii')]);

% ensure that segments exists
if size(cname, 1) == 0
    error_msg = 'no segments found';
    error(error_msg);
end

% warn if outfile exist
out_file = correct_path(sprintf('%s/%s_BET_MPRAGE.nii', subj_dir, subj));
if exist(out_file) && contains(overwrite,'f','IgnoreCase',true)
    warning_msgf = sprintf('%s file already exist, skipping subject',out_file);
    error(warning_msgf);
elseif exist(out_file)
    warning_msgt = sprintf('%s file already exist, will replace',out_file);
    warning(warning_msgt);
end

imglist = {};
imglist{1,1} = anat;
imglist{2,1} = fullfile(cname(1).folder,cname(1).name);
imglist{3,1} = fullfile(cname(2).folder,cname(2).name);
imglist{4,1} = fullfile(cname(3).folder,cname(3).name);
matlabbatch = {};
matlabbatch{1}.spm.util.imcalc.input = imglist;
matlabbatch{1}.spm.util.imcalc.output = out_file;
matlabbatch{1}.spm.util.imcalc.outdir = '';
matlabbatch{1}.spm.util.imcalc.expression = 'i1.*(i2+i3+i4)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
save(correct_path([subj_dir '\brain_extraction_batch.mat']),'matlabbatch');
spm_jobman('run',matlabbatch);
end
