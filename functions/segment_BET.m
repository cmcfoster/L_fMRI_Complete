function [BET] = segment_BET(anat, spm_path, overwrite)
%segment_BET segment BET'd brain into different tissue types
%   Uses probability maps (TPM.nii) from SPM12 and segments the T1 into:
%   gm, wm, csf, bone, soft tissue, and air/background
%
%   input:
%       anat      full path to BET nifti
%       spm_path  full path to spm12 directory to obtain tissue probability maps
%       overwrite set to 'false' or 'f' if you don't want to overwrite the image.
%
%   output:
%       segmented brain in the same anat directory
%       1. gm
%       2. wm
%       3. csf
%       4. bone
%       5. soft tissue
%       6. air/background

% find BET

BET = char(correct_path(get_file_path([fileparts(anat) '//3tb*BET_*.nii'])));

% ensure that file exists
if ~exist(BET, 'file')
    error_msg = sprintf('%s file does not exist', BET);
    error(error_msg);
end

% ensure that file exists
if ~exist(spm_path, 'dir')
    error_msg = sprintf('%s directory does not exist', spm_path);
    error(error_msg);
end

% warn if file already exists
anat_file_parts = dir(BET);
out_file_list = strcat(anat_file_parts.folder, {'/c'}, {'1', '2', '3', '4', '5'}, anat_file_parts.name)';
for i = 1:size(out_file_list, 1)
    if exist(out_file_list{i}, 'file')
        warning_msgf = sprintf('%s file already exists, skipping subject', out_file_list{i});
        warning_msgt = sprintf('%s file already exists, replacing file', out_file_list{i});
        if contains(overwrite,'f','IgnoreCase',true)
            error(warning_msgf);
        else
            warning(warning_msgt);
        end
    end
end

% run the matlab segment batch
matlabbatch{1}.spm.spatial.preproc.channel.vols = {BET};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {correct_path([spm_path '\tpm\TPM.nii,1'])};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {correct_path([spm_path '\tpm\TPM.nii,2'])};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {correct_path([spm_path '\tpm\TPM.nii,3'])};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {correct_path([spm_path '\tpm\TPM.nii,4'])};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {correct_path([spm_path '\tpm\TPM.nii,5'])};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {correct_path([spm_path '\tpm\TPM.nii,6'])};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
save(correct_path([fileparts(BET) '\segment_BET_Batch.mat']), 'matlabbatch');
spm_jobman('run', matlabbatch);

end
