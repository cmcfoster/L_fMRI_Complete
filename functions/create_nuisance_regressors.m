function [nuisance_regressors] = create_nuisance_regressors(m_paths,dummy_list)
%Create Nuisance Regressors. combine all calculated nuisance regressors,
%ensure they are the same length, add dummy variables for flagged volumes
%if there are any.
%   Input a single cell array with all file paths to files ending with .csv
%   or .txt.

wm_csf_der = readmatrix(char(m_paths(contains(m_paths,{'gwrvol_wm_csf_ts_td1'}))));
rp_der = readmatrix(char(m_paths(contains(m_paths,'rp_vol_0000_td1'))));

test_of_size = size(wm_csf_der,1) == size(rp_der,1);

if test_of_size
    nuisance_regressors = [wm_csf_der,rp_der];
elseif test_of_size
    error('Size of input nuisance regressors unequal. \nCheck nuisance files in run folder.');
end

if isempty(dummy_list)
elseif size(nuisance_regressors,1) == size(dummy_list,1)
    nuisance_regressors = [nuisance_regressors,dummy_list];
elseif size(nuisance_regressors,1) ~= size(dummy_list,1)
    error('Size of nuisance regressors and flagged volumes unequal.');
end
end

