// Make a new folder for all input files (only .dv files go in here) and a new folder for all output files. 
// The script will prompt you to find these folders.


input=getDirectory("Input file folder");
output=getDirectory("Output file folder");
run("Bio-Formats Macro Extensions");
list = getFileList(input);
for (i = 0; i < list.length; i++) {
	run("Bio-Formats Importer", "open=[" + input + list[i] + "] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

//Preliminary processing (Color correction, slice selection, bleach correction)

	imageTitle=getTitle();//returns a string with the image title
		run("*Split Channels [F1]");//splits channels
		selectWindow("C1-"+imageTitle);//select channel 1
		C1=getTitle();//saves the channel 1 name as a variable
		setMinAndMax(0, 2000);//manually set these values for  your data
		run("FreshGreen");//alter the LUT to match whichever color you want for C1
		selectWindow("C2-"+imageTitle);//select channel 2
		C2=getTitle();//saves channel 2 name as a variable
		setMinAndMax(0, 2000);//manually set these values for your data
		run("RedMagenta");//alter the LUT to match your C2
		run("Merge Channels...", "c1="+C1+" c2="+C2+" create");//merge into 1 image
		waitForUser("Choose which channels/z-plane/frames you would like to use");
		run("Make Substack...");//alter these values to change which channels/focal planes/frames are included in the AVI
		rename("Processed_" + imageTitle);//Renaming for saving later
		processed=getTitle();//saving the new title as a variable
		makeRectangle(120, 120, 200, 200);//for cropping,if you want a different size box, change the X,Y values (the last 2 values)
					waitForUser("Is this the crop you want?");
					setOption("WaitForCompletion", true);
					run("Crop");
		run("Bleach Correction", "correction=[Histogram Matching]");//fixes bleaching during a timelapse
		
		waitForUser("Adjust image as necessary, click OK to save avi's to output folder");
		selectWindow(processed);
		saveAs("avi", "compression=None frame=15 save=[" + processed + ".avi]");
		if (getBoolean("Do you want to make a montage of these?")) {
			selectWindow(processed);
			run("Make Montage...");
			selectWindow("Montage");
			rename("montage_" + processed);
			getBoolean("Do you want to save these montages?");
			selectWindow("montage_" + processed);
			saveAs("Tiff");
		}
		run("Close All");		
}

getBoolean("You're all done!");