#!/bin/bash
# bash /raid/data/shared/software/scripts/fmri/Longitudinal_fMRI/functions/gtemp2mni152linear.sh
module load ants
module load ants

root_dir=/raid/data/

#3dresample -dxyz 3 3 3 -prefix ${root_dir}/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/gtemp2atlas_warps/mni152linear_t1_3mm_brain.nii.gz -input ${root_dir}/shared/Atlases/MNI/MNI152_T1_1mm_brain.nii.gz

#fixed_nii=${root_dir}/shared/Atlases/MNI/MNI152_T1_3mm_brain.nii.gz

gtemp2atlas_dir=${root_dir}/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/gtemp2atlas_warps

fixed_nii=${gtemp2atlas_dir}/mni152linear_t1_3mm_brain.nii.gz #template0_3mm.nii
moving_nii=${gtemp2atlas_dir}/template0_3mm.nii
out_nii=${gtemp2atlas_dir}/template0_mni152linear_3mm.nii.gz
out_prefix=${gtemp2atlas_dir}/mni152linear_3mm_

# options were default from nipype documentation
# https://miykael.github.io/nipype/interfaces/generated/interfaces.ants/registration.html

# antsRegistration \
# --collapse-output-transforms 0 \
# --dimensionality 3 \
# --initialize-transforms-per-stage 0 \
# --interpolation Linear \
# --output [ mni152linear_, template0_mni152linear.nii.gz ] \
# --transform Affine[ 2.0 ] \
# --metric Mattes[ ${fixed_nii}, ${moving_nii}, 1, 32, Random, 0.05 ] \
# --convergence [ 1500x200, 1e-08, 20 ] \
# --smoothing-sigmas 1.0x0.0vox \
# --shrink-factors 2x1 \
# --use-estimate-learning-rate-once 1 \
# --use-histogram-matching 1 \
# --transform SyN[ 0.25, 3.0, 0.0 ] \
# --metric Mattes[ ${fixed_nii}, ${moving_nii}, 1, 32 ] --convergence [ 100x50x30, 1e-09, 20 ] \
# --smoothing-sigmas 2.0x1.0x0.0vox \
# --shrink-factors 3x2x1 \
# --use-estimate-learning-rate-once 1 \
# --use-histogram-matching 1 \
# --winsorize-image-intensities [ 0.0, 1.0 ]

# this is our lab version
antsRegistration \
--dimensionality 3 \
--float 0 \
--output [ ${out_prefix}, ${out_nii}] \
--interpolation Linear \
--winsorize-image-intensities [0.005,0.995] \
--use-histogram-matching 0 \
--initial-moving-transform [${fixed_nii},${moving_nii},1] \
--transform Rigid[0.1] \
--metric MI[${fixed_nii},${moving_nii},1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[${fixed_nii},${moving_nii},1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric CC[${fixed_nii},${moving_nii},1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox
