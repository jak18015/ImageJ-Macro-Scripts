output = getDirectory("Choose an output directory");
list = getList("image.titles");
for(i = 0; i<list.length; i++) {
	selectWindow(list[i]);
	save(output+list[i]+".tif");
}