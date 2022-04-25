//===========================================================//
//    		Two channel movie processing pipeline
//===========================================================//
// This pipeline will process your images (bleach correct and background subtract if needed)
// it will then create avi files and montages of both the full image and a chosen inset and save them as RGB Tiffs to be imported into Illustrator


//					Introduction
//===========================================================//

Dialog.create("two-channel live movie processing and montage pipeline");
Dialog.addMessage("This pipeline will convert images to magenta/green, and make montages with insets");
Dialog.addMessage("");
Dialog.addMessage("NOTE: You should make two new folders in your data folder containing your images \n labeled 'processed' and 'unprocessed', and move all current raw files into the 'unprocessed' folder.");
Dialog.addMessage("");
Dialog.addMessage("You will need to select these two folders on the upcoming screens to make sure your files save to a \n place you can find them because this pipeline will make new subfolders in 'processed' for each image.");
Dialog.addMessage("");
Dialog.addMessage("You can run this script to make final figures, or to get a scope of the trends across all of your movies.");
Dialog.addMessage("For the montages, the default setting is a montage across the entire movie. \n This means if your movie frames are not '(n-1)/10' (31,61,121 frame movies), your increment will need to be manually adjusted. \n You can change this, and it will use the same values for the inset montage automatically. \n Alternatively, you can download a copy of this script and modify the defaultinc variables at the beginning of the montage commands");
Dialog.show();

