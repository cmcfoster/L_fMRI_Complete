packages <- c("pTFCE", "oro.nifti", "glue", "dplyr", "stringr")
xfun::pkg_attach2(packages, message = F)

base_dir <- "/Volumes/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI"

mask_file <- glue("{base_dir}/GroupTemplate/GroupTemplate_WB_mask_no_hole.nii")
mask <- readNIfTI(mask_file, reorient = F)

task <- "dj"

res_file <- glue("{base_dir}/group_analyses/{task}/results_residual.nii.gz")
res <- readNIfTI(res_file, reorient = F)

results_dir <- glue("{base_dir}/group_analyses/{task}/results_3d")
in_files <- list.files(results_dir, "_Z.nii.gz", full.names = T)

# degrees of freedom
# for all effects of dj are 632 except for age_w1_mc, which is 173
# for all effects of nback are 854 except for age_w1_mc, which is 166
# currently, these are hard-coded double
# check actual dof with 3dinfo -verb $results_path 

for (i in 1:length(in_files)) {
  
  if (grepl("age_w1_mc_Z.nii.gz", in_files[i])) {
    dof_value <- 173
  } else {
    dof_value <- 632
  }

  z <- oro.nifti::readNIfTI(in_files[i], reorient = F)
  
  # if two-sided
  pos_t <- sum(as.numeric(z[,,]) > 0) > 0
  neg_t <- sum(as.numeric(z[,,]) < 0) > 0
  
  if (pos_t & neg_t) {
    
    # positive
    out_file <- in_files[i] %>%
      str_replace(., "results_3d", "ptfce") %>%
      str_replace(., ".nii.gz", "_pos.nii.gz")
    z_pos <- z
    z_pos[z_pos[,,] <= 0] <- 0
    if (!file.exists(out_file)) {
      ptfce_results <- ptfce(img = z_pos, mask = mask, residual = res, dof = dof_value)
      writeNIfTI(ptfce_results$Z, out_file)
    }
    
  } else {
    out_file <- in_files[i] %>%
      str_replace(., "results_3d", "ptfce")
    if (!file.exists(out_file)) {
      ptfce_results <- ptfce(z, mask, residual = res_file, dof = dof_value)
      writeNIfTI(ptfce_results$Z, out_file)
    }
  }
  

  
  #orthographic(pTFCE$Z, zlim=c(ptfce_results$fwer0.05.Z, max(ptfce_results$Z)), crosshair=F)
  
}