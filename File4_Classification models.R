library(rpart)
library(rattle)
library(caret)
library(readxl)
library(xlsx)
library(filenamer)

#This code is meant to build and train your own classification trees, validate them, and use them to identify unknown particles.
#If you wish to use already existing train and validation datasets, find them in the link in the README-file. 
#To use the coding below on those datasets, make sure to copy all rows under the 'validation_data'-sheet UNDERNEATH the rows of the 'training_data'-sheet,
#so that both training and validation data is present in sheet 1. 

RGB_dataset <- read_excel("Paste_the_location_of_your_RGB_dataset_here.xlsx")

#Function to subdivide your dataset  in a training dataset (80%) and a validation dataset (20%).
create_train_validate <- function(Overall_dataset, size = 0.8, train = TRUE) {
  n_row = nrow(Overall_dataset)
  total_row = size * n_row
  train_sample <- 1: total_row
  if (train == TRUE) {
    return (Overall_dataset[train_sample, ])
  } else {
    return (Overall_dataset[-train_sample, ])
  }
}

traindata<-create_train_validate(RGB_dataset,size = 0.8, train = TRUE)
validationdata<-create_train_validate(RGB_dataset,size = 0.8, train = FALSE)

#Function to train your PDM or PIM model. Depending on the model created, be sure to
#adjust 'minsplit' (minimum amount of records that must exist in a node in order for a split to be attempted),
#adjust 'minbucket' (minimum amount of records that end up in an end node),
#and adjust 'cp' (minimum model fit improvement required for splits not to be discarded).

PDM_creation <- function(Overall_dataset) {
  RGB_train_data<-create_train_test(Overall_dataset, size = 0.8, train=TRUE)
  PDM_model <- rpart(Material ~ .,
                     data = RGB_train_data, method = "class",
                     control =rpart.control(minsplit=8,minbucket=3, cp=0,02))
  return(PDM_model)
}

PIM_creation <- function(Overall_dataset) {
  RGB_train_data<-create_train_test(Overall_dataset, size = 0.8, train=TRUE)
  PIM_model <- rpart(Material ~ .,
                     data = RGB_train_data, method = "class",
                     control =rpart.control(minsplit=39,minbucket=13, cp=0,02))
  return(PIM_model)
}

PDM_creation(RGB_dataset)
PIM_creation(RGB_dataset)

#Function to visualise your PDM or PIM model
PDM_visualisation <-function(Overall_dataset){
  PDM_model_plotted <- fancyRpartPlot(PDM_creation(Overall_dataset), caption = NULL)
  return(PDM_model_plotted)
}


PIM_visualisation <-function(Overall_dataset){
  PIM_model_plotted <- fancyRpartPlot(PIM_creation(Overall_dataset), caption = NULL)
  return(PIM_model_plotted)
}

PDM_visualisation(RGB_dataset)
PIM_visualisation(RGB_dataset)

#Function to validate your PDM or PIM model using your validation datasets.
PDM_validation<-function(Overall_dataset){
  RGB_validation_data<-create_train_test(Overall_dataset, size = 0.8, train=FALSE)
  PDM_RGB_model<-PDM_creation(Overall_dataset)
  predict_unknown<-predict(PDM_RGB_model, RGB_validation_data, type="class")
  A <-as.factor(predict(PDM_RGB_model, RGB_validation_data, type="class"))
  B <-as.factor(RGB_validation_data$Material)
  CM <- confusionMatrix(data = A, reference = B)
  return(CM)
}

PIM_validation<-function(Overall_dataset){
  RGB_validation_data<-create_train_test(Overall_dataset, size = 0.8, train=FALSE)
  PIM_RGB_model<-PIM_creation(Overall_dataset)
  predict_unknown<-predict(PIM_RGB_model, RGB_validation_data, type="class")
  A <-as.factor(predict(PIM_RGB_model, RGB_validation_data, type="class"))
  B <-as.factor(RGB_validation_data$material)
  CM <- confusionMatrix(data = A, reference = B)
  return(CM)
}

PDM_validation(RGB_dataset)
PIM_validation(RGB_dataset)

#Function to predict the plastic/non-plastic origin of particles using the constructed Plastics Detection Model (PDM),
#and function to predict the polymer type microplastic particles belong to, using the constructed Polymer Identification Model (PIM).

Inport<-setwd("Location_of_RGB-datasets_with_unknown_particles_which_are_to_be_identified")
Export <-setwd("Location_where_particle_prediction_xlsx-file_should_be_stored")

PDM_prediction<-function(Overall_dataset){  
  files<-list.files(path = "Path_where_your_RGB_datasets_of_unknown_particles_are_stored", pattern=".xlsx")
  for (f in files) {
    read.xlsx(xlsxFile = f, sheet = 1)
    fnstring<-(as.character(as.filename(f)))
    Filename<- paste(substr(fnstring,1,nchar(fnstring)-5),"_Predicted_IDs",".xlsx",sep= "")
    Exportdirectory=paste(Export,"/",Filename,sep="")
    traindataset<-create_train_test(RGB_dataset, size = 0.8, train=TRUE)
    model<-PDM_creation(traindataset)
    Predicted_particle_IDs=c("Particle_ID","Predicted_origin")
    for (i in 1:nrow(f)){
      subdataset<-f[2:37]
      predicted_ID<-predict(model,subdataset[i,],type='class')
      newrow=c(subdataset[i,1],predicted_ID)
      Predicted_particle_IDs<-rbind(Predicted_particle_IDs,newrow)
      write.xlsx(Predicted_particle_IDs,file = Exportdirectory,sheetName="Sheet1",row.names = FALSE)
    }
  }
}

PIM_prediction<-function(Overall_dataset){  
  files<-list.files(path = "Path_where_your_RGB_datasets_of_unknown_particles_are_stored", pattern=".xlsx")
  for (f in files) {
    read.xlsx(xlsxFile = f, sheet = 1)
    fnstring<-(as.character(as.filename(f)))
    Filename<- paste(substr(fnstring,1,nchar(fnstring)-5),"_Predicted_IDs",".xlsx",sep= "")
    Exportdirectory=paste(Export,"/",Filename,sep="")
    traindataset<-create_train_test(RGB_dataset, size = 0.8, train=TRUE)
    model<-PIM_creation(traindataset)
    Predicted_particle_IDs=c("Particle_ID","Predicted_origin")
    for (i in 1:nrow(f)){
      subdataset<-f[2:37]
      predicted_ID<-predict(model,subdataset[i,],type='class')
      newrow=c(subdataset[i,1],predicted_ID)
      Predicted_particle_IDs<-rbind(Predicted_particle_IDs,newrow)
      write.xlsx(Predicted_particle_IDs,file = Exportdirectory,sheetName="Sheet1",row.names = FALSE)
    }
  }
}

PDM_prediction(RGB_dataset)
PIM_prediction(RGB_dataset)