//					Get the date for naming
//===========================================================//

	 MonthNames = newArray("01","02","03","04","05","06","07","08","09","10","11","12");
	 getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	 TimeString = ""+year;
	 TimeString = TimeString+MonthNames[month];
     if (dayOfMonth<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+dayOfMonth;


//			Setting up the image directories and files
//===========================================================//

input = getDirectory("Choose the Input Directory Containing Unprocessed Files");
output = getDirectory("_Choose an Output Directory for Processed files");
rawlist = getFileList(input);

for (i = 0; i<rawlist.length; i++) {
	if (endsWith(rawlist[i], ".dv")) {
		list = Array.concat(list,rawlist[i]);
	}
}
list = Array.deleteIndex(list, 0);

GetDateAndTime();
print("-------------------------------");
print("directories for processing");
print("-------------------------------");
print("Input directory: " + input);
print("Output directory: " + output);
print("-------------------------------");
print("Image files");
print("-------------------------------");
for (i=0; i<list.length; i++) {
	print(list[i]);
}
print("-------------------------------");

output = output + "/" + TimeString + "/";
File.makeDirectory(output);

selectWindow("Log");
saveAs(".txt", output + TimeString + "_" + "processing_log");


//						Begin processing
//===========================================================//

// Choose whether you want to loop through entire folder or choose a specific image
if (getBoolean("Do you want to loop through the whole folder, or start at a specific image?", "Loop through entire folder", "Choose specific image") == false) {
	
	while (getBoolean("Choosing 'Yes' will allow you to continue picking individual images, 'No' will abort the macro") == true) {
	Dialog.create("Choose a specific image");
	Dialog.addChoice("Image", list);
	Dialog.show();
	img = Dialog.getChoice();
	open(input+img);
	Stack.getDimensions(width, height, channels, slices, frames);
	print(input+img);
	waitForUser("View this image and see if you think it is good enough to process");   
	if (getBoolean("Do you want to process this file? \n \n Yes will begin processing \n \n No will skip to next image \n \n Cancel will quit the macro") == true) {
		if (channels == 1) {
			ProcessOneChannelImage();
		}
		if (channels == 2) {
			ProcessTwoChannelImage();
		}
	}	
}
}

else {

	for (i=0; i<list.length; i++) { 
		if (endsWith(list[i],".dv")){
			print(i + ": " + input+list[i]); 
            open(input+list[i]);
            Stack.getDimensions(width, height, channels, slices, frames);
			waitForUser("View this image and see if you think it is good enough to process");   
			if (getBoolean("Do you want to process this file? \n \n Yes will begin processing \n \n No will skip to next image \n \n Cancel will quit the macro") == true) {
				if (channels == 1) {
					ProcessOneChannelImage();
				}
				if (channels == 2) {
					ProcessTwoChannelImage();
				}
			}
			else {
				close("*");
				print("\\Clear");
			}	
		}	
	}
}


function ProcessOneChannelImage() { 
// for one channel images
	waitForUser("View this image and see if you think it is good enough to process");   
			title = getTitle();
			dir = output + "/" + title + "/";
			File.makeDirectory(dir);
			print(dir);

//			Process raw files into corrected movies
//===========================================================//


			// if expression for videos with multi-Z
			if (slices > 1) {
				waitForUser("Decide if you want to project these Z-slices, or choose a single slice via z-projection over one slice.");
				run("*Z Project... [F11]");
				rename(title);
			}



			// establishes name variables for two-chanel images
			run("Duplicate...", "duplicate");
			title = getTitle();
			print(title);

			// ROI acquisition and average background values
			run("Duplicate...", "duplicate");
			rename("dupwindow1");
			dupwindow1 = getTitle();
			run("Z Project...", "projection=[Max Intensity]");
			rename("zmax1");
			zmax1 = getTitle();
			selectWindow(dupwindow1);
			run("Z Project...", "projection=[Average Intensity]");
			rename("zavg1");
			zavg1 = getTitle();
			selectWindow(zmax1);
			run("Gaussian Blur...", "sigma=2");
			
			//run("Threshold...");
			setAutoThreshold("Default dark");
			getThreshold(lower, upper);
				print("Parasite Threshold Values \n Lower = " + lower + "\n Upper value = " + upper + "\n");
			run("Create Selection");
			roiManager("Add");
			roiManager("Select", 0);
			roiManager("Rename", "parasite");
			run("Select None");
			setAutoThreshold("MinError dark");
			getThreshold(lower, upper);
				print("Background Threshold Values \n Lower value = " + lower + "\n Upper value = " + upper + "\n");
			run("Create Selection");
			run("Make Inverse");
			roiManager("Add");
			roiManager("Select", 1);
			roiManager("Rename", "background");
			selectWindow(zavg1);
			roiManager("Select", 1);
			run("Measure");
			selectWindow("Results");
			background1 = getResult("Mean", 0);
			print("mean background for bleach correction\n" + background1);
			
			// channel 1 bleach correction
			selectWindow(dupwindow1);
			roiManager("Select", 0);
			
			run("Bleach Correction", "correction=[Simple Ratio] background=" + background1);
			rename("cor_c1");
			
			resetMinAndMax;
			run("Select None");
			

			rename("merge");
			merge = getTitle();
			waitForUser("Decide if background subtraction would be helpful before clicking ok");
			if (getBoolean("Do you want to background subtract this image?") == true) {
				run("Subtract Background...", "rolling=10 sliding stack");
				merge = getTitle();
				print(merge);
			}
			waitForUser("Modify the brightness and contrast here before montage making begins");
					
//                   Montage begin
//===========================================================//

			defaultinc = ((frames - 1) / 10);
			
			selectWindow(merge);

			// My modified Make Montage
			Dialog.create("Jacob's Montage");
			
			Dialog.addNumber("Columns:", 5);
			Dialog.addNumber("Rows:", 2);
			Dialog.addNumber("Scale factor:", 1);
			Dialog.addNumber("First slice:", 1);
			Dialog.addNumber("Last slice:", frames);
			Dialog.addNumber("Increment:", defaultinc);
			Dialog.addNumber("Border width:", 0);
			Dialog.addNumber("Font size:", 0);
			
			Dialog.addCheckbox("Label slices", false);
			Dialog.addCheckbox("Use foreground color", false);
				
				
			// One can add a Help button that opens a webpage
			Dialog.addHelp("https://imagej.nih.gov/ij/macros/DialogDemo.txt");
			
			// Finally show the GUI, once all parameters have been added
			Dialog.show();
				
			// Once the Dialog is OKed the rest of the code is executed
			// ie one can recover the values in order of appearance 
			// Sliders are number too
			columns = Dialog.getNumber(); 
			rows = Dialog.getNumber();
			scale_factor = Dialog.getNumber();
			first_slice = Dialog.getNumber();
			last_slice = Dialog.getNumber(); 
			increment = Dialog.getNumber();
			border_width = Dialog.getNumber();
			font_size = Dialog.getNumber();
			label_slices = Dialog.getCheckbox();
			use_foreground_color = Dialog.getCheckbox();
				
				
			// inString  = Dialog.getString();
			// inChoice  = Dialog.getChoice();
			// inBoolean = Dialog.getCheckbox();
	
			print("\n-------------------------------");
			print("Montage choices");
			print("-------------------------------");
			print("Columns:", columns);
			print("Rows:", rows);
			print("Scale factor:", scale_factor);
			print("First slice:", first_slice);
			print("Last slice:", last_slice);
			print("Increment:", increment);
			print("Border width:", border_width);
			print("Font size:", font_size);
			print("Label slices (1=True, 0=False):", label_slices);
			print("Use foreground color (1=True, 0=False):", use_foreground_color);
			print("-------------------------------");
			print("End montage  choices");
			print("-------------------------------\n");

					
				if (label_slices == false) {
						label_slices = "";
				}
				else {
					label_slices = " label";
				}

				if (use_foreground_color == false) {
					use_foreground_color = "";
				}
				else {
					use_foreground_color = " use";
				}
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + label_slices + use_foreground_color);
			rename("merge_montage");
			merge_montage = getTitle();

			// inset begin
			selectWindow(merge);
			run("Duplicate...", "title=[ref_" + merge + "] duplicate frames=1");
			ref_merge = getTitle();
			
			selectWindow(merge);
			makeRectangle(128, 128, 50, 50);
			waitForUser("Place selection box over desired inset, or change desired inset box size. \n default is 50px X 50px");
			run("Select Bounding Box");
			roiManager("Add");
			roiManager("select", 2);
			roiManager("rename", "inset");
			Roi.setStrokeColor(255, 255, 255);
			Roi.setStrokeWidth(1);
			run("Duplicate...", "title=[inset_" + merge + "] duplicate");
			
			inset_merge = getTitle();
			
//                   Inset montage begin
//===========================================================//
				
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + label_slices + use_foreground_color);
			rename(inset_merge + "_montage");
			inset_merge_montage = getTitle();
			
