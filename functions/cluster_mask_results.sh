#!/bin/tcsh

# load modules ----
module load afni

# tcsh /raid/data/shared/software/scripts/fmri/Longitudinal_fMRI/functions/cluster_mask_results.sh

# set parameters ----
#set n_vox = 56
set task = "dj"
set base_dir = "/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI"
set in_file = "${base_dir}/group_analyses/${task}/testing_3dLMEr/results.nii.gz"

set in_3dclustsim_file = "${base_dir}/group_analyses/${task}/results_residual_3dClustSim.txt" # using residual from 3dLME since it's not currently available on 3dLMEr #`echo $in_file | sed s/.nii.gz/.nii/g | sed s/.nii/_residual_3dClustSim.txt/g`
set contrast_labels = (`3dinfo -verb ${in_file} | grep "sub-brick" | grep "Z" | awk -F"'" '{print $2}' | sed s/' Z'//g`)

set p_thr = 0.001
set vox_thr = `Rscript /raid/data/shared/software/scripts/fmri/Longitudinal_fMRI/functions/get_cluster_threshold.R ${in_3dclustsim_file}`
echo "alpha = 0.05, p-threshold = ${p_thr}, voxel-threshold: ${vox_thr}"

foreach i (`seq 1 1 ${#contrast_labels}`)
  set contrast_label = $contrast_labels[$i]
  set threshold_label = "${contrast_label} Z"

  set mask = "${base_dir}/GroupTemplate/GroupTemplate_WB_mask_no_hole.nii"
  set out_mask_file = `echo $in_file | sed s/.nii/_${contrast_label}_mask.nii/g`
  set out_masked_file = `echo $in_file | sed s/.nii/_${contrast_label}_masked.nii/g`
  set out_cluster_file = `echo $in_file | sed s/.nii.gz/.nii/g | sed s/.nii/_${contrast_label}_clusters.txt/g`

  # run 3dClusterize ----
  3dClusterize \
  -inset ${in_file} \
  -mask ${mask} \
  -ithr "${threshold_label}"  \
  -idat "${contrast_label}" \
  -bisided p=${p_thr} \
  -NN 3 \
  -clust_nvox ${vox_thr} \
  -pref_map ${out_mask_file} \
  -pref_dat ${out_masked_file} > ${out_cluster_file}
end
