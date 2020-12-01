#!bin/tcsh

# script to determine cluster correction
# determine shape of spatial autocorrelation using FWHMx on the residuals,

# tcsh /raid/data/shared/software/scripts/fmri/Longitudinal_fMRI/functions/cluster_correction.sh

# load modules ----
module load afni

# set paths ----
set in_file = $1
set out_fwhm_file = `echo $in_file | sed s/.nii.gz/.nii/g | sed s/.nii/_3dFWHMx.txt/g`
set out_3dclustsim_file = `echo $in_file | sed s/.nii.gz/.nii/g | sed s/.nii/_3dClustSim.txt/g`
set base_dir = "/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI"
set mask = "${base_dir}/GroupTemplate/GroupTemplate_WB_mask_no_hole.nii"

# run 3dFWHMx ----
3dFWHMx -mask ${mask} ${in_file} | tee ${out_fwhm_file}

# run 3dClustSim ----
set fwhm_x = `cat ${out_fwhm_file} | awk 'FNR == 2 {print $1}'`
set fwhm_y = `cat ${out_fwhm_file} | awk 'FNR == 2 {print $2}'`
set fwhm_z = `cat ${out_fwhm_file} | awk 'FNR == 2 {print $3}'`
3dClustSim -mask ${mask} -acf ${fwhm_x} ${fwhm_y} ${fwhm_z} > ${out_3dclustsim_file}
