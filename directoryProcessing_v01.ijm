dir = getDirectory("image");
ProcessDir();

function ProcessDir() {

	filelist = getFileList(dir);
	
	
	unprocessed = dir + File.separator + "unprocessed" + File.separator;
	File.makeDirectory(unprocessed);
	
	processed = dir + File.separator + "processed" + File.separator;
	File.makeDirectory(processed);
	
	backup = dir + File.separator + "backup" + File.separator;
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