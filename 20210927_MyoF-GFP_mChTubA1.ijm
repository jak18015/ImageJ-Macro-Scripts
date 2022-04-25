//Preliminary processing (Color correction, slice selection, bleach correction)
imageTitle=getTitle();//returns a string with the image title
	
	//Color-correction, this is set up for 2-color channels
	//Copy and paste one casette of info to increase channel count
	
	run("*Split Channels [F1]");//splits channels
	
	//casette 1 begin
	selectWindow("C1-"+imageTitle);//select channel 1
	C1=getTitle();//saves the channel 1 name as a variable
	if (getBoolean("reset to min/max of image pixels? or specified values in the script for comparison?", "fit to image", "specific values")) {
	resetMinAndMax ;}
	else {setMinAndMax(0, 10000);//manually set these values for  your data
	}
	run("FreshGreen");//alter the LUT to match whichever color you want for C1
	//casette 1 end
	
	//casette 2 begin
	selectWindow("C2-"+imageTitle);//select channel 2
	C2=getTitle();//saves channel 2 name as a variable
	if (getBoolean("reset to min/max of image pixels? or specified values in the script for comparison?", "fit to image", "specific values")) {
	resetMinAndMax ;}
	else {setMinAndMax(0, 10000);//manually set these values for  your data
	}
	run("RedMagenta");//alter the LUT to match your C2
	//casette 2 end
	
	run("Merge Channels...", "c1="+C1+" c2="+C2+" create");//merge into 1 image
	
	//Choosing Z-stacks/frames/channels to use in final movies
	
	waitForUser("Choose which channels/z-plane/frames you would like to use");
	run("Make Substack...");//alter these values to change which channels/focal planes/frames are included in the AVI
	rename("Processed_" + imageTitle);//Renaming for saving later
	processed=getTitle();//saving the new title as a variable
	
	//cropping to 200x200
	
	makeRectangle(120, 120, 200, 200);//for cropping,if you want a different size box, change the X,Y values (the last 2 values)
		waitForUser("Is this the crop you want?");
		setOption("WaitForCompletion", true);
		run("Crop");

	//Bleach correction option

	if (getBoolean("Do you want to bleach correct?", "Yes", "No")) {
	run("Bleach Correction"); }//fixes bleaching during a timelapse