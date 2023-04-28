// the first step is to create a .csv file containing the full path to the directories you want to describe using this script
// don't forget to put a header in cell A1, otherwise your first entry will become the header!

TableDir = getDir("Choose the directory containing the .csv file");
TableList = getFileList(TableDir);
for (i=0; i < TableList.length; i++) {
	if (matches(TableList[i], ".*.csv") == true) {
		newTableList = Array.concat(newTableList,TableList[i]);
	}
}
newTableList = Array.deleteIndex(newTableList, 0);
TableList = newTableList;

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
TimeString =""+year+"";
		    
if (month < 10) {TimeString = TimeString+"0";}
	TimeString = TimeString+month; 
if (dayOfMonth<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+dayOfMonth; 
if (hour<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+hour;
if (minute<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+minute;

Dialog.createNonBlocking("Choose a .csv file to begin");
Dialog.addChoice(".csv file", TableList);
Dialog.show();

TablePath = Dialog.getChoice();

Table.open(TableDir + TablePath);
list = Table.getColumn("imagePath");
close(TablePath);

EmptyArray = newArray(list.length);
indices = newArray(list.length);
for (i=1; i < indices.length; i++) {
	indices[i] = i;
	}

Table.create(TablePath);
Table.setColumn("Index", indices);
Table.setColumn("imagePath", list);
Table.update;

// Choose whether you want to loop through entire folder or choose a specific image
//if (getBoolean("Do you want to loop through the whole list,"
//+ "or choose to start at a specific image set?", "Loop", "Choose") == false) {
//Adds the option to continue choosing different imaging sets
	while (getBoolean("Do you want to initiate/"
	+ "continue picking image sets or abort the macro?", "Continue", "Abort") == true) {

		Dialog.createNonBlocking("Choose a specific image set");
			Dialog.addChoice("Image Set", list);
		Dialog.show();	
		img_set = Dialog.getChoice();

		TableSplit = split(img_set, "\\");
		for (var i=0; i < TableSplit.length; i++) {
		}
		
		TableName = TableSplit[i-1];
		
		TableName = "notes_" + TableName;
		
// returns the index of the chosen image set for correctly applying the recorded data to it		
		for (i=0; i < list.length; i++) {
			if (list[i] == img_set) {
				index = Table.get("Index", i);	
			}
		}
		image_list = getFileList(list[index] + File.separator + "unprocessed" + File.separator);	
			
		Dialog.create("Choose a specific image");
			Dialog.addChoice("Starting image", image_list);
		Dialog.show();
		StartingImage = Dialog.getChoice();
		for (i=0; i < image_list.length; i++) {
			if (image_list[i] == StartingImage) {
				DvArray = Array.slice(image_list,i);
			}
		}
		
		
		// counts the number of opened images by the following for looop with q
		q = 0;
		r3dArray = newArray();
		// Loop that goes through all .dv's in a single directory
			for (j=0; j < DvArray.length; j++) {
				if (matches(DvArray[j], ".*_R3D.dv$") == true) {
					r3dArray = Array.concat(r3dArray,DvArray[j]); 
					run("Bio-Formats Windowless Importer", "open=" + list[index] + File.separator + "unprocessed" + File.separator + DvArray[j]);
					run("Original Scale");
					q++;
				}
			}
	
		run("Tile");
		
		Dialog.createNonBlocking("TableBuilder");
		Dialog.addMessage("Type a comma-separated list of "
		+ "descriptive categories you want to be able to have for each describing the phenotypes."
		+ "\nIt's reccomended to put at least a few extra categories more than you think you will need, "
		+ "even if their titles are only 'descriptor1','descriptor2' etc. so that you can organize any new findings.");
		Dialog.addString("List of descriptors", "myof, organelle, colocalization, D1, D2", 50);
		Dialog.show();
		ColumnArray = Dialog.getString();
		
		ColumnArray = split(ColumnArray, ",");
		
		indices = newArray(r3dArray.length);
		EmptyArray = newArray(r3dArray.length);
		for (i=1; i < indices.length; i++) {
			indices[i] = i;
		}
		Table.create(img_set);
		Table.setColumn("Index", indices);
		Table.setColumn("ImageNumber", r3dArray);
		Table.setColumn("VacNumber", EmptyArray);
		Table.setColumn("Cell Cycle", EmptyArray);
		for (i = 0; i < ColumnArray.length; i++) {
			Table.setColumn(ColumnArray[i], EmptyArray);
		}
		for (j=0; j < r3dArray.length; j++) {
			selectWindow(r3dArray[j]);
			Stack.getDimensions(width, height, channels, slices, frames);
			if ((slices>1)==true && (channels>1)==true && (frames>1)==true) {
				run("Z Project...", "projection=[Max Intensity] all");
				run("*Split Channels [F1]");
				run("Merge Channels...", "c2=C1-MAX_" + r3dArray[j] + " c6=C2-MAX_" + r3dArray[j] + " create ignore");
				run("*Split Channels [F1]");
				run("Merge Channels...", "c1=C1-MAX_" + r3dArray[j] + " c2=C2-MAX_" + r3dArray[j] + " create keep");
				CenterAndZoomTwoChannelZ();
			}
			if ((slices==1)==true && (channels>1)==true && (frames>1)==true) {
				run("*Split Channels [F1]");		
				run("Merge Channels...", "c2=C1-" + r3dArray[j] + " c6=C2-" + r3dArray[j] + " create ignore");
				run("*Split Channels [F1]");
				run("Merge Channels...", "c1=C1-" + r3dArray[j] + " c2=C2-" + r3dArray[j] + " create keep");
				CenterAndZoomTwoChannel();
			}
			if ((slices==1)==true && (channels==1)==true && (frames>1)==true) {
				CenterAndZoomOneChannel();
					doCommand("Start Animation [\\]");
			}
			if ((slices>1)==true && (channels==1)==true && (frames==1)==true) {
				run("Z Project...", "projection=[Max Intensity] all");
				CenterAndZoomOneChannel();
			}
					
			ObservationsWindow();
			
			Table.save(TableDir + TableName + "_" + TimeString + ".csv");
			close("*" + r3dArray[j] + "*");
		}
		
		showMessage("Table saved to: " + TableDir + TableName + "_" + TimeString + ".csv");
	}


//
//// Loop that goes through the entire .csv file of directories
//for (i=0; i < list.length; i++) {
//	image_list = getFileList(list[i] + File.separator + "unprocessed" + File.separator);	
//	q = 0;
//// Loop that goes through all .dv's in a single directory
//	for (j=0; j < image_list.length; j++) {
//		if (endsWith(image_list[j], "R3D.dv")) {
//			run("Bio-Formats Windowless Importer", "open=" + list[i] + File.separator + "unprocessed" + File.separator + image_list[j]);
//			run("Original Scale");
//			q++;
//		}
//	}
//	run("Tile");
//}
//




function ObservationsWindow() {

VacNumber = newArray("1", "2", "4", "4+");

// dialog for recording phenotypes
	Dialog.createNonBlocking("ObservationStation");
		Dialog.addMessage("Image directory name: " + list[index] + ""
		+ "\n\n\nNumber of images in this directory: " + q + ""
		+ "\n \nActive Image: " + r3dArray[j]);
		Dialog.setLocation(10,10);
			Dialog.addChoice("# of parasites in vacuole", VacNumber, "2");
			Dialog.addCheckbox("Interphase", false);
			Dialog.addCheckbox("Daughter formation", false);
			for (i=0; i < ColumnArray.length; i++) {Dialog.addString(ColumnArray[i], "initialText", 100);}	
			Dialog.show();
			variable = Array.getSequence(ColumnArray.length);
	  		for (i = 0; i < variable.length; i++) {variable[i] = ColumnArray[i];}
  			VacNumber = Dialog.getChoice();
  			Table.set("VacNumber", j, VacNumber);
			interphase = Dialog.getCheckbox();
			DaughterFormation = Dialog.getCheckbox();
			if (interphase == true) {CellCycle = "Interphase";}
			if (DaughterFormation == true) {CellCycle = "Daughter Formation";}
			Table.set("Cell Cycle", j, CellCycle);
			for (i=0; i < ColumnArray.length; i++) {variable[i] = Dialog.getString();}
			for (i=0; i < ColumnArray.length; i++) {Table.set(ColumnArray[i], j, variable[i]);}	
			Table.update;
			
	while ((interphase != true) && (DaughterFormation != true)) {
			Dialog.create("You didn't choose a cell cycle stage");
			Dialog.addChoice("# of parasites in vacuole", VacNumber, "2");
			Dialog.addCheckbox("Interphase", false);
			Dialog.addCheckbox("Daughter formation", false);
			for (i=0; i < ColumnArray.length; i++) {Dialog.addString(ColumnArray[i], "initialText", 100);}	
			Dialog.show();
			variable = Array.getSequence(ColumnArray.length);
	  		for (i = 0; i < variable.length; i++) {variable[i] = ColumnArray[i];}
  			VacNumber = Dialog.getChoice();
  			Table.set("VacNumber", j, VacNumber);
			interphase = Dialog.getCheckbox();
			DaughterFormation = Dialog.getCheckbox();
			if (interphase == true) {CellCycle = "Interphase";}
			if (DaughterFormation == true) {CellCycle = "Daughter Formation";}
			Table.set("Cell Cycle", j, CellCycle);
			for (i=0; i < ColumnArray.length; i++) {variable[i] = Dialog.getString();}
			for (i=0; i < ColumnArray.length; i++) {Table.set(ColumnArray[i], j, variable[i]);}	
			Table.update;
	}
}

function CenterAndZoomTwoChannelZ() {
	
		selectWindow("C1-MAX_" + r3dArray[j]);
			setLocation(screenWidth/55, screenHeight/4);
			run("Magenta");
			showMessage("C1 selected");
			doCommand("Start Animation [\\]");
		selectWindow("C2-MAX_" + r3dArray[j]);
			c2 = getTitle();
			selectWindow(c2);
			setLocation(screenWidth/3.1, screenHeight/4);
			run("Green");
			showMessage("C2 selected");
			doCommand("Start Animation [\\]");
		}
		if (matches(windowArray[i], "(?<!C[0-9]).*" + r3dArray[j])) {
			merged = getTitle();
			selectWindow(merged);
			setLocation(screenWidth/1.6, screenHeight/4);
			Stack.setChannel(1);
			run("Magenta");
			Stack.setChannel(2);
			run("Green");	
			showMessage("merge selected");
			doCommand("Start Animation [\\]");
		}
	}
}

function CenterAndZoomTwoChannel() {
	
		selectWindow("C1-" + r3dArray[j]);
			setLocation(screenWidth/55, screenHeight/4);
			run("Magenta");
			run("In [+]");
			run("In [+]");
			doCommand("Start Animation [\\]");
		selectWindow("C2-" + r3dArray[j]);
			c2 = getTitle();
			selectWindow(c2);
			setLocation(screenWidth/3.1, screenHeight/4);
			run("Green");
			run("In [+]");
			run("In [+]");
			doCommand("Start Animation [\\]");
		
		selectWindow(r3dArray[j]);
			setLocation(screenWidth/1.6, screenHeight/4);
			Stack.setChannel(1);
			run("Magenta");
			Stack.setChannel(2);
			run("Green");
			selectWindow(r3dArray[j]);
			run("In [+]");
			run("In [+]");	
			doCommand("Start Animation [\\]");
		}
	}
}

function CenterAndZoomOneChannel() {
	selectWindow(title);
		setLocation(screenWidth/3, screenHeight/4);
		run("In [+]");
		run("In [+]");
		run("Grays");
}




