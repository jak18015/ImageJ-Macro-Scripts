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
// ----------------------------------------------------------//
// basic path setup
//===========================================================//
path = getDirectory("Choose the directory containing the 'unprocessed' and 'processed' folders");

input = path + "unprocessed\\";
output = path + "processed\\";

rawlist = getFileList(input);
// ----------------------------------------------------------//
// Organization by goal of processing
//===========================================================//
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
// ----------------------------------------------------------//
// Choosing Raw or deconvolved images for processing
//===========================================================//
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
// ----------------------------------------------------------//
// background subtraction
//===========================================================//
// if (getBoolean("Do you want to run a background subtraction on this set?")) {
	// bacsub = true;
	// }
// else {
	// bacsub = false;
	// }
// ----------------------------------------------------------//
// saving preliminary processing information
//===========================================================//
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
// ----------------------------------------------------------//
// processing begin
//===========================================================//
