function [] = get_betas_w_afni(text_file)
%AFNI Extraction
%
% input - requried
% text_file = the full path to data table used in the 
% 3dLME group analysis
%
% output csv of the text_file with cluster betas appended

%text_file = "/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/group_analyses/dj/in_data_table.txt";

file_path = fileparts(text_file);

if isempty(file_path)
    text_file = which(text_file);
    file_path = fileparts(text_file);
end

masks = get_file_path(strcat(file_path, '/*_mask.nii.gz'));
tmp = readtable(text_file);
tmp = tmp(:,1:end-1);
tmp_paths = tmp(:,'InputFile');
new_bp = extractBefore(text_file,'Longitudinal');
old_bp = extractBefore(char(tmp_paths{1,1}),'Longitudinal');
fp = strrep(tmp_paths.InputFile,old_bp,new_bp);
for i = 1:size(masks,1)
    [~,mask_name] = fileparts(masks{i});
    mask_name = strrep(mask_name,'.nii','');
    for j = 1:size(fp,1)
        [~,sub_betas] = system(['module load afni; 3dROIstats -mask ' char(masks{i,1}) ' -nzmean -nomeanout ' char(fp{j,1})],'-echo');
        cluster_betas = str2num(extractAfter(sub_betas,'0[?]'));
        tmp_table(j,:) = [ tmp(j,:) table(cluster_betas)]; 
        clear cluster_betas
    end
    writetable(tmp_table, strcat(file_path, '/', mask_name, 'ed_betas.csv'));
    clear tmp_table mask_name
end
end