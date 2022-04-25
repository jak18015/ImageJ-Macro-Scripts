  print("\\Clear");
  dir = getDirectory("Choose a Directory ");
  count = 1;
  list = newArray("");
  FolderFiles(dir);
for (i=0; i < list.length; i++) {
		print(list[i]);	
}
  function FolderFiles(dir) {
     folder_list = getFileList(dir);



     for (i=0; i<folder_list.length; i++) {
        if (endsWith(folder_list[i], "/"))
        	subdirectory = File.getDirectory(folder_list[i]);
        	for (i=0; i < subdirectory.length; i++) {
        		if (endsWith(subdirectory[i], "/")) {
        			
        			}
        		}
           list = Array.concat(list,(""+dir+folder_list[i]));
        else
           print((count++) + ": " + dir + folder_list[i]);
     }
  }

// for (i=0; i < folder_list.length; i++) {
//		print(folder_list[i]);	
//	}
     
  //   waitForUser