// Make a new folder for all input files and a folder for all output files
// Change names within the script to fit the experiment

input=getDirectory("Input file folder");
output=getDirectory("Output file folder");

run("Bio-Formats Macro Extensions");

list = getFileList(input);

for (i = 0; i < list.length; i++) {

	run("Bio-Formats Importer", "open=[" + input + list[i] + "] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

	imageTitle=getTitle();//returns a string with the image title
		run("Split Channels");//Splits the channels 
		
		selectWindow("C2-"+imageTitle);//Selects channel 1
			rename("C1");
			run("Magenta");
			run("Brightness/Contrast...");
			resetMinAndMax();
			waitForUser("Brightness and contrast of C1 set?");
			
		selectWindow("C1-"+imageTitle);
			rename("C2");
			run("Green");
			run("Brightness/Contrast...");
			resetMinAndMax();
			waitForUser("Brightness and contrast of C2 set?");

		run("Merge Channels...", "c2=C1 c6=C2");
		rename("Processed_" + imageTitle);
		processed=getTitle();
		makeRectangle(120, 120, 200, 200);
					waitForUser("Is this the crop you want?");
					setOption("WaitForCompletion", true);
					run("Crop");
		run("*Split Channels [F1]");
		selectWindow("C1-Processed_"+ imageTitle);
		C1=getTitle();
		selectWindow("C2-Processed_"+ imageTitle);
		C2=getTitle();
		run("Merge Channels...", "c1="+ C1 + " c2=" + C2 + " create keep");
		waitForUser("Adjust image as necessary, click OK to save avi's to output folder");
		selectWindow(processed);
		saveAs("avi", "compression=None frame=15 save=[" + processed + ".avi]");
		selectWindow(C1);
		saveAs("avi", "compression=None frame=15 save=[C1_" + imageTitle + ".avi]");
		selectWindow(C2);
		saveAs("avi", "compression=None frame=15 save=[C2_" + imageTitle + "_.avi]");
		selectWindow(processed);
		if (getBoolean("Do you want to make a montage of these?")) {
			selectWindow(processed);
			run("Make Montage...");
			selectWindow("Montage");
			rename("montage_" + processed);
			selectWindow(C1);
			run("Make Montage...");
			rename("montage_" + C1);
			selectWindow(C2);
			run("Make Montage...");
			rename("montage_" + C2);
			getBoolean("Do you want to save these montages?");
			selectWindow("montage_" + processed);
			saveAs("Tiff");
			selectWindow("montage_" + C1);
			saveAs("Tiff");
			selectWindow("montage_" + C2);
			saveAs("Tiff");
		}
	run("Close All");		
}

getBoolean("You're all done!");