//                      Montage end
//===========================================================//


//                   Saving everything
//===========================================================//
			// AVI movies
			selectWindow(merge);
			run("AVI... ", "compression=None frame=24 save=" + dir + title + "_" + merge + ".avi");
			
			selectWindow(inset_merge);
			run("AVI... ", "compression=None frame=24 save=" + dir + title + "_" + inset_merge + ".avi");

			// inset reference images
			
			selectWindow(ref_merge);
			
			roiManager("select", 2);
			Roi.setStrokeColor("white");
			Overlay.addSelection
			run("Select None");
			
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + ref_merge + ".tif");
			
			// main montages
			selectWindow(merge_montage);
			run("Duplicate...", "duplicate");
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + merge_montage + ".tif");

			// inset montages
			selectWindow(inset_merge_montage);
			run("Duplicate...", "duplicate");
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + inset_merge_montage + ".tif");

			// log file
			selectWindow("Log");
			saveAs("text", dir + "log_" + title + ".txt");
			print("\\Clear");

			// results file
			selectWindow("Results");
			saveAs("text", dir + "results_" + title + ".txt");
			run("Clear Results");

			//ROIs
			roiManager("save", "" + dir + title + ".roi");
			roiManager("deselect");
			roiManager("delete");
			close("*");
}


