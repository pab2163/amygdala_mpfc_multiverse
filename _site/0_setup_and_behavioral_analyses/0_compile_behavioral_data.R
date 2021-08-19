# This scripts goes through the individual subject behavioral txt files (headers removed), pulls them into one big master data frame
# PAB
# February 2018

require(plyr)
require(dplyr)
require(ggplot2)


# Set paths for each of the 3 waves
path_wave1 = 'scan1noHeader/'
path_wave2 = 'fu1noHeader/'
path_wave3 = 'fu2noHeader/'

# Make a list of all the files for each wave
files_wave1 = dir(path_wave1, pattern = '.txt')
files_wave2 = dir(path_wave2, pattern = '.txt')
files_wave3 = dir(path_wave3, pattern = '.txt')


# Initalize data frame using the first file in the list, then delete that file from the list so it won't duplicate
wave1 <- read.table(paste0(path_wave1, files_wave1[1]), sep = '\t',header = T, fill = T)
wave2 <- read.table(paste0(path_wave2, files_wave2[1]), sep = '\t',header = T, fill = T)
wave3 <- read.table(paste0(path_wave3, files_wave3[1]), sep = '\t',header = T, fill = T)
files_wave1 <- files_wave1[-1]
files_wave2 <- files_wave2[-1]
files_wave3 <- files_wave3[-1]


# For all of the files in the list
for (ii in files_wave1){
  newData <- read.table(paste0(path_wave1,ii), sep = '\t',header = T, fill = T)
  wave1 <- rbind.fill(wave1, newData)
}

for (ii in files_wave2){
  newData <- read.table(paste0(path_wave2,ii), sep = '\t',header = T, fill = T)
  wave2 <- rbind.fill(wave2, newData)
}

for (ii in files_wave3){
  newData <- read.table(paste0(path_wave3,ii), sep = '\t',header = T, fill = T)
  wave3 <- rbind.fill(wave3, newData)
}

wave1$wave <- 1
wave2$wave <- 2
wave3$wave <- 3


# Filter Out Bad Subjects Based On Experimenter Notes ---------------------

# Wave 1
# Subject 54 not on task (no hits), Subject 134 no responses, Subject 154 no responses, Subject 271 no responses
# Subject 233 not really on task, only pressed button 3 times
# Subject 316 not really on task, only pressed button 3 times
# Subject 325 doesn't have a run at all
# Subject 19 for only a partial run (12 trials)
wave1 <- filter(wave1, Subject != 54, Subject != 134, Subject != 154, Subject != 271, 
                Subject != 233, Subject != 316, Subject != 19,
                Subject != 279, Subject != 280, Subject !=83, 
                Subject != 325)

# Wave 2
# Subjects 217 and 218 no button presses recorded
# Subject 170 not really on task, only pressed button 3 times
# Subject 276 off task and just pressing for everything 
wave2 <- filter(wave2, Subject != 217, Subject != 218, Subject != 170, Subject != 276)



# Wave 3
# Button box not working for subjects 71, 162
wave3 <- filter(wave3, Subject != 71, Subject != 162)


## Bind all waves together to make master data frame
master <- rbind.fill(wave1, wave2)
master <- rbind.fill(master, wave3)


# Join Ages ---------------------------------------------------------------

ages <- read.csv('ages.csv', stringsAsFactors = F)

master <- left_join(master, ages)


## Refactor PI/Comp/Foster/Adult

master$group <- recode(master$Group..0.control..1.PI., '1' = 'PI', '0' = 'Comp', '3' = 'Foster', '4' = 'Adult')
master$group[is.na(master$group)] <- 'Adult'

# Based on which wave the scan was, grab from that column to the 'age' column to get one column that shows all ages
master$Age[master$wave ==1] <- master$Age_wave1_scan1[master$wave ==1]
master$Age[master$wave ==2] <- master$Age_wave2_FU1[master$wave ==2]
master$Age[master$wave ==3] <- master$Age_wave3_FU2[master$wave ==3]

# Code responses a bit better
master$face.RESP <- as.numeric(master$face.RESP) # as numeric
master$face.RESP[is.na(master$face.RESP)] <- 0 # make na responses into 0s
master$face.RESP[master$face.RESP > 0] <- 1 # all responses greater than 0 as 1s
master$cresp[is.na(master$cresp)] <- 0 # for the cresp category, make na's 0s


# Code by trial result (hit, correct rejection, miss, false alarm)
master$tr_result[master$cresp == 1 & master$face.RESP ==1] <- 'hit'
master$tr_result[master$cresp == 0 & master$face.RESP ==0] <- 'corr_reject'
master$tr_result[master$cresp == 1 & master$face.RESP ==0] <- 'miss'
master$tr_result[master$cresp == 0 & master$face.RESP ==1] <- 'false_alarm'
master$tr_result[master$Procedure.Trial. == 'dummyfixproc' & master$Procedure.Trial. == 'fixproc'] <- NA


# Relable emotion doubles
master$emotion[master$emotion == 'NeutralT_go'] = 'NeutT_go'
table(master$emotion)

# Get rid of non-needed columns
master <- select(master, Subject, wave, group, Age, Sex, cresp, face.RESP, tr_result, emotion, face, face.RT, face.OnsetTime, fix.OnsetTime, DummyFix.OffsetTime, Block, 
                 Procedure.Block., Procedure.Trial., Running.Trial., SubTrial, ExperimentName)

# Master will still have some dummyfix information in it
#masterFearHappy <- filter(master, Procedure.Trial. != 'dummyfixproc' & Procedure.Trial. != 'fixproc', !is.na(face.OnsetTime))
masterFearHappy = master
master <- filter(master, Procedure.Block. == 'BlockProcNeutFear', Subject < 1000)

save(master, masterFearHappy, file = 'master_behav.rda')



