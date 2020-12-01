#!/bin/tcsh

# tcsh /raid/data/shared/software/scripts/fmri/Longitudinal_fMRI/s6_group_level_effects_dj_testing_3dLMEr.sh

# load modules
module load afni/20.2.11

# set parameters
set task = "dj/testing_LMEr"
set base_dir = "/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI"
set out_file = "${base_dir}/group_analyses/${task}/results.nii.gz"
set out_file_residual = "${base_dir}/group_analyses/${task}/results_residual.nii.gz"
set data_table = "${base_dir}/group_analyses/${task}/in_data_table.txt"
set mask_file = "${base_dir}/GroupTemplate/GroupTemplate_WB_mask_no_hole.nii"

## run model
date

3dLMEr \
-prefix $out_file \
-jobs 8 \
-model "contrast+age_w1_mc+lag_years+contrast_x_age_w1_mc+contrast_x_lag_years+age_w1_mc_x_lag_years+contrast_x_age_w1_mc_x_lag_years+(1+contrast|Subj)" \
-qVars "contrast,age_w1_mc,lag_years,contrast_x_age_w1_mc,contrast_x_lag_years,age_w1_mc_x_lag_years,contrast_x_age_w1_mc_x_lag_years" \
-qVarCenters "0,0,0,0,0,0,0" \
-SS_type 3 \
-mask $mask_file \
#-resid $out_file_residual \
-dbgArgs \
-gltCode contrast 'contrast :' \
-gltCode age_w1_mc 'age_w1_mc :' \
-gltCode lag_years 'lag_years :' \
-gltCode contrast_x_age_w1_mc 'contrast_x_age_w1_mc :' \
-gltCode contrast_x_lag_years 'contrast_x_lag_years :' \
-gltCode age_w1_mc_x_lag_years 'age_w1_mc_x_lag_years :' \
-gltCode contrast_x_age_w1_mc_x_lag_years 'contrast_x_age_w1_mc_x_lag_years :' \
-dataTable @${data_table}

date
