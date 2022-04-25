// Make a new folder for all input files and a folder for all output files
// Change names within the script to fit the experiment

input=getDirectory("Input file folder");
output=getDirectory("Output file folder");

filelist = getFileList(input) 
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], "D3D.dv")) { 
		run("Bio-Formats Importer", "open=[" + input + filelist[i] + "] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		imageTitle=getTitle();//returns a string with the image title
			run("Split Channels");//Splits the channels 
			
			selectWindow("C1-"+imageTitle);//Selects channel 1
				rename("C1");
				run("Green");
				setMinAndMax(0,65535);
				run("Find focused slices", "select=100 variance=0.000");
				selectWindow("Focused slices of C1_100.0%");
				rename("Focused_C1");
	
			selectWindow("C2-"+imageTitle);
		
				rename("C2");
				run("Magenta");
				setMinAndMax(0,65535);
				run("Find focused slices", "select=100 variance=0.000");
				selectWindow("Focused slices of C2_100.0%");
				rename("Focused_C2");
				run("Merge Channels...", "c2=Focused_C2 c6=Focused_C1 create");
			rename(imageTitle);
			run("Brightness/Contrast...");
			makeRectangle(120, 120, 200, 200);
				waitForUser("Adjust image as necessary, click OK to crop and save tiff to output folder");
				setOption("WaitForCompletion", true);
				run("Crop");
			saveAs("Tiff",output+"Processed_"+imageTitle);
			run("Close All");
}
}
waitForUser("Processing on input folder complete");

Stack.getDimensions(width, height, channels, slices, frames);
print(channels);