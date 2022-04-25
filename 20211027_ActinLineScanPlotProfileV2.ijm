// Make a new folder for all input files and a folder for all output files
// Change names within the script to fit the experiment

input=getDirectory("Input file folder"); 
// This directory should contain all of the images to be analyzed, and only those images
output=getDirectory("Output file folder");
// This directory will be where all files will be exported to

run("Bio-Formats Macro Extensions");
// Initializes the plugins necessary to open files

list = getFileList(input);
// Creates a list of files found in the input to FOR loop over for analysis

for (i = 0; i < list.length; i++) {
// Beginning of FOR loop
	run("Bio-Formats Importer", "open=[" + input + list[i] + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
// Opens the files

getDimensions(width, height, channels, slices, frames);
title = getTitle();
// Gets dimensions and title for following FOR loop and for naming output correctly

setOption("WaitForCompletion", true);
	waitForUser("Draw line", "Draw line segment");
// This is where the line segment is drawn that will be the analysis line

roiManager("add");
// Adds the line to the ROI manager to be saved for reference

CurrentCount = roiManager("count");
// This count is necessary for the subsequent line

roiManager("select", CurrentCount - 1);
// Selects the ROI drawn on the current image

roiManager("rename", title);
// Renames the selected ROI to the same name as the current image

for (j = 0; j < frames; j++) {
// Beginning of plot profile analysis FOR loop

    profile = getProfile();
    // Runs plot profile without displaying the window and returns the data as an array to a log window
    
    Array.print(profile);
	// Prints the array to a log window for saving
   
    run("Next Slice [>]");
    //Moves the image one slice forward to re-iterate the J FOR loop

} 
// End of J FOR loop

save(output + title + "_LINESCAN.txt");
// Saves the plot profile array in the log window as a text file for import into excel

roiManager("save selected", output + title + "_ROI.zip");
// Saves the ROI for later reference

roiManager("delete");
// Deletes the ROIs before the next image is opened

close("Log");
// Closes the log window before the next image is opened
}
//End of I FOR loop