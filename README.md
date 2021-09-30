# RGB_models
This repository contains the ImageJ macro and R scripts to build, validate and use the PDM (Plastics Detection Model) and the PIM (Polymer Identification Model) for the fast and accurate analysis of microplastics. 

--Particle Fluorescence Extractor (PFE)--

This repository contains files needed to construct two easily interpretable, supervised machine learning models for microplastics analysis: the PDM (Plastics Detection Model) and the PIM (Polymer Identification Model). The PDM allows to accurately distinguish plastic from natural particles while the PIM accurately identifies the polymer types (Nylon, PE, PET, PP, PS, PVC and PUR) microplastics belong to. The predictive modelling tools are based on the extraction of RGB-derived statistics from images of fluorescent Nile Red-dyed particles, under UV, blue and green filters, taken with a fluorescence microscope. The RGB-data extracted from image analysis is used to build the two classification models through recursive binary splitting using simple decision rules, inferred from emission spectra features.
File 1: ‘Particle Fluorescence Extractor’ contains a macro for the image processing program ImageJ Fiji and allows to extract the RGB values of pixels laying along the maximum Feret diameter of fluorescently labeled particles photographed against a black background, the 3 other files (File 2: ‘Construction RGB-dataset’, File 3: ‘Measurements’ and File 4: ‘Classification models’) contain R codes needed to construct the dataset to train and validate the RGB data-based-models before use. Run the scripts in the order as presented below:

File 1: Particle Fluorescence Extractor

SOFTWARE: ImageJ

INPUT: Particle images (‘Material’ +_+ ImageNumber +_+Filter(B,G,UV))

OUTPUT: - .csv-files containing RGB-data of particles photographed under the B,G and UV filter.
	      - .tif file of each image with all particles outlined and numbered.
        - .xlsx-file containing detailed particle information on the outlined particles in the .tif file.

Make sure that image files are named as followed before running the macro in ImageJ: 
When using known reference materials: ‘Material’ +_+ ImageNumber +_+Filter(B,G,UV) e.g.: PET_3_G (image #3 of PET, taken under the green filter)
In case of unknown particles, for identification reasons: use ‘unknown’ under ‘Material’, e.g.:  Unknown_3_G.

Images should be ordered in 3 folders based on the filter used: a folder ‘Blue’, ‘Green’ and ‘UV’.

When running the macro, first select the input directory where your images are stored, followed by the output directory, where you want your .csv-files containing the extracted RGB-values to be saved. Create 3 folders in your output directory based on the filter used: a folder ‘Blue’, ‘Green’ and ‘UV’*, as is the case in the input folder.
Make sure the .csv-files are saved in their corresponding folders.

Next, it is advised to choose ‘Set scale manually’ under ‘Help with scaling (interactive)’, ‘NONE’ under ‘Smoothing filter’ and ‘Manual (interactive)’ under ‘Tresholding mode’. Fill out the minimum max. Feret diameter that you want to consider for particle selection. Don’t forget to set the scale unit (µm). 

The macro will automatically select all particles present after manual/automatic thresholding of the image, and for each particle larger than the set minimum (max. Feret diameter), the macro automatically saves a .csv file containing all RGB-values of the pixels laying along its max. Feret diameter. Particles are automatically numbered and .csv-files will automatically be named as followed: ‘Material’+ImageNumber+_+’Filter(B,G,UV)+_+p+’ParticleNumber’ (e.g.: 
PET_3_G_p5 (image 3 of PET, particle 5, taken under the green filter).

Next to the .csv files, the macro will also save a .xlsx-file containing specific measurements (area, circularity, Feret, FeretX, FeretY, FeretAngle, minFeret, aspect ratio, round, solidity) of ALL selected particles (also the ones smaller than specified under ‘max. Feret diameter’).

File 2: Construction RGB-dataset

SOFTWARE: R

INPUT: .csv-files exported from ImageJ: 3 different inputs are required (1 per filter folder (B,G,UV)* (output from file 1).

OUTPUT: a .xlsx-file containing a dataset with RGB-statistics of all particles photographed under the B,G and UV filter.

Make sure .csv-files are correctly named in the previous step (‘Material’+ImageNumber+_+’Filter(B,G,UV)+_+p+’particlenumber’), and saved in the correct folder (B, G, UV).

First, start by setting the working directory to the ‘Blue folder’. Do the same for the other two folders further on in the R script as indicated. Next, Chose ant output directory where your RGB-dataset will be stored.  

When the script is run, a .xlsx-file called ‘Date+_dataset_RGB_statistics.xlsx’ will be created, e.g. ‘29_09_2021_dataset_RGB_statistics’.

File 3: Measurements

SOFWARE: R

INPUT: .xlsx-file containing detailed particle information on the outlined particles in the .tif file (output ImageJ, measurements file) (output from file 1).

OUTPUT: .xlsx-file containing detailed particle information on the outlined particles in the .tif file with associated particle IDs of all particles larger than the specified minimum max. Feret diameter. 

When running this code, a copy of the original .csv-file will be created as a .xlsx-file, with the same particle information, but  with an added column containing the particle IDs of only the particles larger than the set minimum max. Feret diameter, for which .csv-files with RGB values were extracted. In this way the exported .csv files and associated particle IDs in the RGB-statistics dataset can easily be linked to the different particles in the respective photograph (outlined and numbered in the .tif file), through the measurements file. 

File 4: Classification models

SOFTWARE: R

INPUT:  .xlsx-file containing a dataset with RGB-statistics of all particles photographed under the B,G and UV filter. (output from file 2).

OUTPUT: - Plastic Detection Model (PDM) that allows to distinguish microplastics from nature-based particles. This model can be used during further analyses, and can be plotted.
        - Polymer Identification Model (PIM) that allows to identify the polymer types     microplastics belong to. This model can be used during further analyses, and can be plotted.
        - Confusion matrices that allow to assess model performance of both models. 
        - Once trained and validated, these models can be used to predict the identity of unidentified photographed particles (plastic/non-plastic, and if plastic: which   polymer type).

The code in File 4 ‘Classification models’ is meant to build and train your own classification trees, validate them, and use them to identify unknown particles. If you wish to use the already existing train and validation datasets, you can find them here:

https://doi.org/10.14284/511
https://doi.org/10.14284/512

To use the R code in File 4 on these datasets, make sure to first copy all rows under the 'validation_data'-sheet UNDERNEATH the rows of the 'training_data'-sheet, so that both training and validation data is present in sheet 1.

