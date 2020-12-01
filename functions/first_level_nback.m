function [matlabbatch,out_dir] = first_level_nback(subj_dir,mask,overwrite)
%first_level_nback perform first-level analysis for n-back
%Input subj_dir and overwrite flag. Either true, to overwrite the current
%matlabbatch or false, to not overwrite it.

out_dir = correct_path([subj_dir '/first_level_nback/' ]);
if any(strcmp(overwrite,["f","F","False","false"])) && exist([out_dir 'SPM.mat'],'file')
    matlabbatch = {};
    error('skipping %s, already completed processing',subj_dir);
else
    if ~exist(out_dir,'dir')
        mkdir(out_dir);
    end
    base_path = extractBefore(subj_dir,'Longitudinal_Data');
    if contains(mask,'T','IgnoreCase',true)
        mask_path = get_file_path([base_path '/Longitudinal_Data/W1_W2/MRI/FMRI/GroupTemplate/GroupTemplate_WB_mask_no_hole.nii']);
    else
        mask_path = {''};
    end
    [~, ~, nback_list] = get_functional_volumes(subj_dir, 'sgwrvol');               % find paths to functional volumes for both tasks
    
    [motion_files] = get_file_path([subj_dir '/*/too_much*.csv']);
    nback_motion = {''};
    if  ~isempty(motion_files{1,1})
        nback_motion = motion_files(contains(motion_files,'Nback'));
    end
    if isempty(nback_motion)
        nback_motion = {''};
    end
    subj = get_subj_mri_id(subj_dir);
    subj_w_id = [subj extractAfter(subj_dir,subj)];
    
    matlabbatch = {};
    %% Scan Parameters
    matlabbatch{1}.spm.stats.fmri_spec.dir = {out_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.5;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    
    %% RUNS
    if size(nback_motion,1) > 1
        error('%s has too much motion for Nback first level effects',subj);
    else
        counter = 1;
        for ii = 1:size(nback_list,2)
            task = char(extractBetween(nback_list{ii}{1,1},subj_w_id,'sgw'));
            if ~contains(nback_motion,erase(task,["/","\"]))
                % scans
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).scans = nback_list{ii};
                % task onsets
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).multi = {[subj_dir task 'onsets.mat']};
                % nuisance
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress = struct('name', {}, 'val', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).multi_reg = {[subj_dir task 'nuisance_regressors.txt']};
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).hpf = 210;
                counter = counter + 1;
            end
        end
        
        % other specs
        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;
        matlabbatch{1}.spm.stats.fmri_spec.mask = mask_path;
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
        
        %% design matrix
        matlabbatch{2}.spm.stats.fmri_est.spmmat = {[out_dir 'SPM.mat']};
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
        %% contrasts
        matlabbatch{3}.spm.stats.con.spmmat = {[out_dir 'SPM.mat']};
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '0-back';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 ];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = '2-back';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = '3-back';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = '4-back';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1];
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = '2-back > 0-back';
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [-1 1 0 0];
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = '3-back > 0-back';
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [-1 0 1 0];
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = '4-back > 0-back';
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [-1 0 0 1];
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'linear_with_control';
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [-2.25 -0.25 0.75 1.75];
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'linear_without_control';
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 -1 0 1];
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'quadratic_with_control';
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [-0.535 0.535 0.267 -0.535];
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.delete = 1;
        
        save([out_dir 'first_level_batch.mat'],'matlabbatch');
        
    end
end
end
