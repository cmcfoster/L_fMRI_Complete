#!/bin/Rscript --vanilla

# load packages ----
packages <- c("glue", "rmarkdown", "dplyr", "stringr")
xfun::pkg_attach2(packages, message = F)

# render report ----
template_file <- "/Volumes/shared/software/scripts/fmri/Longitudinal_fMRI/functions/cluster_group_analyses_report.Rmd"
base_dir <-  "/Volumes/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/"


# for each task
task_list <- c("dj", "nback")
for (i in 1:length(task_list)) {
  # set paramters ----
  out_dir <- glue("{base_dir}/group_analyses/{task_list[i]}")
  
  # obtain list of beta names ----
  beta_list <- list.files(out_dir, "betas") %>%
    str_remove(., "_masked_betas.csv") %>%
    str_remove(., "results_")
  
  # for each significant effect
    for (j in 1:length(beta_list)) {
      cat("\ntask: ", task_list[i],
          "\neffect: ", beta_list[j],
          "\n")
      
      out_file <- glue("results_{beta_list[j]}_cluster_analyses.html")
      
      if (file.exists(glue("{out_dir}/{out_file}"))) {
        msg <- glue("Skipping, {out_dir}/{out_file} already exists.")
        next(msg)
      }
      
      render(
        input = template_file,
        output_file = out_file,
        output_dir = out_dir,
        params = list(task = task_list[i],
                      results_name = beta_list[j])
      )
    }
}