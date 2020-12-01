#!/bin/tcsh

# script to split file
# trailing argument of path of afni results file to split

# tcsh /raid/data/shared/software/scripts/fmri/Longitudinal_fMRI/functions/split_group_results.sh

# load modules ----
module load afni

# script -----
set in_file = $1
set out_file_prefix = `echo $in_file | sed s/.nii.gz//g`

@ n_vol = `3dnvals ${in_file}`
set vol_list = `3dinfo -verb ${in_file} | grep "sub-brick" | awk -F "'" '{print $2}' | sed 's/ /_/g' | sed 's/(//g' | sed 's/)//g' | sed 's/:/_x_/g'`

set vol_start = 0
set vol_end = `echo $n_vol-1 | bc`

foreach i ( `count -dig 3 0 $vol_end` )
  set j = `echo $i+1 | bc`
  3dbucket -prefix ${out_file_prefix}_${i}_${vol_list[${j}]}.nii.gz ${in_file}"[$i]"
end
