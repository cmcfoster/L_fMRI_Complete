function [id_list3] = get_w1_w2_ids(mri_tracking_excel_path)
%get_w1_w2_ids grab all participants with both wave 1 and wave 2 MRI IDs
%
% input:
%     mri_tracking_excel_path   full path to mri tracking excel file
%
% output:
%     id_list3                   3tb MRI IDs for Wave 1 and 2; each row is each
%                               participant's respective 3tb MRI ID for Wave 1 and 2

% ensure that file exists
if ~exist(mri_tracking_excel_path, 'file')
    error_msg = sprintf('%s file does not exist', mri_tracking_excel_path)
    error(error_msg)
end

% read excel file
[~, ~, id_list] = xlsread(mri_tracking_excel_path);

counter = 1;
for i = 1:size(id_list, 2)
    if strcmp(id_list{1, i}, 'Full MRI ID')
        tmp_list(:, counter) = id_list(:, i);
        counter = counter + 1;
    end
end

tmp_list = tmp_list(cellfun('isclass', tmp_list(:, 1), 'char'), :); % drop nans
tmp_list = strrep(tmp_list, '_W2', '');
tmp_list = unique(tmp_list(:, 1), 'stable');
tmp_list = tmp_list(2:end, 1);

for i = 1:size(tmp_list, 1)
    id_list2{i, :} = split(tmp_list(i, 1), '_')';
end

counter = 1;
for i = 1:size(id_list2, 1)
    if size(id_list2{i, 1}, 2) > 1
    id_list3(counter, 1) = id_list2{i}(1, 1);
    id_list3(counter, 2) = id_list2{i}(1, 2);
    counter = counter + 1;
    end
end

end
