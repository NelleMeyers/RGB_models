#This is an R-script that allows to analyze all .csv-RGB files acquired in ImageJ, and subsequently exports all calculated RGB statistics in a .xlsx-file to a chosen location. 
#Once exported the created .xlSX-file can be used to create a supervised machine learning classification tree model to distinguish plastics from non-plastics (PDM: Plastics Detection Model),
#or to identify the polymer type a plasticd belongs to (PIM: Plastics Identification Model). 
#Before running this code, make sure that the to-be-analyzed .csv files are stored in THREE SEPERATE folders, per filter type.
#.csv files should be named as followed: 'Plastics type'+_'+

library("writexl")
library("xlsx")
library("fs")
library("stringr")
library("R.utils")
library("zoo")
library("filenamer")

#Open directory where all pictures taken under the BLUE filter are stored.
setwd("Directory_with_csv_files_of_pictures_taken_under_blue_filter/B")
#Iterate over all .csv-RGB files in the directory acquired through ImageJ.
files<-list.files(path = ".", pattern=".csv")
Fulldataset_bluefilter<-c("Full_ID","Material","B_R_10","B_R_50","B_R_90","B_R_mean","B_G_10","B_G_50","B_G_90","B_G_mean","B_B_10","B_B_50","B_B_90","B_B_mean")

#Calculate RGB statistics for particles under the BLUE filter.
for (f in files) {
  fn <- as.filename(f)
  fnstring<-(as.character(fn))
  Full_ID<-(substr(fnstring,1,nchar(fnstring)-4))
  File_name<-files[1]
  Particle_type=word(File_name, 1, sep = "_")
  dat <-read.csv(file = f, header = TRUE)
  RED=dat$Red
  GREEN=dat$Green
  BLUE=dat$Blue
  B_R_10<-quantile(RED,probs=0.1)
  B_R_50<-quantile(RED,probs=0.5)
  B_R_90<-quantile(RED,probs=0.9)
  B_R_mean<-mean(RED)
  B_G_10<-quantile(GREEN,probs=0.1)
  B_G_50<-quantile(GREEN,probs=0.5)
  B_G_90<-quantile(GREEN,probs=0.9)
  B_G_mean<-mean(GREEN)
  B_B_10<-quantile(BLUE,probs=0.1)
  B_B_50<-quantile(BLUE,probs=0.5)
  B_B_90<-quantile(BLUE,probs=0.9)
  B_B_mean<-mean(BLUE)
  Statistics_bluefilter<-c(Full_ID,Particle_type,B_R_10,B_R_50,B_R_90,B_R_mean,B_G_10,B_G_50,B_G_90,B_G_mean,B_B_10,B_B_50,B_B_90,B_B_mean)
  Fulldataset_bluefilter <-rbind(Fulldataset_bluefilter, Statistics_bluefilter)
}  

#Open directory where all pictures taken under the GREEN filter are stored.
setwd("Directory_with_csv_files_of_pictures_taken_under_green_filter/G")
#Iterate over all .csv RGB-files in the directory acquired through ImageJ.
files<-list.files(path = ".", pattern=".csv")
Fulldataset_greenfilter<-c("G_R_10","G_R_50","G_R_90","G_R_mean","G_G_10","G_G_50","G_G_90","G_G_mean","G_B_10","G_B_50","G_B_90","G_B_mean")

#Calculate RGB statistics for particles under the GREEN filter.
for (f in files) {
  dat <-read.csv(file = f, header = TRUE)
  RED=dat$Red
  GREEN=dat$Green
  BLUE=dat$Blue
  G_R_10<-quantile(RED,probs=0.1)
  G_R_50<-quantile(RED,probs=0.5)
  G_R_90<-quantile(RED,probs=0.9)
  G_R_mean<-mean(RED)
  G_G_10<-quantile(GREEN,probs=0.1)
  G_G_50<-quantile(GREEN,probs=0.5)
  G_G_90<-quantile(GREEN,probs=0.9)
  G_G_mean<-mean(GREEN)
  G_B_10<-quantile(BLUE,probs=0.1)
  G_B_50<-quantile(BLUE,probs=0.5)
  G_B_90<-quantile(BLUE,probs=0.9)
  G_B_mean<-mean(BLUE)
  Statistics_greenfilter<-c(G_R_10,G_R_50,G_R_90,G_R_mean,G_G_10,G_G_50,G_G_90,G_G_mean,G_B_10,G_B_50,G_B_90,G_B_mean)
  Fulldataset_greenfilter <-rbind(Fulldataset_greenfilter, Statistics_greenfilter)
}  

#Open directory where all pictures taken under the UV filter are stored.
setwd("Directory_with_csv_files_of_pictures_taken_under_UV_filter/UV")
#Iterate over all .csv RGB-files in the directory acquired through ImageJ.
files<-list.files(path = ".", pattern=".csv")
Fulldataset_UVfilter<-c("UV_R_10","UV_R_50","UV_R_90","UV_R_mean","UV_G_10","UV_G_50","UV_G_90","UV_G_mean","UV_B_10","UV_B_50","UV_B_90","UV_B_mean")
#Calculate RGB statistics for particles under the UV filter.
for (f in files) {
  dat <-read.csv(file = f, header = TRUE)
  RED=dat$Red
  GREEN=dat$Green
  BLUE=dat$Blue
  UV_R_10<-quantile(RED,probs=0.1)
  UV_R_50<-quantile(RED,probs=0.5)
  UV_R_90<-quantile(RED,probs=0.9)
  UV_R_mean<-mean(RED)
  UV_G_10<-quantile(GREEN,probs=0.1)
  UV_G_50<-quantile(GREEN,probs=0.5)
  UV_G_90<-quantile(GREEN,probs=0.9)
  UV_G_mean<-mean(GREEN)
  UV_B_10<-quantile(BLUE,probs=0.1)
  UV_B_50<-quantile(BLUE,probs=0.5)
  UV_B_90<-quantile(BLUE,probs=0.9)
  UV_B_mean<-mean(BLUE)
  Statistics_UVfilter<-c(UV_R_10,UV_R_50,UV_R_90,UV_R_mean,UV_G_10,UV_G_50,UV_G_90,UV_G_mean,UV_B_10,UV_B_50,UV_B_90,UV_B_mean)
  Fulldataset_UVfilter <-rbind(Fulldataset_UVfilter, Statistics_UVfilter)
}  

#Combine RGB statistics taken under each of the three filters in one dataframe.
Overall_dataset<- cbind(Fulldataset_bluefilter,Fulldataset_greenfilter,Fulldataset_UVfilter)

#Choose directory where the RGB dataset will be saved.
Export<-setwd("Directory_where_RGB_dataset_should_be_saved")

#Export the overall dataframe containing the RGB statistics as a .xlsx-file to the chosen location.
Date<-Sys.Date()
Exportedfilename<- paste(Date,"_dataset_RGB_statistics.xlsx",sep= "")
Exportdirectory=paste(Export,"/",Exportedfilename,sep="")
write.xlsx(Overall_dataset,Exportdirectory,sheetName="Sheet1",row.names=FALSE,col.names=FALSE)

