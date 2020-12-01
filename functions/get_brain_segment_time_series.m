function [] = get_brain_segment_time_series(gtemp_seg_file_list, subj_dir, task_dir_list, nii_prefix, out_prefix,overwrite)
%get_brain_segment_time_series Extract time series for gray, white, csf,
%whole brain signal
%   Detailed explanation goes here
% obtain task directories

%gtemp_seg_file_list = gtemp_seg_list(2:3);
%subj_dir = subj_dir_list{i};
%out_prefix = 'gwvol_wm_csf';

for j = 1:size(task_dir_list, 1)
    
    task = strsplit(task_dir_list{j}, {'/', '\'});
    task = task{end};
    out_file = correct_path([subj_dir '\' task '\' out_prefix '_ts.csv']);
    
    if exist(out_file,'file') && any(contains(overwrite,'f','IgnoreCase',true))
        error('Skipping %s, already exists',out_file);
    else
        
        func = get_4d_func(subj_dir, task, nii_prefix);
        
        % for loop through each segment
        seg_ts = [];
        for k = 1:size(gtemp_seg_file_list, 1)
            % load segment
            seg = spm_read_vols(spm_vol(gtemp_seg_file_list{k}));
            
            % mask segment
            seg_thr = .95;
            seg_mask = (seg >= seg_thr);
            
            % functional threshold (used to eliminate zeros from func img)
            func_thr = 100;
            
            % for loop through each func vol
            for l = 1:size(func, 4)
                func_vol = func(:,:,:,l);
                func_vol_mask = func_vol >= func_thr;
                seg_ts(l, k) = nanmean(func_vol(seg_mask & func_vol_mask));
            end
        end
        
        % save
        csvwrite(out_file, seg_ts);
    end
end
