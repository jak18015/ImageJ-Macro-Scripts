Dialog.createNonBlocking("Phenotype Binner");
Dialog.addMessage("Create a comma-separated list of terms to bin your images \nOnly 4 bins set right now, can add more in code");
Dialog.addString("Name the result table containing your binned images", "daughter cell presence", 50);
Dialog.addString("Phenotypes:", "cytosolic and peripheral, vesicular, residual body, apical extracellular", 100);
Dialog.addString("input the directory path where you want your table to be saved", "C:\\");
Dialog.show();
tablename = Dialog.getString();
choices = Dialog.getString();
path = Dialog.getString();
choice_array = split(choices, ",");
Table.showArrays("Results", choice_array);
choice_number = nResults;
run("Clear Results");

waitForUser("open all images before clicking ok");

bin = newArray(0);
Table.setColumn("Path", bin);
Table.setColumn("Image", bin);

for (i=0; i < choice_number; i ++) {
	Table.setColumn(choice_array[i], bin);
	}
	
Table.setLocationAndSize(10, 200, 600, 800);


image_name_array = getList("image.titles");

for (i=0; i < nImages; i++) {
		selectWindow(image_name_array[i]);
		image_dir = getDirectory("image");
		image_fullname = image_dir + image_name_array[i];
		image_path_array = Array.concat(image_path_array,image_fullname);
	}

image_path_array = Array.deleteIndex(image_path_array, 0);

Table.setColumn("Path", image_path_array);
Table.setColumn("Image", image_name_array);

for (i=0; i < image_name_array.length; i++) {
	selectWindow(image_name_array[i]);
	run("Original Scale");
	run("-");
	run("-");
	run("-");
	run("-");
}
run("Cascade");
selectWindow("Results");
 
for (i=0; i < image_name_array.length; i++) {
	selectWindow(image_name_array[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Original Scale");
	Table.setLocationAndSize(screenWidth/2,screenHeight/2, width, height, image_name_array[i]);
	run("In [+]");
	selectWindow("name");
	Dialog.createNonBlocking("Phenotype Binner");
	for (j=0; j < choice_number; j++) {
		Dialog.addCheckbox(choice_array[j], false);
	}
	Dialog.setLocation(10,10);
	Dialog.show();

	
	if (choice_number == 1) {
		checkbox_0 = Dialog.getCheckbox();
		for (l = 0; l < nResults; l++) {
			if (getResultString("Image", l) == image_name_array[i])
				setResult(choice_array[0], l, checkbox_0);
		}
	}
	if (choice_number == 2) {
		checkbox_0 = Dialog.getCheckbox();
		checkbox_1 = Dialog.getCheckbox();
		for (l = 0; l < image_name_array.length; l++) {
			if (getResultString("Image", l) == image_name_array[i])
				setResult(choice_array[0], l, checkbox_0);
				setResult(choice_array[1], l, checkbox_1);
		}
	}	
	if (choice_number == 3) {
		checkbox_0 = Dialog.getCheckbox();
		checkbox_1 = Dialog.getCheckbox();		
		checkbox_2 = Dialog.getCheckbox();
		for (l = 0; l < nResults; l++) {
			if (getResultString("Image", l) == image_name_array[i])
				setResult(choice_array[0], l, checkbox_0);
				setResult(choice_array[1], l, checkbox_1);
				setResult(choice_array[2], l, checkbox_2);
		}
	}	
	if (choice_number == 4) {
		checkbox_0 = Dialog.getCheckbox();
		checkbox_1 = Dialog.getCheckbox();		
		checkbox_2 = Dialog.getCheckbox();
		checkbox_3 = Dialog.getCheckbox();
		for (l = 0; l < nResults; l++) {
			if (getResultString("Image", l) == image_name_array[i])
				setResult(choice_array[0], l, checkbox_0);
				setResult(choice_array[1], l, checkbox_1);
				setResult(choice_array[2], l, checkbox_2);
				setResult(choice_array[3], l, checkbox_3);
		}
	}
	updateResults();	

}



selectWindow("Results");
Table.rename("Results", tablename);
Table.save(path + File.separator + tablename + ".csv");
run("Close All");
wait(5000);
close(tablename);
wait(1000);
run("Close All");