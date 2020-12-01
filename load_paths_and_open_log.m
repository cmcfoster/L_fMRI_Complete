%% Set paths and get subject list -----
clear
clc

%drive_list = {'/raid/data/shared/','W:/','/Volume/shared/'};
base_path = uigetdir('','Choose KK_KR_JLBS folder');
spm_path = uigetdir('','Choose SPM12 folder');                              % will open file browser window where user selects path to SPM12 directory
long_fmri_path = uigetdir('','Choose Longitudinal_fMRI scripts folder');                              % will open file browser window where user selects path to Longitudinal_fMRI scripts directory

%hard coded just to save time for trouble shooting
%base_path = '/raid/data/shared/KK_KR_JLBS';
%spm_path = '/opt/spm/12';
%long_fmri_path = '/raid/data/shared/software/scripts/fmri/Longitudinal_fMRI';

% add slash
if ~strcmp(base_path(end),'/')
base_path = [base_path '/'];
end
                                    
% set number of waves
waves = {'1', '2'};

% add spm12 path to matlab
addpath(spm_path);

% add path to longitudinal fmri scripts directory
addpath(genpath(long_fmri_path));

% automatically create wave dir
wave_dir = strjoin(strcat('W', waves), '_');                                                       

% automatically create wave list
wave_list = strcat('Wave', waves);

% set id list using MRI tracking excel file
mri_tracking_path = correct_path([long_fmri_path '\Copy_Wave2_MRI_Tracking.xlsx']);
id_list = get_w1_w2_ids(mri_tracking_path); % list linking W1 and W2 MRI_IDs

% add slash
if ~strcmp(base_path(end),'/')
base_path = [base_path '/'];
end

% set fsl environment in case fsl is used
setenv('FSLOUTPUTTYPE','NIFTI');

%% Create and open txt file to store errors
log_dir = [base_path 'Longitudinal_Data/' wave_dir '/MRI/FMRI/'];
log_path = [log_dir, 'processing_log.txt'];

temp_base_path = split(base_path,["/","\"]);
temp_spm_path = split(spm_path,["/","\"]);

if ~strcmp(temp_base_path{end},'KK_KR_JLBS') && ~strcmp(temp_base_path{end-1}, 'KK_KR_JLBS')
    error('basepath does not end with KK_KR_JLBS. Please restart script and choose correct path.');
end

if ~strcmp(temp_spm_path(end),{'spm12', '12'})
    error('ERROR: \nspm path does not end with spm12 or 12. Please restart script and choose correct path.');
end