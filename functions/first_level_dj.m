function [matlabbatch,out_dir] = first_level_dj(subj_dir,mask,overwrite)
%first_level_dj perform first-level analysis for DJ
%onset path \\cvlkrfs\shared\KK_KR_JLBS\Longitudinal_Data\W1_W2\MRI\FMRI\hard_coded_onsets

out_dir = correct_path([subj_dir '/first_level_dj/' ]);
if any(strcmp(overwrite,["f","F","False","false"])) && exist([out_dir 'SPM.mat'],'file')
    matlabbatch = {};
    error('skipping %s, already completed processing',subj_dir)
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
    [~, dj_list, ~] = get_functional_volumes(subj_dir, 'sgwrvol');               % find paths to functional volumes for both tasks
    
    [motion_files] = get_file_path([subj_dir '/*/too_much*.csv']);
    dj_motion = {''};
    if  ~isempty(motion_files{1,1})
        dj_motion = motion_files(contains(motion_files,'DJ'));
    end
    if isempty(dj_motion)
        dj_motion = {''};
    end
    subj = get_subj_mri_id(subj_dir);
    subj_w_id = extractAfter(subj_dir,'FMRI/data/');

    matlabbatch = {};
    %% Scan parameters
    matlabbatch{1}.spm.stats.fmri_spec.dir = {out_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.5;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    
    %% RUNS
    if size(dj_motion,1) > 1
        error('%s has too much motion for DJ first level effects',subj);
    else
        counter = 1;
        for ii = 1:size(dj_list,2)
            task = char(extractBetween(dj_list{ii}{1,1},subj_w_id,'sgw'));
            if ~contains(dj_motion,erase(task,["/","\"]))
                % scans
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).scans = dj_list{ii};
                % task onsets
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).multi = {[subj_dir task 'onsets.mat']};
                % nuisance
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).regress = struct('name', {}, 'val', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).multi_reg = {[subj_dir task 'nuisance_regressors.txt']};
                matlabbatch{1}.spm.stats.fmri_spec.sess(counter).hpf = 128;
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
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'control';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 ];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Easy';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Medium';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1 0];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Hard';
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1];
        matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Easy > Control';
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [-1 1 0 0];
        matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Medium > Control';
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [-1 0 1 0];
        matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Hard > Control';
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [-1 0 0 1];
        matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'linear_with_control';
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [-1.5 -.5 .5 1.5];
        matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'linear_without_control';
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 -1 0 1];
        matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'Task > control';
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [-3 1 1 1];
        matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'quadratic_with_control';
        matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [-0.535 0.535 0.267 -0.535];
        matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'quadratic_without_control';
        matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [0 -1 2 -1];
        matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'replsc';
        matlabbatch{3}.spm.stats.con.delete = 1;
        
        save([out_dir 'first_level_batch.mat'],'matlabbatch');
    end
end
end

