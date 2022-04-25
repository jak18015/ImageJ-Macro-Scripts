list = getList("image.titles");

Table.create("bestImages");
selectWindow(list[0]);
dir = getDirectory("image");
	dirArray = split(dir, "\\");
	dirArray = Array.deleteIndex(dirArray, 3);
	dir = String.join(dirArray, "\\") + "\\";
for (i=0; i < list.length; i++) {
	selectWindow(list[i]);
	title = getTitle();
	Table.set("Image", i, dir + title);
}
Table.save(dir + "bestImagesPlusIAA.csv");
