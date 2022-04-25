dir = getDirectory("Choose a Directory ");
count = 1;
listFiles(dir); 
list = Table.getColumn("image");
run("Clear Results");

function listFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
			listFiles(""+dir+list[i]);
		else
			if (endsWith(list[i], ".tif") == true)
			Table.set("image", nResults, list[i]);
	}
}