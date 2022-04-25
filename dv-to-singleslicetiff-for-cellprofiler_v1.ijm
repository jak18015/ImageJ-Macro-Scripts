input = getDirectory("Choose the directory containing the dv's to make into single slice tiff images");

output = getDirectory("Choose directory where new subfolders will be made with the single slice tiffs in them");

rawlist = getFileList(input);

// Choosing Raw or deconvolved images for processing
// -----------------------------------------
if (getBoolean("Do you want to process raw or deconvolved images?", "Raw (R3D)", "Deconvolved (R3D_D3D)") == true) {
	for (i = 0; i<rawlist.length; i++) {
		if (endsWith(rawlist[i], "R3D.dv")) {
			list = Array.concat(list,rawlist[i]);
		}
	}
}
else {
	for (i = 0; i<rawlist.length; i++) {
		if (endsWith(rawlist[i], "R3D_D3D.dv")) {
			list = Array.concat(list,rawlist[i]);	
			}
		}
	}

setBatchMode("hide");
for (i=1; i<list.length; i++) {
	name = File.getNameWithoutExtension(list[i]);
	suboutput = output + "\\" + name + "\\";
	File.makeDirectory(suboutput);
	run("Bio-Formats Windowless Importer", "open=" + input + "\\" + list[i]);
	run("Image Sequence... ", "select=" + list[i] + " dir=" + suboutput + " format=TIFF start=1 digits=3");
	}
showMessage("Done!");


