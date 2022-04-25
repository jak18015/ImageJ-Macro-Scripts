// Make a new folder for all input files and a folder for all output files
// Change names within the script to fit the experiment

input=getDirectory("Input file folder");
output=getDirectory("Output file folder");

filelist = getFileList(input) 
for (i = 0; i < lengthOf(filelist); i++) {
    run("Bio-Formats Importer", "open=[" + input + filelist[i] + "] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    Stack.getDimensions(width, height, channels, slices, frames);

    if (endsWith(filelist[i], "D3D.dv") && channels==1) { 
			run("Bio-Formats Importer", "open=[" + input + filelist[i] + "] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			imageTitle=getTitle();//returns a string with the image title
			run("Grays");
			setMinAndMax(0,65535);
			makeRectangle(120, 120, 200, 200);
			waitForUser("Is this the crop you want?");
			setOption("WaitForCompletion", true);
			run("Crop");
			waitForUser("Adjust the merged image, click OK to save avi to output folder");
			saveAs("avi", "compression=None frame=15 save=[" + output + imageTitle + ".avi]");
			run("Close All");
	}
	
	if (endsWith(filelist[i], "D3D.dv") && channels==2) { 
		imageTitle=getTitle();//returns a string with the image title
			run("Split Channels");//Splits the channels 
			
			selectWindow("C1-"+imageTitle);//Selects channel 1
				rename("C1");
				run("Green");
				setMinAndMax(0,65535);
			
			selectWindow("C2-"+imageTitle);
				rename("C2");
				run("Magenta");
				setMinAndMax(0,65535);
	
			run("Merge Channels...", "c2=C2 c6=C1 create");
				rename(imageTitle);
				run("Brightness/Contrast...");
				makeRectangle(120, 120, 200, 200);
				waitForUser("Adjust the merged image, click OK to crop and save avi to output folder");
				setOption("WaitForCompletion", true);
				run("Crop");
			saveAs("avi", "compression=None frame=15 save=[" + output + imageTitle + ".avi]");
			run("Close All");
	}

}