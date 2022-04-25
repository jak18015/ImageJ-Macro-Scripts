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
	if (endsWith(filelist[i], ".dv") == true) {
		File.copy(dir + filelist[i], backup + filelist[i] + ".dv");
		File.rename(dir + filelist[i], unprocessed + filelist[i] + ".dv");
	}
	else {
		if (endsWith(filelist[i], ".log") == true) {
			File.copy(dir + filelist[i], backup + filelist[i] + ".log");
			File.rename(dir + filelist[i], unprocessed + filelist[i] + ".log");
		}
	}
	else {
		if (endsWith(filelist[i], ".txt") == true) {
			File.copy(dir + filelist[i], backup + filelist[i] + ".txt");
			File.rename(dir + filelist[i], unprocessed + filelist[i] + ".txt");
		}
	}
	else {
		if (endsWith(filelist[i], ".joblog") == true) {
			File.copy(dir + filelist[i], backup + filelist[i] + ".joblog");
			File.rename(dir + filelist[i], unprocessed + filelist[i] + ".joblog");
		}
	}
}

print("Done!");