function ProcessTwoChannelImage() {
// for two channel images
	waitForUser("View this image and see if you think it is good enough to process");   
			title = getTitle();
			Stack.getDimensions(width, height, channels, slices, frames);
			dir = output + "/" + title + "/";
			File.makeDirectory(dir);
			print(dir);

//			Process raw files into corrected movies
//===========================================================//


			// if expression for videos with multi-Z
			if (slices > 1) {
				waitForUser("Decide if you want to project these Z-slices, or choose a single slice via z-projection over one slice.");
				run("*Z Project... [F11]");
				rename(title);
			}


			// establishes name variables for two-chanel images
			run("Duplicate...", "duplicate");
			title = getTitle();
			run("*Split Channels [F1]");
			selectWindow("C1-" + title);
			c1 = getTitle();
			print(c1);
			selectWindow("C2-" + title);
			c2 = getTitle();
			print(c2);

			// ROI acquisition and average background values
			/// channel 1
			selectWindow(c1);
			run("Duplicate...", "duplicate");
			rename("dupwindow1");
			dupwindow1 = getTitle();
			run("Z Project...", "projection=[Max Intensity]");
			rename("zmax1");
			zmax1 = getTitle();
			selectWindow(dupwindow1);
			run("Z Project...", "projection=[Average Intensity]");
			rename("zavg1");
			zavg1 = getTitle();
			selectWindow(zmax1);
			run("Gaussian Blur...", "sigma=2");
			
			//run("Threshold...");
			setAutoThreshold("Default dark");
			getThreshold(lower, upper);
				print("Parasite Threshold Values \n Lower = " + lower + "\n Upper value = " + upper + "\n");
			run("Create Selection");
			roiManager("Add");
			roiManager("Select", 0);
			roiManager("Rename", "parasite");
			run("Select None");
			setAutoThreshold("MinError dark");
			getThreshold(lower, upper);
				print("Background Threshold Values \n Lower value = " + lower + "\n Upper value = " + upper + "\n");
			run("Create Selection");
			run("Make Inverse");
			roiManager("Add");
			roiManager("Select", 1);
			roiManager("Rename", "background");
			selectWindow(zavg1);
			roiManager("Select", 1);
			run("Measure");
			selectWindow("Results");
			background1 = getResult("Mean", 0);
			print("channel 1 background for bleach correction\n" + background1);
			
			/// channel 2
			selectWindow(c2);
			run("Duplicate...", "duplicate");
			rename("dupwindow2");
			dupwindow2 = getTitle();
			run("Z Project...", "projection=[Average Intensity]");
			rename("zavg2");
			zavg2 = getTitle();
			roiManager("Select", 1);
			run("Measure");
			selectWindow("Results");
			background2 = getResult("Mean", 1);
			print("channel 2 background for bleach correction\n" + background2);
			
			// channel 1 bleach correction
			selectWindow(dupwindow1);
			roiManager("Select", 0);
			run("Bleach Correction", "correction=[Simple Ratio] background=" + background1);
			rename("cor_c1");
			resetMinAndMax;
			
			// channel 2 bleach correction
			selectWindow(dupwindow2);
			roiManager("Select", 0);
			run("Bleach Correction", "correction=[Simple Ratio] background=" + background2);
			rename("cor_c2");
			resetMinAndMax;
			
			// create merge and split channels
			run("Merge Channels...", "c2=cor_c1 c6=cor_c2 create ignore");
			rename("merge");
			merge = getTitle();
			waitForUser("Decide if background subtraction would be helpful before clicking ok");
			if (getBoolean("Do you want to background subtract this image?") == true) {
				run("Split Channels");
				selectWindow("C1-" + merge);
				run("Subtract Background...", "rolling=10 sliding stack");
				selectWindow("C2-" + merge);
				run("Subtract Background...", "rolling=10 sliding stack");
				run("Merge Channels...", "c2=C1-" + merge + " c6=C2-" + merge + " create ignore");
				merge = getTitle();
				print(merge);
			}
			waitForUser("Modify the brightness and contrast here before montage making begins");
					
//                   Montage begin
//===========================================================//

			defaultinc = ((frames - 1) / 10);
			
			selectWindow(merge);

			// My modified Make Montage
			Dialog.create("Jacob's Montage");
			
			Dialog.addNumber("Columns:", 5);
			Dialog.addNumber("Rows:", 2);
			Dialog.addNumber("Scale factor:", 1);
			Dialog.addNumber("First slice:", 1);
			Dialog.addNumber("Last slice:", frames);
			Dialog.addNumber("Increment:", defaultinc);
			Dialog.addNumber("Border width:", 0);
			Dialog.addNumber("Font size:", 0);
			
			Dialog.addCheckbox("Label slices", false);
			Dialog.addCheckbox("Use foreground color", false);
				
				
			// One can add a Help button that opens a webpage
			Dialog.addHelp("https://imagej.nih.gov/ij/macros/DialogDemo.txt");
			
			// Finally show the GUI, once all parameters have been added
			Dialog.show();
				
			// Once the Dialog is OKed the rest of the code is executed
			// ie one can recover the values in order of appearance 
			// Sliders are number too
			columns = Dialog.getNumber(); 
			rows = Dialog.getNumber();
			scale_factor = Dialog.getNumber();
			first_slice = Dialog.getNumber();
			last_slice = Dialog.getNumber(); 
			increment = Dialog.getNumber();
			border_width = Dialog.getNumber();
			font_size = Dialog.getNumber();
			label_slices = Dialog.getCheckbox();
			use_foreground_color = Dialog.getCheckbox();
				
				
			// inString  = Dialog.getString();
			// inChoice  = Dialog.getChoice();
			// inBoolean = Dialog.getCheckbox();
	
			print("\n-------------------------------");
			print("Montage choices");
			print("-------------------------------");
			print("Columns:", columns);
			print("Rows:", rows);
			print("Scale factor:", scale_factor);
			print("First slice:", first_slice);
			print("Last slice:", last_slice);
			print("Increment:", increment);
			print("Border width:", border_width);
			print("Font size:", font_size);
			print("Label slices (1=True, 0=False):", label_slices);
			print("Use foreground color (1=True, 0=False):", use_foreground_color);
			print("-------------------------------");
			print("End montage  choices");
			print("-------------------------------\n");

					
				if (label_slices == false) {
						label_slices = "";
				}
				else {
					label_slices = " label";
				}

				if (use_foreground_color == false) {
					use_foreground_color = "";
				}
				else {
					use_foreground_color = " use";
				}
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + label_slices + use_foreground_color);
			rename("merge_montage");
			merge_montage = getTitle();

			// inset begin
			selectWindow(merge);
			run("Duplicate...", "title=[ref_" + merge + "] duplicate frames=1");
			ref_merge = getTitle();
			selectWindow(merge);
			makeRectangle(128, 128, 50, 50);
			waitForUser("Place selection box over desired inset, or change desired inset box size. \n default is 50px X 50px");
			run("Select Bounding Box");
			roiManager("Add");
			roiManager("select", 2);
			roiManager("rename", "inset");
			Roi.setStrokeColor(255, 255, 255);
			Roi.setStrokeWidth(1);
			run("Duplicate...", "title=[inset_" + merge + "] duplicate");
			inset_merge = getTitle();
			run("Split Channels");
			run("Merge Channels...", "c1=C1-inset_merge c2=C2-inset_merge create keep");

			
