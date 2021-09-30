
function parseBoolean(boolstring){ 
    if (boolstring == "true" || boolstring == true || boolstring == "1" || boolstring == 1){
        return(true); 
    } 
    else return(false);
}

dirin = getDirectory("Choose Source Directory with particle images "); 
dirout = getDirectory("Choose Destination Directory to store files with extracted RGB values ");
dirextra = getDirectory("Choose Destination Directory to store all other files");

list = getFileList(dirin);
setBatchMode(true);
for (i = 0; i < list.length; i++){
        action(dirin, dirout, list[i]);
}

setBatchMode(false);


function action(dirin, dirout, filename) {
    open(dirin + filename);
	choose_scale = newArray("NONE", "Set scale manually");
	oScalehelp = call("ij.Prefs.get", "PFE.scalehelp", "Set scale manually");
	oScaleunit = call("ij.Prefs.get", "PFE.scaleUnit", "µm");
	oDarkBG = parseBoolean(call("ij.Prefs.get", "PFE.darkBG", "false"));
	choose_smoothing = newArray("NONE", "Median r = 1 (3x3)", "Median r = 2 (5x5)", "Median r = 3 (7x7)", "Gaussian r = 1", "Gaussian r = 2", "Gaussian r = 3");
	oSmooth = call("ij.Prefs.get", "PFE.smooth", "Median r = 1 (3x3)"); 
	Minimum_Feret_diameter = call("ij.Prefs.set", "dialogDefaults.minParticle", "50");
	choose_thresh  = newArray("Manual (interactive)", "Automatic (ImageJ)");
	oThresh = call("ij.Prefs.get", "PFE.thresh", "Manual (interactive)"); 
	
	Dialog.create("Particle Fluorescence Extractor (PFE)");
	Dialog.addMessage("Designed to extract RGB (Red-Green-Blue) values of pixels laying along the maximum Feret diameter of photographed particles.");
	Dialog.addChoice("Help with scaling (interactive)", choose_scale, oScalehelp);
	Dialog.addString("Scale unit (e.g. µm)", oScaleunit);
	Dialog.addChoice("Smoothing filter", choose_smoothing, oSmooth);
	Dialog.addChoice("Thresholding mode", choose_thresh, oThresh);
	Dialog.addNumber("Choose minimum particle size (max. Feret diameter):", parseInt(Minimum_Feret_diameter));  
	Dialog.show();
	
	oScalehelp  = Dialog.getChoice();   call("ij.Prefs.set", "PFE.scalehelp", oScalehelp);
	oScaleunit  = Dialog.getString;     call("ij.Prefs.set", "PFE.scaleUnit", oScaleunit);
	oSmooth     = Dialog.getChoice();   call("ij.Prefs.set", "PFE.smooth", oSmooth);
	oThresh     = Dialog.getChoice();   call("ij.Prefs.set", "PFE.thresh", oThresh);
	minParticle = Dialog.getNumber();   call("ij.Prefs.set", "dialogDefaults.minParticle", minParticle);
	
	
	run("Appearance...", "  antialiased menu=12");  
	removeScalebar = true;    
	
	imgtitle    = getTitle();
	index = lastIndexOf(imgtitle, ".");
	if (index!=-1) imgtitle = substring(imgtitle, 0, index);  
	titlebase = imgtitle;
	
	imgID       = getImageID();
	filedir     = split(getDirectory("image"),"\n\n");
	imgdir      = filedir[0];
	imgwidth    = getWidth();  
	imgheight   = getHeight();
	particlecount = 0;
	
	
	
	if (oScalehelp == "Set scale manually"){       
	    scalelineX1 = call("ij.Prefs.get", "PFE.scalelineX1", 10);     
	    scalelineY1 = call("ij.Prefs.get", "PFE.scalelineY1", imgheight-10);   
	    scalelineX2 = call("ij.Prefs.get", "PFE.scalelineX2", imgwidth-10);
	    scalelineY2 = call("ij.Prefs.get", "PFE.scalelineY2", imgheight-10);
	    makeLine(scalelineX1, scalelineY1, scalelineX2, scalelineY2);
	}
	    
	        
	if (oScalehelp != "NONE"){      
	    run("To Selection");
	    setTool(4);
	    scalemessage = "Please set yellow line to set the scale, then press OK to enter values (\"Known distance\" and \"Unit of length\").\n(Use + and - to zoom in and out)";
	    waitForUser("USER INPUT: Manual adjustment", scalemessage);
	    
	    scaleStr = "unit="+oScaleunit+" global"; 
	    run("Set Scale...", scaleStr);
	    run("Set Scale...");
	
	    getLine(scalelineX1, scalelineY1, scalelineX2, scalelineY2, linewidth); 
	    call("ij.Prefs.set", "PFE.scalelineX1", scalelineX1);   
	    call("ij.Prefs.set", "PFE.scalelineY1", scalelineY1);
	    call("ij.Prefs.set", "PFE.scalelineX2", scalelineX2);
	    call("ij.Prefs.set", "PFE.scalelineY2", scalelineY2);
	}
	
	getPixelSize(unit, pWidth, pHeight, pDepth);

	run("Original Scale");
	run("Duplicate...", "title="+imgtitle+"_preprocessed");
	processingID = getImageID();
	selectImage(processingID);

	run("8-bit");   
	run("Grays");
	
	if (oDarkBG) run("Invert");
	if (oSmooth == "Median r = 1 (3x3)") run("Median...", "radius=1");
	else if (oSmooth == "Median r = 2 (5x5)") run("Median...", "radius=2");
	else if (oSmooth == "Median r = 3 (7x7)") run("Median...", "radius=3");
	else if (oSmooth == "Gaussian r = 1") run("Gaussian Blur...", "sigma=1");
	else if (oSmooth == "Gaussian r = 2") run("Gaussian Blur...", "sigma=2");
	else if (oSmooth == "Gaussian r = 3") run("Gaussian Blur...", "sigma=3");
	
	if (oThresh == "Manual (interactive)"){  
	    setBatchMode("exit & display");   	
	    run("Threshold...");
	    setTool(4);   
	    waitForUser("USER INPUT: Manual adjustment","THRESHOLDING of preprocessed image:\n\nIf necessary first adjust threshold with sliders, then press \"Apply\" and finally press \"OK\".\n(Use + and - to zoom in and out)");
	  
	}
	
	if (oThresh == "Automatic (ImageJ)"){  
	    setAutoThreshold();
	}
	
	run ("Create Selection"); 
	roiManager("Add"); 
	selectImage(imgID);
	roiManager("Select", 0);
	roiManager("Split");
	waitForUser("Extraction of RGB values", "Click \"cancel\" to skip a particle");


	for (i = 1; i < roiManager("count"); i++){
	    roiManager("Select", i);
	    Roi.getFeretPoints (x, y);              
		makeLine (x[0], y[0], x[1], y[1]);      
		run("Measure");
		size = getValue("Feret");

		if (size >= minParticle){ 
			particlecount = particlecount + 1;
			run("Line to Area");
			run("Save XY Coordinates...","save=["+dirout+imgtitle+"_p"+particlecount+".csv]");
			}
	}

	
	run("Convert to Mask");
	run("Set Measurements...", "area shape feret's redirect=None decimal=3");
	minParticle_Area=(minParticle)^2;
	run("Analyze Particles...", "size="+minParticle_Area+"-infinity circularity=0.0-1.00 show=Outlines clear include ");
	saveAs("tiff", dirextra + imgtitle +"_numbered_particles");  
	saveAs("Measurements", dirextra + imgtitle +"_measurements_particles.csv");
	close("*");
	selectWindow("Threshold"); 
	run("Close");
	selectWindow("ROI Manager");
	run("Close");

}
