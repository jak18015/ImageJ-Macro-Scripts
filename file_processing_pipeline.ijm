macro "File Processing Pipeline" {

// activate which dir you would like to use, pick the directory or paste in the directory
// If you choose the "Choose" option, you'll need to turn off both second lines	
	dir = getDirectory("Choose the file with images"); 
	
	unprocessed = dir + "/" + "unprocessed" + "/";
	File.makeDirectory(unprocessed);
	
	processed = dir + "/" + "processed" + "/";
	File.makeDirectory(processed);
	
	backup = dir + "/" + "backup" + "/";
	File.makeDirectory(backup);
	
	filelist = getFileList(dir) 
	for (i = 0; i < lengthOf(filelist); i++) { 
		File.getName(filelist[i]);
	// dv files	
		if (endsWith(filelist[i], ".dv") == true) {
			File.copy(dir + filelist[i], backup + filelist[i]);
			File.rename(dir + filelist[i], unprocessed + filelist[i]);
		}
	// log files
		if (endsWith(filelist[i], ".log") == true) {
			File.copy(dir + filelist[i], backup + filelist[i]);
			File.rename(dir + filelist[i], unprocessed + filelist[i]);
		}
	// txt files
		if (endsWith(filelist[i], ".txt") == true) {
			File.copy(dir + filelist[i], backup + filelist[i]);
			File.rename(dir + filelist[i], unprocessed + filelist[i]);
		}
	// joblog files
		if (endsWith(filelist[i], ".joblog") == true) {
			File.copy(dir + filelist[i], backup + filelist[i]);
			File.rename(dir + filelist[i], unprocessed + filelist[i]);
		}
	}
	
	print("Done!");
}