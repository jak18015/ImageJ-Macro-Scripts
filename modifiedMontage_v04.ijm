open("C:\\Users\\jakek\\OneDrive\\Desktop\\imagesForFigures.csv");
tableName = "X:\\Microscopy\\20211015_MyoF-AID_AC-EmFP_FNR-RFP\\unprocessed\\";
Col = Table.getColumn(tableName);
tableName = tableName+"processingRecord";
Table.create("skippedImageSets");
Table.setColumn("imageSet");

Table.create(tableName);

close("imagesForFigures.csv");

for (i=0; i < Col.length; i++) {open(Col[i]);}

list = getList("image.titles");

for (i=0; i < list.length; i++) {

	// Prep paths
	selectWindow(list[i]);
	run("8-bit");
	title = getTitle();
	dir = getDirectory("image");
	dirArray = split(dir, "\\");
	dirArray = Array.deleteIndex(dirArray, 3);
	dir = String.join(dirArray, "\\") + "\\";
	print("Processed dir: " + dir);
	File.makeDirectory(dir + "illustratorTiffs");
	dir = dir + "illustratorTiffs" + File.separator;
	selectWindow(tableName);
	Table.set("Path", i, dir+list[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	if (slices > 1) {
		waitForUser("set the best Z in "+list[i]);
		run("Reduce Dimensionality...", "channels frames");
	}
	
	if (channels == 1) {oneChannelMontage();}
	if (channels == 2) {twoChannelMontage();}

	closeList = getList("image.titles");
	for (j=0; j < closeList.length; j++) {
		selectWindow(closeList[j]);
		if (matches(closeList[j], ".*"+""+list[i]+""+".*")) {close();}
	}
}
selectWindow(tableName);
Table.save(tableName+".csv");
print("Table saved to: "+tableName+".csv");
print("Done!");


function oneChannelMontage() {

//Process image for proper montaging
makeRectangle(20, 20, 180, 180);
			waitForUser("Place selection box over vacuole. \n default is 180px X 180px");
				getSelectionBounds(x, y, width, height);
				selectWindow(tableName);
					Table.set("XY coordinates", 0, "("+x+","+y+")");
					Table.set("window size width (px)", 0, width);
					Table.set("window size height (px)", 0, height);
					Table.update;

			run("Crop");
merge = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
	frameInterval = Stack.getFrameInterval();
	selectWindow(tableName);
	Table.set("Frame interval (sec)", 0, frameInterval);
	Table.update;
run("Bleach Correction", "correction=[Exponential Fit]");
close("y = a*exp(-bx) + c");
selectWindow("DUP_"+ merge);
rename(merge+"_DUP");
merge = getTitle();


//                   Montage begin
//===========================================================//
			if (frames > 135) {
				frames = 135;
				}
			defaultinc = 20;
			defaultframes = 61;



			selectWindow(merge);

			// My modified Make Montage
			Dialog.createNonBlocking("Jacob's Montage");
			Dialog.addMessage("NOTE: When making a montage, both the first and last frame appear in the panel. \n i.e. a 10 panel montage of frames 40-80 with an increment of 4 will only go to 76");
			Dialog.addMessage("NOTE: When making a montage, both the first and last frame appear in the panel."
			+ "\n \n i.e. 4 panel montages with an increment of 4 have 12 frames from first to last (4,8,12,16)");
			Dialog.addNumber("Columns:", 1);
			Dialog.addNumber("Rows:", 4);
			Dialog.addNumber("Scale factor:", 1);
			Dialog.addNumber("First slice:", 1);
			Dialog.addNumber("Last slice:", 61);
			Dialog.addNumber("Increment:", 20);
			Dialog.addNumber("Border width:", 0);
			
			Dialog.addCheckbox("Use foreground color", false);
					
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
	// figure montage
			selectWindow(merge);
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + use_foreground_color);
			rename(merge+"_montage");
			merge_montage = getTitle();
			
	// labeled montage
			selectWindow(merge);
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + use_foreground_color + " label");
			rename(merge+"_labeledMontage");
			labeledMontage = getTitle();
			
			// inset begin
			selectWindow(merge);
			run("Duplicate...", "title="+merge+"_ref duplicate frames=1");
			ref_merge = getTitle();
			
			selectWindow(ref_merge);
			makeRectangle(60, 60, 60, 60);
			waitForUser("Place selection box over desired inset, "
			+ "or change desired inset box size. \n default is 60px X 60px");
					getSelectionBounds(x, y, width, height);
					Table.set("inset XY coordinates", 0, ""+x+","+y+"");
					Table.set("inset window size width (px)", 0, width);
					Table.set("inset window size height (px)", 0, height);
					Table.update;
			run("Select Bounding Box");
			roiManager("Add");
			roiManager("select", 0);
			roiManager("rename", "inset");
			Roi.setAntiAlias(false);
			Roi.setStrokeColor(255, 255, 255);
			Roi.setStrokeWidth(2);
			Overlay.addSelection
			run("Duplicate...", "title="+merge+"_inset duplicate");
			
			insetMerge = getTitle();

			
			
//                   Inset montage begin
//===========================================================//
				
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + use_foreground_color);
			rename(merge+"_insetMontage");
			insetMergeMontage = getTitle();
			roiManager("delete");
			
