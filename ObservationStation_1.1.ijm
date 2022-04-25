TableDir = getDir("Choose the directory containing the .csv file");
TableList = getFileList(TableDir);

Dialog.createNonBlocking("Choose a .csv file to begin");
Dialog.addChoice(".csv file", TableList);
Dialog.show();

TablePath = Dialog.getChoice();

Table.open(TableDir + TablePath);
list = Table.getColumn("ImagePath");
close(TablePath);

EmptyArray = newArray(list.length);
indices = newArray(list.length);
for (i=1; i < indices.length; i++) {
	indices[i] = i;
	}

Table.create(TablePath);
Table.setColumn("Index", indices);
Table.setColumn("ImagePath", list);
Table.setColumn("Description", EmptyArray);
Table.setColumn("Conclusion", EmptyArray);
Table.setColumn("Need more?", EmptyArray);
Table.update;

// Choose whether you want to loop through entire folder or choose a specific image
if (getBoolean("Do you want to loop through the whole list,"
+ "or choose to start at a specific image set?", "Loop", "Choose") == false) {
//Adds the option to continue choosing different imaging sets
	while (getBoolean("Do you want to initiate/"
	+ "continue picking image sets or abort the macro?", "Continue", "Abort") == true) {

		Dialog.createNonBlocking("Choose a specific image set");
		Dialog.addChoice("Image Set", list);
		Dialog.show();
			
		img = Dialog.getChoice();

// returns the index of the chosen image set for correctly applying the recorded data to it		
		for (i=0; i < list.length; i++) {
			if (list[i] == img) {
				index = Table.get("Index", i);	
			}
		}
		image_list = getFileList(list[index] + File.separator + "unprocessed" + File.separator);	
			q = 0;
		// Loop that goes through all .dv's in a single directory
			DvArray = newArray("");
			for (j=0; j < image_list.length; j++) {
				if (matches(image_list[j], ".*optimization.*")) {
					j++;
				}
				if (endsWith(image_list[j], "R3D.dv")) {
					DvArray = Array.concat(DvArray,image_list[j]);
					run("Bio-Formats Windowless Importer", "open=" + list[index] + File.separator + "unprocessed" + File.separator + image_list[j]);
					run("Original Scale");
					q++;
				}
			}
		run("Tile");
		run("Synchronize Windows");
		
		DvArray = Array.deleteIndex(DvArray, 0);
		
		Dialog.createNonBlocking("TableBuilder");
		Dialog.addMessage("Type a comma-separated list of "
		+ "descriptive categories you want to be able to have for each describing the phenotypes."
		+ "\nIt's reccomended to put at least a few extra categories more than you think you will need, "
		+ "even if their titles are only 'descriptor1','descriptor2' etc. so that you can organize any new findings.");
		Dialog.addString("List of descriptors", "-IAA overall, +IAA overall, D1, D2, D3, D4, D5", 100);
		Dialog.show();
		ColumnArray = Dialog.getString();
		
		ColumnArray = split(ColumnArray, ", ");
		
		indices = newArray(DvArray.length);
		EmptyArray = newArray(DvArray.length);
		for (i=1; i < indices.length; i++) {
			indices[i] = i;
		}
		Table.create(img);
		Table.setColumn("Index", indices);
		Table.setColumn("ImageNumber", DvArray);
		for (i = 0; i < ColumnArray.length; i++) {
			Table.setColumn(ColumnArray[i], EmptyArray);
		}
		for (j=0; j < DvArray.length; j++) {
			selectWindow(DvArray[j]);
			Table.setLocationAndSize(screenWidth/2, screenHeight/2, 512, 512);
			ObservationsWindow();
			close();
		}
		if (File.exists(TableDir + "processed_" + TablePath)) {
			z = 1
			while (File.exists(TableDir + "processed_" + z + "_" + TablePath) == true) {
				z++;	
			}
			Table.save(TableDir + "processed_" z + "_" + TablePath);
		}
		else {
		Table.save(TableDir + "processed_" + TablePath);
		}
	}
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

// dialog for recording phenotypes
	Dialog.createNonBlocking("ObservationStation_1.0");
		Dialog.addMessage("Image directory name: " + list[index] + ""
		+ "\n\n\nNumber of images in this directory: " + q + ""
		+ "\n \nActive Image: " + image_list[j]);
		for (i=0; i < ColumnArray.length; i++) {
			Dialog.addString(ColumnArray[i], "initialText", 100);	
		}
	Dialog.show();
	
		variable = Array.getSequence(ColumnArray.length);
	  	for (i = 0; i < variable.length; i++) {
      		variable[i] = ColumnArray[i];
  		}
	
	for (i=0; i < ColumnArray.length; i++) {
		variable[i] = Dialog.getString();
	}
	for (i=0; i < ColumnArray.length; i++) {
		Table.set(ColumnArray[i], j, variable[i]);
	}	
	Table.update;
}









