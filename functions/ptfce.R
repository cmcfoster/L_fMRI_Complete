packages <- c("pTFCE", "oro.nifti", "glue", "dplyr", "stringr", "tictoc")
xfun::pkg_attach2(packages, message = F)

tic()

base_dir <- "/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI"

mask_file <- glue("{base_dir}/GroupTemplate/GroupTemplate_WB_mask_no_hole.nii")
mask <- readNIfTI(mask_file, reorient = F)

task <- "dj"
#res_file <- glue("{base_dir}/group_analyses/{task}/results_residual.nii.gz")
#res <- readNIfTI(res_file, reorient = F)

results_dir <- glue("{base_dir}/group_analyses/{task}/results_3d")
in_files <- list.files(results_dir, "_Z.nii.gz", full.names = T)

# degrees of freedom
# for all effects of dj are 632 except for age_w1_mc, which is 173
# for all effects of nback are 854 except for age_w1_mc, which is 166
# currently, these are hard-coded double
# check actual dof with 3dinfo -verb $results_path

#for (i in 1:length(in_files)) {
i <- 1

if (grepl("age_w1_mc_Z.nii.gz", in_files[i])) {
  dof_value <- 173
} else {
  dof_value <- 632
}

# these were calculated from fsl smoothest, it's having a hard time reading the 4D residual file, but the author of the package says it should be equivalent and FSL smoothest is faster
dlh <- 0.0534414
volume <- 54319
resels <- 86.4579

z <- oro.nifti::readNIfTI(in_files[i], reorient = F)
toc()

# pos
cat('# positive clusters ---- \n')
tic()
out_file <- in_files[i] %>%
  str_replace(., "results_3d", "ptfce") %>%
  str_replace(., ".nii.gz", "_pos.nii.gz")
z_pos <- z
z_pos[z_pos[,,] <= 0] <- 0
if (!file.exists(out_file)) {
  ptfce_results <- ptfce(img = z_pos, mask = mask, Rd = volume*dlh, V = volume, resels = resels) #, residual = res, dof = dof_value)
  writeNIfTI(ptfce_results$Z, str_remove(out_file, ".nii.gz"))

  fwer0.05_2tailed_z <- fwe.p2z(ptfce_results$number_of_resels, 0.05/2)
  ptfce_results$Z_thr <- ptfce_results$Z
  ptfce_results$Z_thr[ptfce_results$Z_thr[,,] <= fwer0.05_2tailed_z] <- 0
  out_file <- out_file %>%
    str_replace(., ".nii.gz", "_thr.nii.gz")
  writeNIfTI(ptfce_results$Z_thr, str_remove(out_file, ".nii.gz"))
} else {
  print("skipping, file already exists")
}
toc()

# neg
cat('# negative clusters ---- \n')
tic()
out_file <- in_files[i] %>%
  str_replace(., "results_3d", "ptfce") %>%
  str_replace(., ".nii.gz", "_neg.nii.gz")
z_neg <- -1*z
z_neg[z_neg[,,] <= 0] <- 0
if (!file.exists(out_file)) {

  ptfce_results <- ptfce(img = z_neg, mask = mask, Rd = volume*dlh, V = volume, resels = resels) # residual = res, dof = dof_value)
  writeNIfTI(ptfce_results$Z, str_remove(out_file, ".nii.gz"))

  fwer0.05_2tailed_z <- fwe.p2z(ptfce_results$number_of_resels, 0.05/2)
  ptfce_results$Z_thr <- ptfce_results$Z
  ptfce_results$Z_thr[ptfce_results$Z_thr[,,] <= fwer0.05_2tailed_z] <- 0
  out_file <- out_file %>%
    str_replace(., ".nii.gz", "_thr.nii.gz")
  writeNIfTI(ptfce_results$Z_thr, str_remove(out_file, ".nii.gz"))
} else {
  print("skipping, file already exists")
}
toc()