//                      Montage end
//===========================================================//
selectWindow(ref_merge);
run("Z Project...", "stop=1 projection=[Max Intensity]");
rename(merge+"_ref");
ref_merge = getTitle();

selectWindow(insetMergeMontage);
run("Duplicate...", "title=insetVarMask");
	run("8-bit");
run("Gaussian Blur...", "sigma=1");
run("Variance...", "radius=1");
rename(insetMergeMontage+"_VarMask");
VarMaskInset = getTitle();



selectWindow(insetMergeMontage);
	run("8-bit");
	resetMinAndMax;
	saveAs("tiff", dir + insetMergeMontage);
selectWindow(VarMaskInset);
	run("8-bit");
	resetMinAndMax;
	saveAs("tiff", dir + VarMaskInset);
selectWindow(merge_montage);
	run("8-bit");
	saveAs("tiff", dir + merge_montage);
	resetMinAndMax;
selectWindow(ref_merge);
	run("Flatten");
	run("8-bit");
	resetMinAndMax;
	saveAs("tiff", dir + ref_merge);
selectWindow(labeledMontage);
rename(labeledMontage + "_16");
Stack.getDimensions(width, height, channels, slices, frames);
	run("8-bit");
	rename(labeledMontage);
	labeledMontage = getTitle();
	resetMinAndMax;
	saveAs("tiff", dir + labeledMontage);
}


