// get date for organization
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
TimeString =""+year+"";	    
if (month < 10) {TimeString = TimeString+"0";}
	TimeString = TimeString+(month+1); 
if (dayOfMonth<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+dayOfMonth;

// pixels to micron conversion
micronPerPixels = (1/15.4321);

// processing
list = getList("image.titles");
for (i=0; i < list.length; i++) {
	selectWindow(list[i]);
	setLocation(screenWidth/4, screenHeight/4, 256, 256);
}
run("Cascade");
for (image = 0; image < list.length; image++) {
	selectWindow(list[image]);
	Stack.getDimensions(width, height, channels, slices, frames);
	setLocation(screenWidth/4, screenHeight/4, 512, 512);
	title = getTitle();
	
	// count the actin
	run("Z Project...", "projection=[Max Intensity]");
	projection = getTitle();
	setLocation(1/screenWidth, 1/screenHeight, 0.7*sqrt(screenHeight*screenWidth), 0.7*sqrt(screenHeight*screenWidth));
	Dialog.createNonBlocking("actin counter");
	Dialog.addNumber("how many linescans will you draw on this image?", 2);
	Dialog.show();
	actinCount = Dialog.getNumber();
	
	for (g=0; g < actinCount; g++) {
		setTool(5);
		selectWindow(projection);
		setLocation(1/screenWidth, 1/screenHeight, 0.7*sqrt(screenHeight*screenWidth), 0.7*sqrt(screenHeight*screenWidth));
		waitForUser("draw line");
		roiManager("add");
		roiManager("select", roiManager("count")-1);
		roiName = Roi.getName;
		roiManager("rename", title + "_" + roiName);
		if (g == actinCount-1) {close(projection);}
		selectWindow(list[image]);
		roiManager("select", roiManager("count")-1);
		c1Profile = getProfile();
		
	// set up arrays for table
		// pixel array
		pixelArray = Array.getSequence(c1Profile.length);
		for (i=0; i < pixelArray.length; i++) {
			pixelArray[i] = pixelArray[i]+1;
		}
		// micron array
		micronArray = newArray("");
		// img title array
		titleArray = newArray("");
		// actin number array
		actinArray = newArray("");
		// propogate arrays
		for (i=0; i < pixelArray.length; i++) {
			micronArray[i] = pixelArray[i]*micronPerPixels;
			titleArray[i] = title;
			actinArray[i] = g+1;
		}
		
		// set ID columns into Results table
		Table.setColumn("img", titleArray);
		Table.setColumn("actinCount", actinArray);
		Table.setColumn("px", pixelArray);
		Table.setColumn("micron", micronArray);
		
		// measure actin profile and set into Results table
		for (f=0; f < frames; f++) {
			Stack.setFrame(f+1);
			c1Profile = getProfile();			
			Table.setColumn("Frame_" + f+1 + "", c1Profile);
		}
		
		// create or append results to excel file
		xlPath = "Z:\\Jacob\\R\\Projects\\20221107_MyoF-AID_AC-EmFP\\20221129_linescansForASCB\\";
		xlName = TimeString + "_actinProfilesRedraw";
		setOption("WaitForCompletion", true);
		run("Read and Write Excel", "stack_results no_count_column dataset_label=[20220916_actinAnalysis] file=["+xlPath+xlName+".xlsx]");
		roiManager("save", xlPath+xlName + ".zip");
		run("Clear Results");
		close("Results");
		selectWindow(list[image]);
		setLocation(0.8*screenWidth, 0.8*screenHeight, 256, 256);
		run("Put Behind [tab]");
	}
}