list = getList("image.titles");
Table.create("bestImages");
for (i=0; i< list.length; i++) {
	selectWindow(list[i]);
	dir = getDirectory("image");
	Table.set("Path to image", i, dir + list[i]);
}

dirArray = split(dir, File.separator);
Dialog.create("which box indicates the folder name?");
Dialog.addChoice("Choose the folder that names the images", dirArray);
Dialog.show();
dirChoice = Dialog.getChoice();
for (j=0; j < dirArray.length; j++) {
	if (dirChoice == dirArray[j]) {
		dirStringArray = Array.slice(dirArray,0,j+1);
		dirString = String.join(dirStringArray, File.separator);
		print(dirString);
	}
}
Table.save(dirString + File.separator + "bestImages" + ".csv");