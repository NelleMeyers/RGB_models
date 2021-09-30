library("readxl")
library("openxlsx")
library("writexl")
library("xlsx")
library("fs")
library("stringr")
library("R.utils")
library("zoo")
library("filenamer")
library("dplyr")

#Choose directory where you want the reworked measurements to be saved.
Export <-setwd("Directory where measurement files are imported and saved again")
files<-list.files(path = ".", pattern=".csv")
Minimum_max_Feret_diameter = 50
count = 0
for (f in files) {
  dat <-read.csv(file = f, header = TRUE) 
  dfdata<-data.frame(dat)
  Particle_column<-rep("/",times=nrow(dfdata))
  Particle_df<-data.frame(Particle_column)
  Overall_dataset<- cbind(Particle_df,dfdata)
  fnstring<-(as.character(as.filename(f)))
  Full_ID<-(substr(fnstring,1,nchar(fnstring)-4))
  Filename<- paste(substr(fnstring,1,nchar(fnstring)-4), ".xlsx",sep= "")
            for (i in 1:nrow(Overall_dataset)){
              if (Overall_dataset[i,5] > Minimum_max_Feret_diameter){
                count = count + 1
                Overall_dataset[i,1]= paste(Full_ID,"_p",count, sep="")
              }
            }
  Exportdirectory=paste(Export,"/",Filename,sep="")
  write.xlsx(Overall_dataset,Exportdirectory,sheetName="Sheet1")
  count = 0
}


  