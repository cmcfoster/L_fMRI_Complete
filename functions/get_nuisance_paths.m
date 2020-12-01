base_dir = '/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI';

subj_list = dir([base_dir '/data/3tb*_*']);
subj_list = {subj_list.name};

task_list = {'dj' 'nback'};

% needs to be fixed for subj that have a .m file but no runs

for (i = 1:length(subj_list))
    for (j= 1:length(task_list))
        in_dir = [base_dir '/data/' subj_list{i} '/first_level_' task_list{j} '/'];
        in_file = 'first_level_batch.mat';
        in_path = [in_dir in_file]; 
        
        out_path = [in_dir 'nuisance_paths.csv'];
        
        if exist(in_path, 'file') == 0
            continue;
        end
        
        first_level_batch = load(in_path);
        first_level_batch = first_level_batch.matlabbatch;
        nuisance_paths = [first_level_batch{1,1}.spm.stats.fmri_spec(:).sess.multi_reg];
        writecell(nuisance_paths', out_path);
        
    end
end



