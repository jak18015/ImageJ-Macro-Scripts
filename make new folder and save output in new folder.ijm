dir=getDirectory("Choose a Directory"); 
print(dir); 
splitDir= dir + "/OneChannel/";
print(splitDir); 
File.makeDirectory(splitDir); 
list = getFileList(dir); 

for (i=0; i<list.length; i++) { 
     if (endsWith(list[i], ".tif")){ 
               print(i + ": " + dir+list[i]); 
             open(dir+list[i]); 
             imgName=getTitle(); 
         baseNameEnd=indexOf(imgName, ".tif"); 
         baseName=substring(imgName, 0, baseNameEnd);
         run("Split Channels"); 
         selectWindow(imgName + " (blue)"); 
         close(); 
         selectWindow(imgName + " (green)"); 
         saveAs("Tiff",  splitDir + baseName "-AnkG.tif"); 
         close(); 
         selectWindow(imgName + " (red)");
         run("Close All"); 
     } else {
     write("One Channel Conversion is Complete");
     }
} 