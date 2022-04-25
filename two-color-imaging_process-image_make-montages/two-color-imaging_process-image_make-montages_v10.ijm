//===========================================================//
//    		Two channel movie processing pipeline
//===========================================================//
// This pipeline will process your images (bleach correct and background subtract if needed)
// it will then create avi files and montages of both the full image and a chosen inset and save them as RGB Tiffs to be imported into Illustrator

//					KNOWN BUGS
//===========================================================//
// need to add changes in channel one montage to channel two
// need to add back in background subtraction





//					Introduction
//===========================================================//

Dialog.create("two-channel live movie processing and montage pipeline");
Dialog.addMessage("This pipeline will process 1- and 2-channel images, and make montages with insets.", 24);
Dialog.addMessage("");
Dialog.addMessage("NOTE: You should have the following three folders in your main image data folder:"
+ "\n one containing all your data from the scope labeled 'unprocessed'"
+ "\n one labeled 'processed' where the output of your processing will be saved"
+ "\n one labeled 'backup' which is a safe copy of everything from the scope");
Dialog.addMessage("");
Dialog.addMessage("You will need to select the main image data folder (ex. 20220202_MyoF-GFP) on the upcoming screen."
+ "\n (the folder containing your 'processed', 'unprocessed', and 'backup' folders)");
Dialog.addMessage("");
Dialog.addMessage("You can run this script to make final figures, or to get a scope of the trends across all of your movies.");
Dialog.addMessage("For the montages, the default setting is a montage across the entire movie."
+ "\n This means if your movie frames are not '(n-1)/10' (31,61,121 frame movies), your increment will need to be manually adjusted."
+ "\n You can change this in the montage dialog, and it will use the same values for the inset montage automatically.");
Dialog.addMessage("\n You should open a few files first to test and see if you will want to background subtract / bleach correct / modify the settings in the code!"
+ "\n DO NOT modify this file, make a copy for any code edits!!!", 16, "Red");
Dialog.show();


					// BASIC DIRECTORY PREPPING
//===========================================================//
//===========================================================//
//===========================================================//



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
waitForUser("In the following dialog box, choose the folder containing your images. This should include:" 
+ "\n all of your .dv files (and their respective files i.e. everything that gets exported from the microscope) in a folder called 'unprocessed'"
+ "\n and another folder called 'processed' that is empty for your processed output."
+ "\n \n(I have another script that can do this for you and make a 'backup' folder with a copy of everything in it for safekeeping)"
+ "\n \n It is ok if there are previously processed images in this folder if you have processed images days previous"
+ "\n since the processed folder contains subfolders based on when you processed and stores them in YYYYMMDD folders."
+ "\n \n If you are going to repeat the same processing in the same day on an image, the new processing will be saved as a duplicate with a '_x' following,"
+ "\n where x is the duplicate number (i.e. 01_R3D.dv duplicate will be 01_R3D_2.dv etc.)"
+ "\n \n However all files within this folder will retain the original '01_R3D.dv' as their titles to prevent hard-to-search-for, long-titled duplicates.");

// basic path setup
// -----------------------------------------
path = getDirectory("Choose the directory containing the 'unprocessed' and 'processed' folders");



input = path + "unprocessed\\";
output = path + "processed\\";

rawlist = getFileList(input);

Array.print(rawlist);

// -----------------------------------------



// Organization by goal of processing
// -----------------------------------------
folders = getFileList(output);
folders = Array.concat(folders,"New Folder");

Dialog.createNonBlocking("What are you trying to analyze?");
Dialog.addMessage("You can either repeat already done analysis from the dropdown or choose 'New Analysis' to create a new folder");
Dialog.addChoice("Choose the folder to open", folders);

Dialog.show();

choice = Dialog.getChoice();
print(choice);

if (choice == "New Folder") {
	Dialog.create("Name this new folder");
	Dialog.addMessage("This dialog box will use the answer in the field below to create a subfolder within 'processed' that will save all processing into this folder."
	+ "\n \n Try to keep this name descriptive and concise ('RB staining', 'Apical MyoF', etc).");
	Dialog.addString("New Folder Name", "", 30);
	Dialog.show();
	newfolder = Dialog.getString();
	newfolder = split(newfolder, " ");
	newfolder = String.join(newfolder, "_");
	output = output + "\\" + newfolder + "\\";
	File.makeDirectory(output);
	print("Saving into new folder (" + newfolder + ") now set as output: " + output);
	}
