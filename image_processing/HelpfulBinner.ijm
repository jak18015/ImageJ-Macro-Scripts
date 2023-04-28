Dialog.createNonBlocking("Phenotype Binner");
Dialog.addMessage("Create a comma-separated list of terms to bin your images \nOnly 4 bins set right now, can add more in code");
Dialog.addString("Name the result table containing your binned images", "actinLocalizations", 50);
Dialog.addString("Phenotypes:", "residualBody, cytosolic, peripheral", 100);
Dialog.addString("input the directory path where you want your table to be saved", "Z:\\Jacob\\R\\Projects\\myofActinLocalizations");
Dialog.show();
tablename = Dialog.getString();
choices = Dialog.getString();
path = Dialog.getString();
choice_array = split(choices, ",");


waitForUser("open all images before clicking ok");

len = getValue("results.count");
bin = newArray(len);
Table.setColumn("Path", bin);
Table.setColumn("Image", bin);
Table.setColumn(choice_array[0], bin);
Table.setColumn(choice_array[1], bin);

Table.setLocationAndSize(10, 200, 600, 800);
Table.showRowIndexes(true);
Table.showRowNumbers(false);

image_namelist = getList("image.titles");



for (i=0; i < image_namelist.length; i++) {
		selectWindow(image_namelist[i]);
		image_dir = getDirectory("image");
		image_fullname = image_dir + image_namelist[i];
		image_array = Array.concat(image_array,image_fullname);
	}
	
image_array = Array.deleteIndex(image_array, 0);


for (i=0; i < image_namelist.length; i++) {
	selectWindow(image_namelist[i]);
	run("Original Scale");
	run("-");
	run("-");
	run("-");
	run("-");
}
run("Cascade");
selectWindow("Results");
 
for (i=0; i < image_namelist.length; i++) {
	selectWindow(image_namelist[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	resetMinAndMax;
	run("Original Scale");
	Table.setLocationAndSize(screenWidth/5,screenHeight/5, 768, 768, image_namelist[i]);
	zoom = getZoom();
	while (zoom < 4) {
		run("In [+]");
		zoom = getZoom();
	}
	if (slices > 1) {
		Stack.setSlice(round(slices/2));
	}
	if (frames > 1) {
		doCommand("Start Animation");
	}
	Table.set("Path", i, image_array[i]);
	Table.set("Image", i, image_namelist[i]);
	Dialog.createNonBlocking("Phenotype Binner");
	Dialog.addCheckbox(choice_array[0], false);
	Dialog.addCheckbox(choice_array[1], true);
	Dialog.addCheckbox(choice_array[2], true);

	Dialog.setLocation(10,10);
	Dialog.show();

	a1 = Dialog.getCheckbox();
	a2 = Dialog.getCheckbox();
	a3 = Dialog.getCheckbox();
	if (frames > 1) {
		selectWindow(image_namelist[i]);
		doCommand("Stop Animation");
	}	
	selectWindow("Results");
	for (j=0; j < nResults; j++) {
		if (getResultString("Image", j) == image_namelist[i]) {
			setResult(choice_array[0], j, a1);
			setResult(choice_array[1], j, a2);
			setResult(choice_array[2], j, a3);

			updateResults();
			}
	} 

}

selectWindow("Results");
Table.rename("Results", tablename);
Table.save(path + File.separator + tablename + ".csv");