#!/bin/Rscript --vanilla

# description ----
# script to obtain the cluster-size threshold (in number of voxels) 
# bi-sided (positive and negative are thresholded separately)
# nn = 3 (1 = surface, 2 = edges, and 3 = corners can touch)
# alpha-threshold = 0.05
# p-threshold = 0.001

# how to use ----
# trailing argument of the path to the 3dClustSim output

# load packages ----
packages <- c("stringr", "dplyr", "readr", "tidyr")
xfun::pkg_attach2(packages, message = F)

args <- commandArgs(T)
file <- args[1]

pthr_value <- .001
athr_value <- .05
sided_thr_value <- "bi"
nn_value <- 3

#file <- "/Volumes/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/group_analyses/dj/results_residual_3dClustSim.txt"

df_orig <- readLines(file) %>%
  str_squish()

cmd_idx <- grep("# 3dClustSim", df_orig)
tbl_sep_idx <- grep("# ---", df_orig)
thr_idx <- grep("thresholding", df_orig)
nn_idx <- grep("# -NN", df_orig)
a_thr_idx <- grep("# pthr", df_orig)

thr_val <- df_orig[grep("thresholding", df_orig)] %>%
  unique() %>%
  str_remove(., "# ") %>%
  str_remove(., "-sided thresholding")
 
nn_val <- df_orig[grep("# -NN", df_orig)] %>% 
  unique() %>%
  str_remove(., "# -NN ") %>%
  str_remove(., " \\| alpha = Prob\\(Cluster \\>\\= given size\\)")

col_header <- df_orig[a_thr_idx] %>% 
  unique() %>% 
  str_remove(., "# ") %>% 
  str_remove(., "\\| ") %>% 
  str_split(., " ") %>% 
  unlist()

df <- df_orig
df_list <- list()
for (i in length(tbl_sep_idx):1) {
  thr_temp <- thr_val[str_which(df_orig[thr_idx[i]], thr_val)]
  nn_temp <- nn_val[str_which(df_orig[nn_idx[i]], nn_val)]
  #a_thr_temp <- a_thr_idx[str_which(df_orig[a_thr_idx[i]], a_thr_val)]
  df_temp <- as.data.frame(df[(tbl_sep_idx[i]+1):length(df)])
  colnames(df_temp) <- "X"
  df_temp <- df_temp %>%
    separate(., X, col_header, sep = " ")
  df_list[[thr_temp]][[nn_temp]] <- df_temp
  df <- df[1:(cmd_idx[i]-1)]
  #print(df_temp)
}

df_long <- as_tibble(df_list) %>%
  mutate(nn = row_number()) %>% 
  pivot_longer(., -nn, names_to = "sided_thresholding", values_to = "data") %>% 
  unnest(cols = c(data)) %>%
  pivot_longer(., -c(nn, sided_thresholding, pthr), names_to = "alpha", values_to = "n_voxel") %>%
  mutate(pthr = as.numeric(pthr),
         alpha = as.numeric(alpha)) %>%
  select(sided_thresholding, nn, alpha, pthr, n_voxel) %>%
  arrange(sided_thresholding, nn, alpha, pthr)

n_vox <- df_long %>%
  filter(sided_thresholding == sided_thr_value,
         nn == nn_value,
         alpha == athr_value,
         pthr == pthr_value) %>%
  select(n_voxel) %>%
  as.numeric() %>%
  round()
# 
# # find the last bi-sided
# last_bisided_idx <- grep("bi-sided thresholding", df_orig) %>% .[3]
# 
# # create table
# df <- df_orig[(last_bisided_idx + 7):length(df_orig)] %>%
#   str_split(., " ") %>% 
#   as.data.frame() %>%
#   t() %>%
#   apply(., 2, as.numeric)
# colnames(df) <- df_orig[(last_bisided_idx + 5)] %>% 
#   str_split(., " ") %>% 
#   unlist() %>%
#   str_subset(., "#", T) %>%
#   str_subset(., "\\|", T)
# rownames(df) <- NULL
# 
# df <- df %>%
#   as_tibble() %>%
#   pivot_longer(-pthr, names_to = "athr", values_to = "n_voxels") %>%
#   mutate(athr = as.numeric(athr))
# 
# # filter to obtain cluster threshold
# n_vox <- df %>%
#   filter(pthr == pthr_value,
#          athr == athr_value) %>%
#   select(n_voxels) %>%
#   as.numeric() %>%
#   ceiling()

cat(n_vox, "\n")
