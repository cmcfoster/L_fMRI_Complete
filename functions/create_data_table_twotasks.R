# load packages ----
packages <- c("glue", "tidyverse", "readxl", "lubridate")
xfun::pkg_attach2(packages)

base_dir <- "/Volumes/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/data"

# create nifti files table ----
subj_list <- list.files(base_dir, "3tb")

files_dj <- paste0("/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/data", "/", subj_list, "/first_level_dj/con_000") %>%
  rep(., each = 3) %>%
  paste0(., c(2:4), ".nii")

files_nback <- paste0("/raid/data/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/data", "/", subj_list, "/first_level_dj/con_000") %>%
  rep(., each = 4) %>%
  paste0(., c(1:4), ".nii")

files = c(files_dj, files_nback)

df_nii <- tibble(id = NA,
                 file = files,
                 contrast = NA) %>%
  mutate(mri_id_start = str_locate(files, "3tb") %>% .[[1]],
         mri_id = str_sub(file, mri_id_start, (mri_id_start + 6)),
         id = str_sub(file, (mri_id_start + 8), (mri_id_start + 11)) %>% as.numeric(),
         contrast = case_when(
           # dj 
           str_detect(file, "con_0002") ~ -1,
           str_detect(file, "con_0003") ~ 0,
           str_detect(file, "con_0004") ~ 1,
         )) %>%
  select(id, mri_id, contrast, file) %>%
  arrange(id, file)

unique_id <- df_nii$id %>% unique()
unique_mri_id <- subj_list %>% str_split(., "_") %>% map(., 1) %>% unlist() %>% unique() %>% sort()

# create age lag table ----
df_age_lag_orig <- read_csv("/Volumes/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/LongitudinalDemographics.csv")
df_age_lag <- df_age_lag_orig %>%
  select(id = CogID, wave = Wave, mri_id = MRI_ID, age_w1 = DJAgeW1, lag_years = Lag, Excluded_from_all, excluded.from.dj) %>%
  filter(!is.na(age_w1),
         Excluded_from_all == 0,
         excluded.from.dj == 0,
         id %in% unique_id,
         mri_id %in% unique_mri_id)
    
# combine tables ----
df_data <- inner_join(df_age_lag, df_nii, by = c("id", "mri_id")) #%>%

# remove files that do not exist ----
missing_idx <- NULL
for (i in 1:nrow(df_data)) {
  file_check <- df_data[i, "file"] %>% unlist() %>% as.character() %>% str_replace(., "/raid/data/", "/Volumes/")
  if (!file.exists(file_check)) {
    print(c(i, df_data[i, "file"]))
    missing_idx <- c(missing_idx, i)
  }
}
if (!is.null(missing_idx)) {
  df_data_clean <- df_data[-missing_idx, ]
} else {
  df_data_clean <- df_data
}

# remove only w2 subjects ----
df_w2_only_subj <- df_data_clean %>% 
  select(id, wave) %>%
  unique() %>%
  group_by(id) %>%
  nest()
w2_only_subj <- NULL
for (i in 1:nrow(df_w2_only_subj)) {
  if (nrow(df_w2_only_subj$data[[i]]) == 1 & df_w2_only_subj$data[[i]]$wave[1] == 2) {
    w2_only_subj <- c(w2_only_subj, df_w2_only_subj$id[[i]])
  }
}
if (!is.null(w2_only_subj)) {
  cat("W2 only subjects:", w2_only_subj, "\n")
  df_data_clean <- df_data_clean %>%
    filter(!(id %in% w2_only_subj))
}

m_age_w1 <- df_data_clean %>%
  filter(wave == 1) %>%
  select(id, wave, age_w1) %>%
  unique() %>%
  select(age_w1) %>%
  unlist() %>%
  as.numeric() %>%
  mean()

# manipulate data ----
df_data_clean <- df_data_clean %>%
  mutate(age_w1_mc = age_w1 - m_age_w1,
         contrast_x_age_w1_mc = contrast * age_w1_mc,
         contrast_x_lag_years = contrast * lag_years,
         age_w1_mc_x_lag_years = age_w1_mc * lag_years,
         contrast_x_age_w1_mc_x_lag_years = contrast * age_w1_mc * lag_years) %>%
  select(Subj = id, contrast, age_w1_mc, lag_years, contrast_x_age_w1_mc, 
         contrast_x_lag_years, age_w1_mc_x_lag_years, 
         contrast_x_age_w1_mc_x_lag_years, InputFile = file) %>%
  mutate("\\" = "\\") %>%
  arrange(Subj)
df_data_clean[nrow(df_data_clean), "\\"] <- ""

# print summary
n_total_subj <- df_data_clean$Subj %>% unique() %>% length()
n_total_subj_long <- df_data_clean %>% filter(lag_years > 0) %>% select(Subj) %>% unique() %>% nrow()
print(c("total" = n_total_subj, "longitudinal_total" = n_total_subj_long))

# save table ----
write_tsv(df_data_clean, "/Volumes/shared/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/group_analyses/dj/in_data_table.txt")  