else {
	output = output + "\\" + choice + "\\";
	print("Saving into output: " + output);
}
// -----------------------------------------


// Choosing Raw or deconvolved images for processing
// -----------------------------------------
if (getBoolean("Do you want to process raw or deconvolved images?", "Raw (R3D)", "Deconvolved (R3D_D3D)") == true) {
	for (i = 0; i<rawlist.length; i++) {
		if (endsWith(rawlist[i], "R3D.dv")) {
			list = Array.concat(list,rawlist[i]);
		}
	}
}
else {
	for (i = 0; i<rawlist.length; i++) {
		if (endsWith(rawlist[i], "R3D_D3D.dv")) {
			list = Array.concat(list,rawlist[i]);	
			}
		}
	}

// if (getBoolean("Do you want to run a background subtraction on this set?")) {
	// bacsub = true;
	// }
// else {
	// bacsub = false;
	// }



output = output + "/" + TimeString + "/";
File.makeDirectory(output);

GetDateAndTime();
print("-------------------------------");
print("directories for processing");
print("-------------------------------");
print("Input directory: " + input);
print("Output directory: " + output);
print("-------------------------------");
// if (bacsub == true) {
	// print("Background subtraction ON");
	// }
print("-------------------------------");
print("Image files");
print("-------------------------------");
for (i=0; i<list.length; i++) {
	print(list[i]);
}
print("-------------------------------");

selectWindow("Log");
saveAs(".txt", output + TimeString + "_" + "processing_log");
print("\\Clear");


//						Begin processing
//===========================================================//