//                   Inset montage begin
//===========================================================//
				
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + label_slices + use_foreground_color);
			rename(inset_merge + "_montage");
			inset_merge_montage = getTitle();
			
//                      Montage end
//===========================================================//


//                   Saving everything
//===========================================================//
			// AVI movies
			selectWindow(merge);
			run("AVI... ", "compression=None frame=24 save=" + dir + title + "_" + merge + ".avi");
			run("Split Channels");
			selectWindow("C1-" + merge);
			run("AVI... ", "compression=None frame=24 save=" + dir + title + "_c1_" + merge + ".avi");
			selectWindow("C2-" + merge);
			run("AVI... ", "compression=None frame=24 save=" + dir + title + "_c2_" + merge + ".avi");
			selectWindow(inset_merge);
			run("AVI... ", "compression=None frame=24 save=" + dir + title + "_" + inset_merge + ".avi");
			run("Split Channels");
			selectWindow("C1-" + inset_merge);
			run("AVI... ", "compression=None frame=24 save=" + dir + title + "_c1_" + inset_merge + ".avi");
			selectWindow("C2-" + inset_merge);
			run("AVI... ", "compression=None frame=24 save=" + dir + title + "_c2_" + inset_merge + ".avi");

			// inset reference images
			
			selectWindow(ref_merge);
			roiManager("select", 2);
			Overlay.addSelection
			run("Select None");
			run("Duplicate...", "duplicate");
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + ref_merge + ".tif");
			selectWindow(ref_merge);
			run("Split Channels");
			selectWindow("C1-" + ref_merge);
			run("RGB Color");
			saveAs("Tiff", dir + title + "_c1_" + ref_merge + ".tif");
			selectWindow("C2-" + ref_merge);
			run("RGB Color");
			saveAs("Tiff", dir + title + "_c2_" + ref_merge + ".tif");
		
			// main montages
			selectWindow(merge_montage);
			run("Duplicate...", "duplicate");
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + merge_montage + ".tif");
			selectWindow(merge_montage);
			run("Split Channels");
			selectWindow("C1-" + merge_montage);
			run("RGB Color");
			saveAs("Tiff", dir + title + "_c1_" + merge_montage + ".tif");
			selectWindow("C2-" + merge_montage);
			run("RGB Color");
			saveAs("Tiff", dir + title + "_c2_" + merge_montage + ".tif");

			// inset montages
			selectWindow(inset_merge_montage);
			run("Duplicate...", "duplicate");
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + inset_merge_montage + ".tif");
			selectWindow(inset_merge_montage);
			run("Split Channels");
			selectWindow("C1-" + inset_merge_montage);
			run("RGB Color");
			saveAs("Tiff", dir + title + "_c1_" + inset_merge_montage + ".tif");
			selectWindow("C2-" + inset_merge_montage);
			run("RGB Color");
			saveAs("Tiff", dir + title + "_c2_" + inset_merge_montage + ".tif");

			// log file
			selectWindow("Log");
			saveAs("text", dir + "log_" + title + ".txt");
			print("\\Clear");

			// results file
			selectWindow("Results");
			saveAs("text", dir + "results_" + title + ".txt");
			run("Clear Results");

			//ROIs
			roiManager("save", "" + dir + title + ".roi");
			roiManager("deselect");
			roiManager("delete");

			close("*");
}

function GetDateAndTime() { 
// gets the date and time of processing
     MonthNames = newArray("01","02","03","04","05","06","07","08","09","10","11","12");
     DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     TimeString ="Date: "+DayNames[dayOfWeek]+" ";
     if (dayOfMonth<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+"\nTime: ";
     if (hour<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+hour+":";
     if (minute<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+minute+":";
     if (second<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+second;
     print(TimeString);
}