dir = "Z:\\Jacob\\Microscopy\\20210620_MyoF-AID_AC-EmFP_fixationconditions\\";

  count = 1;
  listFiles(dir); 

  function listFiles(dir) {
     list = getFileList(dir);
     for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "/"))
           listFiles(""+dir+list[i]);
        else
           if(endsWith(list[i], "_R3D.dv")) {
           	open(dir + list[i]);
           }
     }
  }