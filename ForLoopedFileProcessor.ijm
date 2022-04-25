Table.open("C:\\Users\\jakek\\OneDrive\\Desktop\\ProcessDirectories.csv");
list = Table.getColumn("FilePaths");

for (i=66; i < list.length; i++) {
	sublist = getFileList(list[i]);
	for (j=0; j < sublist.length; j++) {
		if (matches(sublist[j], ".*Backup.*") == true) {
			backup = 1;
			}
		else {
			backup = 0;
		}
		if (matches(sublist[j], ".*Unprocessed.*") == true) {
			unprocessed = 1;
			}
		else {
			unprocessed = 0;
		}
		if (matches(sublist[j], ".*Proccesed.*") == true) {
			processed = 1;
			}
		else {
			processed = 0;
		}
	}
	if (backup + unprocessed + processed != 3) {
		dir = list[i];
		ProcessDir();
		}
}



function ProcessDir() {

	filelist = getFileList(dir);
	
	
	unprocessed = dir + "/" + "unprocessed" + "/";
	File.makeDirectory(unprocessed);
	
	processed = dir + "/" + "processed" + "/";
	File.makeDirectory(processed);
	
	backup = dir + "/" + "backup" + "/";
	File.makeDirectory(backup);
	
	Array.print(filelist);
	
	for (i = 0; i < filelist.length; i++) { 
		print(i + ": " + filelist[i]); 
	// dv files	
		if (endsWith(filelist[i], ".dv") == true) {
			print("dir: " + dir);
			print("filelist[i]: " + filelist[i]);
			print("backup: " + backup);

			File.copy(dir + File.separator + filelist[i], backup + filelist[i]);
			File.rename(dir + File.separator + filelist[i], unprocessed + filelist[i]);
		}
	// log files
		if (endsWith(filelist[i], ".log") == true) {
			File.copy(dir + File.separator + filelist[i], backup + filelist[i]);
			File.rename(dir + File.separator + filelist[i], unprocessed + filelist[i]);
		}
	// txt files
		if (endsWith(filelist[i], ".txt") == true) {
			File.copy(dir + File.separator + filelist[i], backup + filelist[i]);
			File.rename(dir + File.separator + filelist[i], unprocessed + filelist[i]);
		}
	// joblog files
		if (endsWith(filelist[i], ".joblog") == true) {
			File.copy(dir + File.separator + filelist[i], backup + filelist[i]);
			File.rename(dir + File.separator + filelist[i], unprocessed + filelist[i]);
		}
	}
	
	print("Done!");
}