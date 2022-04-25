output = getDirectory("Choose an Output Directory");
title = "test";
dir = output + "/" + title + "/";
File.makeDirectory(dir);
print(output);
print(dir);
File.saveString("test!", dir + ".txt");