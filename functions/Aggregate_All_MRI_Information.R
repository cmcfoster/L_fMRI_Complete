# attempt to automate aggregation
# files needed: Wave1 MRI Tracking/Cog Wave2 MRI Tracking/Cog
 # import hand crafted data
library(openxlsx)

# set base path
#bp <- 'W:/'
bp <- '/Volumes/shared'

mridata <- read.csv(paste0(bp,'/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/all_subj_data.csv'), stringsAsFactors = F)
w1 <- mridata[mridata$Wave == 1,]
w2 <- mridata[mridata$Wave == 2,]

w1cog <- read.xlsx(paste0(bp,'/KK_KR_JLBS/Wave1/Demographic_and_Task_Data/Cog_Data_W1.xlsx'))
w1cog <- w1cog[,c('ID','SEX','AGE','ED_YEARS','CESD','MMSE')]
w1cog <- w1cog[!(is.na(w1cog$ID)),]
names(w1cog) <- c('CogID','SEX','CogAGE','ED_Years','CESD','MMSE')

w2cog <- read.xlsx(paste0(bp,'/KK_KR_JLBS/Wave2/Demographic_and_Task_Data/Cog_Data_W2.xlsx'))
w2cog <- w2cog[,c('ID','SEX','AGE_W2','ED_Years_W2','CESD_W2','MMSE_W2')]
w2cog <- w2cog[!(is.na(w2cog$ID)),]
names(w2cog) <- c('CogID','SEX','CogAGE','ED_Years','CESD','MMSE')


w1full <- merge(w1,w1cog,by = 'CogID')
# check if age from cog and age from mridata are the same
w1full$Age == w1full$CogAGE

w2full <- merge(w2,w2cog,by = 'CogID')
w2full$Age == w2full$CogAGE

# some ages are wrong, not sure why.
# import birthdays
w1birthdays <- read.csv(paste0(bp,'/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/tmp_birthdayW1.csv'), stringsAsFactors = F)
names(w1birthdays) <- c('CogID','BDay')
w2birthdays <- read.csv(paste0(bp,'/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/StudyTrackingMain.csv'), stringsAsFactors = F)
names(w2birthdays) <- c('CogID','BDay')

w1full2 <- merge(w1full,w1birthdays,by = 'CogID', all = T)
# This code is needed to convert to 2000 yr vs 0000 yr
# %>% format("20%y%m%d") %>% as.Date("%Y%m%d")
w1full2$DJ_ScanDate2 <- as.Date(w1full2$DJ_ScanDate,format="%m/%d/%Y") %>% format("20%y%m%d") %>% as.Date("%Y%m%d")
w1full2$Nback_ScanDate2 <- as.Date(w1full2$Nback_ScanDate,format="%m/%d/%Y") %>% format("20%y%m%d") %>% as.Date("%Y%m%d")
w1full2$Bday2 <- as.Date(w1full2$BDay,format = "%m/%d/%Y")

library(lubridate)
w1full2$DJAgeAtScan <- floor(as.numeric(as.period(interval(w1full2$Bday2,w1full2$DJ_ScanDate2)),'years'))
w1full2$NbackAgeAtScan <- floor(as.numeric(as.period(interval(w1full2$Bday2,w1full2$Nback_ScanDate2)),'years'))

w2full2 <- merge(w2full,w1birthdays,by = 'CogID', all = T)
w2full2 <- w2full2[!is.na(w2full2$Wave),]
w2full2$DJ_ScanDate2 <- as.Date(w2full2$DJ_ScanDate,format="%m/%d/%Y") %>% format("20%y%m%d") %>% as.Date("%Y%m%d")
w2full2$Nback_ScanDate2 <- as.Date(w2full2$Nback_ScanDate,format="%m/%d/%Y") %>% format("20%y%m%d") %>% as.Date("%Y%m%d")
w2full2$Bday2 <- as.Date(w2full2$BDay,format = "%m/%d/%Y")

w2full2$DJAgeAtScan <- floor(as.numeric(as.period(interval(w2full2$Bday2,w2full2$DJ_ScanDate2)),'years'))
w2full2$NbackAgeAtScan <- floor(as.numeric(as.period(interval(w2full2$Bday2,w2full2$Nback_ScanDate2)),'years'))

# create lag variable
# loop through W2 and matching W1 row and calculate difference between the two dates
w1full2$Lag <- 0

for(i in 1:nrow(w2full2)){
  tmp <- match(w2full2$CogID[i],w1full2$CogID)
  w2full2$Lag[i] <-  as.numeric(as.period(interval(w1full2$Nback_ScanDate2[tmp],w2full2$Nback_ScanDate2[i])),'years')
}

for ( i in 1:nrow(w2full2)){
  if (w2full2$CogID[i] >= 7000){
    w2full2$Lag[i] = 0
  }
}

# create age at wave1 variables
w1full2$NbackAgeW1 <- w1full2$NbackAgeAtScan
w1full2$DJAgeW1 <- w1full2$DJAgeAtScan
for(i in 1:nrow(w2full2)){
  tmp <- match(w2full2$CogID[i],w1full2$CogID)
  w2full2$NbackAgeW1[i] <-  w1full2$NbackAgeW1[tmp]
  w2full2$DJAgeW1[i] <-  w1full2$DJAgeW1[tmp]
}


df <- rbind(w1full2,w2full2)
df <- df[,!(names(df) %in% c('BDay','Bday2'))]
df$DJ_ScanDate2 <- NULL
df$Nback_ScanDate2 <- NULL

#remove original Age and Sex variables for redundancy
df <- subset(df, select = -c(Age, Sex))

write.csv(df, file = paste0(bp,'/KK_KR_JLBS/Longitudinal_Data/W1_W2/MRI/FMRI/LongitudinalDemographics.csv'),row.names = F)

          