// Choose whether you want to loop through entire folder or choose a specific image
if (getBoolean("Do you want to loop through the whole folder, or start at a specific image?", "Loop through entire folder", "Choose specific image") == false) {

// need to add a dialog box about switching channels to make sure myof/actin is in the first channel


// run("Arrange Channels...");
	if (getBoolean("Do you want to pick images one by one, or start at an image and loop through the end of set?", "Single Image", "Loop") == true) {
		
		
		while (getBoolean("Choosing 'Yes' will allow you to continue picking individual images, 'No' will abort the macro") == true) {
			Dialog.create("Choose a specific image");
			Dialog.addChoice("Image", list);
			Dialog.show();
			img = Dialog.getChoice();
			open(input+img);
			title = getTitle();
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
			close("*");
			print("\\Clear");
			}	
		}
	}
	else {
		Dialog.create("Choose a specific image");
			Dialog.addChoice("Image", list);
			Dialog.show();
			img = Dialog.getChoice();
			in = charCodeAt(img, img.length - 9);
			dex = charCodeAt(img, img.length -8);
			in = fromCharCode(in);
			if (in < 1) {
				in = "0";
			}
			dex = fromCharCode(dex);
			if (dex < 1) {
				dex = "0";	
			}
			index = (in +""+ dex);
			
			newlist = Array.slice(list,index,list.length);
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
		close("*");
		print("\\Clear");		
		for (i=1; i<newlist.length; i++) { 
		if (endsWith(newlist[i],".dv")){
			print(i + ": " + input+newlist[i]); 
            open(input+newlist[i]);
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
				if (channels == 3 {
					showMessage("Sorry, this pipeline doesn't support 3 channel images ... yet! :) if you need it lemme know and I'll add it.");
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
	title = getTitle();
	titl = File.getNameWithoutExtension(title);
	dir = output + "/" + title + "/";


// if you've already processed the same image in the same day, this will ask if you want to make a duplicate folder or overwrite that previous data
	if (File.exists(dir) == true) {
			if (getBoolean("This folder already exists, do you want to overwrite it or make a new folder?", "Overwrite", "New Folder") == false) {
			
				i = 2;
		
				while (File.exists(output + "/" + titl + "_" + i + ".dv" + "/") == true) {
					i = i + 1;
					}
				if (File.exists(output + "/" + titl + "_" + i + ".dv" + "/") == false) {
					newdir = output + "/" + titl + "_" + i + ".dv" + "/";
					File.makeDirectory(newdir);
					dir = newdir;
					print("New directory for this processing made at " + dir);
					showMessage("New directory for this processing made at " + dir);
					selectWindow(title);
					rename(titl + "_" + i + ".dv");
					title = getTitle(); 		
					}
				}
		}
	else {
		File.makeDirectory(dir);
		}

//			Process raw files into corrected movies
//===========================================================//

			// if expression for cropping down to 256x256
			if (width+height != 512) {
				makeRectangle(width/2, height/2, 256, 256);
				run("Crop");
				rename(title);
			}

			// if expression for videos with multi-Z
			if (slices > 1) {
				waitForUser("Decide if you want to project these Z-slices, or choose a single slice via z-projection over one slice.");
				run("*Z Project... [F11]");
				rename(title);
			}

			// establishes name variables
			run("Duplicate...", "duplicate");
			rename("dup");
			selectWindow(title);
			close();
			selectWindow("dup");
			rename(title);
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
					
//                   Montage begin
//===========================================================//
			if (frames > 135) {
				frames = 135;
				}
			defaultinc = ((frames - 1) / 9);
			defaultinc = round(defaultinc);
			defaultframes = 9*defaultinc;
			defaultinc = toString(defaultinc, 0);
			defaultframes = toString(defaultframes, 0);


			selectWindow(merge);

			// My modified Make Montage
			Dialog.createNonBlocking("Jacob's Montage");
			Dialog.addMessage("NOTE: When making a montage, both the first and last frame appear in the panel. \n i.e. a 10 panel montage of frames 40-80 with an increment of 4 will only go to 76");
			Dialog.addMessage("NOTE: When making a montage, both the first and last frame appear in the panel."
			+ "\n \n i.e. 4 panel montages with an increment of 4 have 12 frames from first to last (4,8,12,16)");
			Dialog.addNumber("Columns:", 5);
			Dialog.addNumber("Rows:", 2);
			Dialog.addNumber("Scale factor:", 1);
			Dialog.addNumber("First slice:", 1);
			Dialog.addNumber("Last slice:", defaultframes);
			Dialog.addNumber("Increment:", defaultinc);
			Dialog.addNumber("Border width:", 0);
			
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
			print("Use foreground color (1=True, 0=False):", use_foreground_color);
			print("-------------------------------");
			print("End montage  choices");
			print("-------------------------------\n");

				if (use_foreground_color == 0) {
					use_foreground_color = "";
				}
				else {
					use_foreground_color = " use";
				}
			selectWindow(merge);

			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + use_foreground_color);
			rename("merge_montage");
			merge_montage = getTitle();
			selectWindow(merge);
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + " font=12" + " label" + use_foreground_color);
			rename("merge_labeled_montage");
			merge_labeled_montage = getTitle();

			// inset begin
			selectWindow(merge);
			run("Duplicate...", "title=[ref_" + merge + "] duplicate frames=1");
			ref_merge = getTitle();
			
			selectWindow(merge);
			makeRectangle(128, 128, 50, 50);
			selectWindow(merge);
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
				
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + use_foreground_color);
			rename(inset_merge + "_montage");
			inset_merge_montage = getTitle();
			selectWindow(inset_merge);
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + " font=12" + " label" + use_foreground_color);
			rename("inset_merge_labeled_montage");
			inset_merge_labeled_montage = getTitle();
			
//                      Montage end
//===========================================================//

			if (isOpen("Threshold")) {
				selectWindow("Threshold");
				close("Threshold");
				}

//                   Saving everything
//===========================================================//
			selectWindow("merge");
			resetMinAndMax;
			run("Brightness/Contrast...");
			waitForUser("Adjust your brightness and contrast and propogate to all open images");
		
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
			rename("merge_montage_unscaled");
			saveAs("Tiff", dir + title + "_" + merge_montage + "_unscaled" + ".tif" );
			selectWindow(merge_montage);
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + merge_montage + ".tif");

			selectWindow(merge_labeled_montage);
			run("Duplicate...", "duplicate");
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + merge_labeled_montage + ".tif");

			// inset montages
			selectWindow(inset_merge_montage);
			run("Duplicate...", "duplicate");
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + inset_merge_montage + ".tif");

			selectWindow(inset_merge_labeled_montage);
			run("Duplicate...", "duplicate");
			run("RGB Color");
			saveAs("Tiff", dir + title + "_" + inset_merge_labeled_montage + ".tif");

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

