//===========================================================//
//    		Two channel z-stack processing pipeline
//===========================================================//
// This pipeline will process your images (bleach correct and background subtract if needed)
// it will then create avi files and montages of both the full image and a chosen inset and save them as RGB Tiffs to be imported into Illustrator

//					KNOWN BUGS
//===========================================================//
// need to add changes in channel one montage to channel two
// need to add back in background subtraction





//					Introduction
//===========================================================//


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

// basic path setup
// -----------------------------------------
path = getDirectory("Choose the directory containing the 'unprocessed' and 'processed' folders");

input = path + "unprocessed\\";
output = path + "processed\\";

rawlist = getFileList(input);
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
for (i=1; i<list.length; i++) {
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
			setBatchMode("hide"); 
            run("Bio-Formats Windowless Importer", "open=" + input+list[i]);
            Stack.getDimensions(width, height, channels, slices, frames);  
				if (channels == 1) {
					ProcessOneChannelImage();
					}
				if (channels == 2) {
					ProcessTwoChannelImage();
					}
				if (channels == 3) {
					showMessage("Sorry, this pipeline doesn't support 3 channel images ... yet! :) if you need it lemme know and I'll add it.");
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

// Begin processing
//______________________________//

	run("Z Project...", "projection=[Max Intensity]");
	run("Subtract Background...", "rolling=100");
	saveAs("tiff", dir + title + ".tif");
	close("*");
}

showMessage("Macro Finished!");


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