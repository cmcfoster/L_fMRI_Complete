#!/bin/Rscript --vanilla

# add path of the 3dClustSim output to conver the file to long format

# load packages ----
packages <- c("stringr", "dplyr", "readr", "tidyr")
xfun::pkg_attach2(packages, message = F)

args <- commandArgs(T)
#file <- args[1]
file <- "/Volumes/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/group_analyses/dj/results_residual_3dClustSim.txt"
df_orig <- readLines(file) %>%
  str_squish()

df <- df_orig %>%
  str_squish() %>%
  str_subset(., "#", T) %>%
  str_split(., " ") %>%
  as.data.frame() %>%
  t() %>%
  as.data.frame()

column_names <- grep("# pthr", df_orig) %>% 
  .[1] %>% 
  df_orig[.] %>% 
  str_split(., " ") %>% 
  unlist() %>% 
  str_subset(., "#", T) %>% 
  str_subset(., "\\|", T)

rownames(df) <- NULL
colnames(df) <- column_names

df <- df %>%
  mutate(sided = rep(c("1", "2", "bi"), each = (nrow(df)/3))) %>%
  group_by(sided) %>%
  mutate(nn = rep(1:3, each = nrow(.)/9)) %>%
  ungroup() 

df_long <- df %>%
  pivot_longer(-c(sided, nn, pthr), names_to = "athr", values_to = "voxthr") %>%
  mutate(pthr = as.numeric(pthr),
         athr = as.numeric(athr),
         voxthr = as.numeric(voxthr)) %>%
  arrange(sided, nn, desc(pthr), desc(athr)) %>%
  select(sided, nn, pthr, athr, voxthr)

out_file <- file %>% str_replace(., ".txt", "_long.txt")
write_csv(df_long, out_file)