// if you've already processed the same image in the same day, this will ask if you want to make a duplicate folder or overwrite that previous data

//	if (File.exists(dir) == true) {
//			if (getBoolean("This folder already exists, do you want to overwrite it or make a new folder?", "Overwrite", "New Folder") == false) {
//			
//				i = 2;
//		
//				while (File.exists(output + "/" + titl + "_" + i + ".dv" + "/") == true) {
//					i = i + 1;
//					}
//				if (File.exists(output + "/" + titl + "_" + i + ".dv" + "/") == false) {
//					newdir = output + "/" + titl + "_" + i + ".dv" + "/";
//					File.makeDirectory(newdir);
//					dir = newdir;
//					print("New directory for this processing made at " + dir);
//					showMessage("New directory for this processing made at " + dir);		
//					}
//				}
//		}
//	else {
//		File.makeDirectory(dir);
//		}


//			Process raw files into corrected movies
//===========================================================//

			// if expression for cropping down to 256x256
			if (width+height != 512) {
				makeRectangle(0, 0, 256, 256);
				waitForUser("Place your cropping rectangle");
				run("Crop");
				rename(title);
			}

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
			setAutoThreshold("Mean dark");
			waitForUser("If this threshold doesn't look accurate to the vacuole, open the threshold panel and change\n if the default method 'Mean dark' is not working well for your set, change it in the code");
			getThreshold(lower, upper);
				getInfo("threshold.method");
				print("Parasite Threshold Values \n Lower = " + lower + "\n Upper value = " + upper + "\n");
			run("Create Selection");
			roiManager("Add");
			roiManager("Select", 0);
			roiManager("Rename", "parasite");
			run("Select None");
			roiManager("Select", 0);
			run("Make Inverse");
			setAutoThreshold("MinError dark");
			waitForUser("If this threshold doesn't cover most of the background, open the threshold panel and change\n if the default method 'MinError dark' is not working well for your set, change it in the code");
			getThreshold(lower, upper);
				getInfo("threshold.method");
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
			run("Bleach Correction");
			rename("cor_c1");
			resetMinAndMax;
			
			// channel 2 bleach correction
			selectWindow(dupwindow2);
			roiManager("Select", 0);
			run("Bleach Correction");
			rename("cor_c2");
			resetMinAndMax;
			
			// create merge and split channels
			run("Merge Channels...", "c6=cor_c2 c2=cor_c1 create ignore");
			rename("merge");
			merge = getTitle();
					
//                   Montage begin
//===========================================================//

			defaultinc = ((frames - 1) / 10);
			
			selectWindow(merge);

			// My modified Make Montage
			Dialog.createNonBlocking("Jacob's Montage");
			
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

			selectWindow(merge);
			rename("merge_old");
			run("Duplicate...", "duplicate frames=" + first_slice + "-" + last_slice);
			rename("merge");
			merge = getTitle();
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " border=" + border_width + label_slices + use_foreground_color);
		
			rename("merge_montage");
			merge_montage = getTitle();
			selectWindow("merge_montage");
			Stack.setChannel(1);
			resetMinAndMax();
			getMinAndMax(min1, max1);
			Stack.setChannel(2);
			resetMinAndMax;
			getMinAndMax(min2, max2);

			// inset begin
			selectWindow(merge);
			Stack.setChannel(1);
			setMinAndMax(min1, max1);
			Stack.setChannel(2);
			setMinAndMax(min2, max2);
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

			if (isOpen("Threshold")) {
				selectWindow("Threshold");
				close("Threshold");
				}


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
			Roi.setStrokeColor("white");
			Overlay.addSelection;
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

function BackgroundSubtractOneChannel() {
				run("Subtract Background...");
				merge = getTitle();
}

function BackgroundSubtractTwoChannel() {
				run("Split Channels");
				selectWindow("C1-" + merge);
				run("Subtract Background...");
				selectWindow("C2-" + merge);
				run("Subtract Background...");
				run("Merge Channels...", "c2=C1-" + merge + " c6=C2-" + merge + " create ignore");
				merge = getTitle();
}