function twoChannelMontage() {

//Process image for proper montaging
makeRectangle(20, 20, 180, 180);
waitForUser("Place selection box over vacuole. \n default is 200px X 200px");
	getSelectionBounds(x, y, width, height);
	Table.set("XY coordinates", 0, ""+x+","+y+"");
	Table.set("window size width (px)", 0, width);
	Table.set("window size height (px)", 0, height);

run("Crop");
merge = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
	frameInterval = Stack.getFrameInterval();
	selectWindow(tableName);
	Table.set("Frame interval", 0, frameInterval);
selectWindow(merge);
run("Split Channels");
selectWindow("C1-"+merge);
	run("Bleach Correction", "correction=[Exponential Fit]");
	c1=getTitle();
	close("y = a*exp(-bx) + c");
selectWindow("C2-"+merge);
	run("Bleach Correction", "correction=[Exponential Fit]");
	c2=getTitle();
	close("y = a*exp(-bx) + c");
run("Merge Channels...", "c1="+c1+" c2="+c2+" create");
rename(merge+"_DUP");
merge = getTitle();



//                   Montage begin
//===========================================================//
			if (frames > 135) {
				frames = 135;
				}
			defaultinc = 20;
			defaultframes = 61;

			selectWindow(merge);
			run("Make Composite");

			// My modified Make Montage
			Dialog.createNonBlocking("Jacob's Montage");
			Dialog.addMessage("NOTE: When making a montage, both the first and last frame appear in the panel. \n i.e. a 10 panel montage of frames 40-80 with an increment of 4 will only go to 76");
			Dialog.addMessage("NOTE: When making a montage, both the first and last frame appear in the panel."
			+ "\n \n i.e. 4 panel montages with an increment of 4 have 12 frames from first to last (4,8,12,16)");
			Dialog.addNumber("Columns:", 1);
			Dialog.addNumber("Rows:", 4);
			Dialog.addNumber("Scale factor:", 1);
			Dialog.addNumber("First slice:", 1);
			Dialog.addNumber("Last slice:", 61);
			Dialog.addNumber("Increment:", 20);
			Dialog.addNumber("Border width:", 0);
			
			Dialog.addCheckbox("Use foreground color", false);
					
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
				
				//adding values to recording table
				selectWindow(tableName);
				Table.set("Columns", i, columns);
				Table.set("Rows", i, rows);
				Table.set("scaleFactor", i, scale_factor);
				Table.set("firstSlice", i, first_slice);
				Table.set("lastSlice", i, last_slice);
				Table.set("montageFrameIncrement", i, increment);
				Table.set("borderWidth", i, border_width);
				Table.set("useForegroundColor", i, use_foreground_color);
				
			// inString  = Dialog.getString();
			// inChoice  = Dialog.getChoice();
			// inBoolean = Dialog.getCheckbox();
	
				if (use_foreground_color == 0) {
					use_foreground_color = "";
				}
				else {
					use_foreground_color = " use";
				}


	
//	Dialog.createNonBlocking("Channel color chooser");
//	Dialog.addMessage("can be black, blue, cyan, darkGray, gray, green, lightGray, magenta, orange, pink, red, white, yellow, or a hex value like #ff0000.");
//	Dialog.addString("Channel 1", "green");
//	Dialog.addString("Channel 2", "magenta");
//	Dialog.show();
//	c1Color = Dialog.getString();
//	c2Color = Dialog.getString();
	selectWindow(merge);
	run("Split Channels");
	selectWindow("C1-" + merge);
	c1 = getTitle();
	run("Green");
	selectWindow("C2-" + merge);
	c2 = getTitle();
	run("Magenta");
	run("Merge Channels...", "c1="+c1+" c2="+c2+" create keep");

	
	
	// figure montage
			selectWindow(merge);
			run("Make Montage...", "columns=" + columns + " rows=" + rows + 
			" scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + 
			" increment=" + increment + " border=" + border_width + use_foreground_color);
			rename(merge+"_montage");
			merge_montage = getTitle();
	// figure montage
			selectWindow(c1);
			run("Make Montage...", "columns=" + columns + " rows=" + rows + 
			" scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + 
			" increment=" + increment + " border=" + border_width + use_foreground_color);
			rename(c1+"_montage");
			c1Montage = getTitle();
	// figure montage
			selectWindow(c2);
			run("Make Montage...", "columns=" + columns + " rows=" + rows + 
			" scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + 
			" increment=" + increment + " border=" + border_width + use_foreground_color);
			rename(c2+"_montage");
			c2Montage = getTitle();

	// labeled montage
			selectWindow(merge);
			run("Make Montage...", "columns=" + columns + " rows=" + rows + 
			" scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + 
			" increment=" + increment + " border=" + border_width + use_foreground_color + " label");
			rename(merge + "_labeledMontage");
			labeledMontage = getTitle();
			
			// inset begin
			selectWindow(merge);
			run("Duplicate...", "title="+merge+"_ref duplicate frames=1");
			ref_merge = getTitle();
			
			selectWindow(merge);
			makeRectangle(60, 60, 60, 60);
			waitForUser("Place selection box over desired inset, "
			+ "or change desired inset box size. \n default is 60px X 60px");
					getSelectionBounds(x, y, width, height);
					selectWindow(tableName);
					Table.set("inset XY coordinates", 0, ""+x+","+y+"");
					Table.set("inset window size width (px)", 0, width);
					Table.set("inset window size height (px)", 0, height);
					Table.update;
			run("Select Bounding Box");
			roiManager("Add");
			roiManager("select", 0);
			roiManager("rename", "inset");
			selectWindow(ref_merge);
			roiManager("select", 0);
			Roi.setAntiAlias(false);
			Roi.setStrokeColor(255, 255, 255);
			Roi.setStrokeWidth(2);
			Overlay.addSelection
			selectWindow(merge);
			roiManager("select", 0);
			run("Duplicate...", "title="+merge+"_inset duplicate");
			insetMerge = getTitle();
			
//                   Inset montage begin
//===========================================================//

			//merge	inset
			run("Make Montage...", "columns=" + columns + " rows=" + rows
			+ " scale=" + scale_factor + " first=" + first_slice + " last="
			+ last_slice + " increment=" + increment + " border=" + border_width
			+ use_foreground_color);
			rename(merge+"_insetMontage");
			insetMergeMontage = getTitle();
			
			//merge inset varmask
			selectWindow(insetMerge);
			run("Duplicate...", "title="+insetMerge+"_VarMask duplicate");
			run("Gaussian Blur...", "sigma=1");
			run("Variance...", "radius=1");
			run("RGB Color", "frames");
			insetMergeVarMask = getTitle();
			run("Make Montage...", "columns=" + columns + " rows=" + rows
			+ " scale=" + scale_factor + " first=" + first_slice + " last="
			+ last_slice + " increment=" + increment + " border=" + border_width
			+ use_foreground_color);
			rename(insetMerge+"VarMaskMontage");
			insetMergeVarMaskMontage = getTitle();
			
			
			//split to single channels for montages
			selectWindow(insetMerge);
			run("Split Channels");
			
		//C1
			//c1 inset
			selectWindow("C1-" + insetMerge);
			c1=getTitle();
			run("Make Montage...", "columns=" + columns + " rows=" + rows
			+ " scale=" + scale_factor + " first=" + first_slice + " last="
			+ last_slice + " increment=" + increment + " border=" + border_width
			+ use_foreground_color);
			rename(c1+"_Montage");
			c1InsetMontage = getTitle();
			
			//c1 inset varmask
			selectWindow(c1);
			run("Duplicate...", "title=" + c1 + "_VarMask duplicate");
			run("Gaussian Blur...", "sigma=1");
			run("Variance...", "radius=1");
			c1InsetVarMask = getTitle();
			run("Make Montage...", "columns=" + columns + " rows=" + rows
			+ " scale=" + scale_factor + " first=" + first_slice + " last="
			+ last_slice + " increment=" + increment + " border=" + border_width
			+ use_foreground_color);
			rename(c1+"_insetVarMaskMontage");
			c1InsetVarMaskMontage = getTitle();
		//C2
			//c2 inset
			selectWindow("C2-" + insetMerge);
			run("Make Montage...", "columns=" + columns + " rows=" + rows
			+ " scale=" + scale_factor + " first=" + first_slice + " last="
			+ last_slice + " increment=" + increment + " border=" + border_width
			+ use_foreground_color);
			rename(c2+"_insetMontage");
			c2InsetMontage = getTitle();
			
			//c2 inset varmask
			selectWindow(c2);
			run("Duplicate...", "title=" + c2 + "_VarMask duplicate");
			run("Gaussian Blur...", "sigma=1");
			run("Variance...", "radius=1");
			c2InsetVarMask = getTitle();
			run("Make Montage...", "columns=" + columns + " rows=" + rows
			+ " scale=" + scale_factor + " first=" + first_slice + " last="
			+ last_slice + " increment=" + increment + " border=" + border_width
			+ use_foreground_color);
			rename(c2+"_insetVarMaskMontage");
			c2InsetVarMaskMontage = getTitle();
			
			
			roiManager("delete");
			
//                      Montage end
//===========================================================//


//===============================//
//		saving everything
//===============================//

//merged inset
selectWindow(insetMergeMontage);
	run("RGB Color");
	saveAs("tiff", dir + insetMergeMontage);
	close();
//c1 inset
selectWindow(c1InsetMontage);
	run("RGB Color");
	saveAs("tiff", dir + c1InsetMontage);
	close();
//c2 inset
selectWindow(c2InsetMontage);
	run("RGB Color");
	saveAs("tiff", dir + c2InsetMontage);
	close();
//merge varmask montage
selectWindow(insetMergeVarMaskMontage);
	saveAs("tiff", dir + insetMergeVarMaskMontage);
	close();
//c1 varmask montage
selectWindow(c1InsetVarMaskMontage);
	run("RGB Color");
	saveAs("tiff", dir + c1InsetVarMaskMontage);
	close();
//c2 varmask montage
selectWindow(c2InsetVarMaskMontage);
	run("RGB Color");
	saveAs("tiff", dir + c2InsetVarMaskMontage);
	close();
//merge fullsize montage
selectWindow(merge_montage);
	run("RGB Color");
	saveAs("tiff", dir + merge_montage);
	close();
	selectWindow(merge_montage);
	close();
//c1 fullsize montage
selectWindow(c1Montage);
	run("RGB Color");
	saveAs("tiff", dir + c1Montage);
	close();
//c2 fullsize montage
selectWindow(c2Montage);
	run("RGB Color");
	saveAs("tiff", dir + c2Montage);
	close();
//reference box for inset
selectWindow(ref_merge);
	run("Flatten");
	run("RGB Color");
	saveAs("tiff", dir + ref_merge);
	close();
//fullsize montage with frame numbers
selectWindow(labeledMontage);
Stack.getDimensions(width, height, channels, slices, frames);
	run("RGB Color");
	labeledMontage = getTitle();
	saveAs("tiff", dir + labeledMontage);
	close();
}