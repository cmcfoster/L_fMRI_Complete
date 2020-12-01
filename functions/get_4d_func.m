function [func] = get_4d_func(subj_path, task, prefix)
%get_4d_func reads/loads 4d functional images
%
%   input:
%      subj_path     directory to subject path
%      task          name of task (e.g., DJ1 or Nback1)
%
%   output:
%      func          4d functional matrix
%
    nii_4d = correct_path([subj_path '\func_4D\' task '_' prefix '_4D.nii']);

    if ~exist(nii_4d, 'file')
      error_msg = sprintf('%s file does not exist', nii_4d);
      error(error_msg);
    end

    func = spm_read_vols(spm_vol(nii_4d));

end
