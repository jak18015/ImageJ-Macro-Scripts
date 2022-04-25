dir = getDirectory("Choose the file with images");

filelist = getFileList(dir) 
for (i = 0; i < lengthOf(filelist); i++) { 
		File.getName(filelist[i]);
		if (endsWith(filelist[i], ".joblog.joblog")) {
			newname = File.getNameWithoutExtension(filelist[i]);
			File.rename(dir + filelist[i], dir + newname);
		}
			
}
for (i = 0; i < lengthOf(filelist); i++) { 
		File.getName(filelist[i]);
		if (endsWith(filelist[i], ".txt.txt")) {
			newname = File.getNameWithoutExtension(filelist[i]);
			File.rename(dir + filelist[i], dir + newname);
		}
			
}
for (i = 0; i < lengthOf(filelist); i++) { 
		File.getName(filelist[i]);
		if (endsWith(filelist[i], ".log.log")) {
			newname = File.getNameWithoutExtension(filelist[i]);
			File.rename(dir + filelist[i], dir + newname);
		}
			
}
for (i = 0; i < lengthOf(filelist); i++) { 
		File.getName(filelist[i]);
		if (endsWith(filelist[i], ".dv.dv")) {
			newname = File.getNameWithoutExtension(filelist[i]);
			File.rename(dir + filelist[i], dir + newname);
		}
			
}
print("done!");
