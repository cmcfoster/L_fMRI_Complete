#!/bin/tcsh

# load modules
module load afni

# set parameters
set task = "dj"
set base_dir = "/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI"
set out_file = "${base_dir}/group_analyses/${task}/results.nii.gz"
set out_file_residual = "${base_dir}/group_analyses/${task}/results_residual.nii.gz"
set data_table = "${base_dir}/group_analyses/${task}/in_data_table.txt"
set mask_file = "${base_dir}/GroupTemplate/GroupTemplate_WB_mask_no_hole.nii"

## run model
date

3dLME \
-prefix $out_file \
-jobs 8 \
-model "contrast+age_w1_mc+lag_years+contrast_x_age_w1_mc+contrast_x_lag_years+age_w1_mc_x_lag_years+contrast_x_age_w1_mc_x_lag_years" \
-qVars "contrast,age_w1_mc,lag_years,contrast_x_age_w1_mc,contrast_x_lag_years,age_w1_mc_x_lag_years,contrast_x_age_w1_mc_x_lag_years" \
-qVarCenters "0,0,0,0,0,0,0" \
-ranEff "~1+contrast" \
-SS_type 3 \
-mask $mask_file \
-resid $out_file_residual \
-dbgArgs \
-num_glt 7 \
-gltLabel 1 'contrast' -gltCode  1 'contrast :' \
-gltLabel 2 'age_w1_mc' -gltCode 2 'age_w1_mc :' \
-gltLabel 3 'lag_years' -gltCode 3 'lag_years :' \
-gltLabel 4 'contrast_x_age_w1_mc' -gltCode  4 'contrast_x_age_w1_mc :' \
-gltLabel 5 'contrast_x_lag_years' -gltCode 5 'contrast_x_lag_years :' \
-gltLabel 6 'age_w1_mc_x_lag_years' -gltCode 6 'age_w1_mc_x_lag_years :' \
-gltLabel 7 'contrast_x_age_w1_mc_x_lag_years' -gltCode  7 'contrast_x_age_w1_mc_x_lag_years :' \
-dataTable @${data_table}

date
