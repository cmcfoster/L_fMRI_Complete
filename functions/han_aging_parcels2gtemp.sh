#!/bin/bash

# bash /raid/data/shared/software/scripts/fmri/Longitudinal_fMRI/functions/han_aging_parcels2gtemp.sh

module load ants

moving_nii='/raid/data/shared/Atlases/Han_Aging_Parcellations/YA_parcel_MNI_3mm.nii.gz'
fixed_nii='/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/GroupTemplate/template0_3mm.nii.gz'
out_nii='/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/gtemp2atlas_warps/hap_ya_mni_3mm_gtemp.nii.gz'

mat_file='/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/gtemp2atlas_warps/mni152linear_3mm_0GenericAffine.mat'
nonlinear_file='/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/gtemp2atlas_warps/mni152linear_3mm_1InverseWarp.nii.gz'

antsApplyTransforms \
--default-value \
--interpolation NearestNeighbor \
--dimensionality 3 \
--input ${moving_nii} \
--reference-image ${fixed_nii} \
--output ${out_nii} \
--transform [${mat_file},1] ${nonlinear_file}
