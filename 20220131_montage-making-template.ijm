// processing pipeline for myof-gfp alone
// saves a corrected, background subtracted movie, a full image montage chosen, and an inset montage, and a still image showing inset region overlay
// for saving tiffs to the folder, use: saveAs("Tiff", "M:/Jacob/Microscopy/20211206_MyoF-GFP/processed/" + whatever title + ".tif");
// for saving avi's to the folder, use: run("AVI... ", "compression=None frame=24 save=M:/Jacob/Microscopy/20211206_MyoF-GFP/processed/" + whatever-title + ".avi");

input = getDirectory("Choose the Directory Containing Unprocessed Files");
output = getDirectory("_Choose an Output Directory");
print(input);
print(output);
list = getFileList(input);


for (i=0; i<list.length; i++) { 
	if (endsWith(list[i], "R3D.dv")){ 
               print(i + ": " + input+list[i]); 
             open(input+list[i]); 
             
	waitForUser("View this image and see if you think it is good enough to process");
		if (getBoolean("Do you want to process this file? \n \n Yes will begin processing \n \n No will skip to next image \n \n Cancel will quit the macro") == true) {
		
			title = getTitle();
			dir = output + "/" + title + "/";
			File.makeDirectory(dir);
			print(dir);
	
			selectWindow(title);
			run("Duplicate...", "duplicate");
			duptitle = getTitle();

			selectWindow(duptitle);
			run("Z Project...", "projection=[Max Intensity]");
			threshold = getTitle();

			selectWindow(threshold);
			run("Gaussian Blur...", "sigma=2");
			run("Threshold...");
			waitForUser("Once you have selected your threshold method, press OK to record your selection on the next window");
				Dialog.create("Threshold settings recorder");
				Dialog.addMessage("Record your settings");
				array = newArray("Default", "Huang", "Huang2", "Intermodes", "IsoData", "Li", "MaxEntropy", "Mean", "MinError(I)", "Minimum", "Moments", "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen");
				Dialog.addChoice("Which threshold method?", array);
				var min = 0;
				var max = 65535;
				var default = 0;
				Dialog.addSlider("Min", min, max, default);
				var min = 0;
				var max = 65535;
				var default = 65535;
				Dialog.addSlider("Max", min, max, default);
				Dialog.addCheckbox("Dark background", true);
				Dialog.addCheckbox("Don't reset range", false);
				Dialog.addCheckbox("Stack histogram", false);
				Dialog.show();
				method = Dialog.getChoice();
				minim = Dialog.getNumber();
				maxim = Dialog.getNumber();
				bkgrnd = Dialog.getCheckbox();
				rnge = Dialog.getCheckbox();
				hist = Dialog.getCheckbox();

				print("Thresholding settings");
				print(method); 
				print(minim); 
				print(maxim); 
				print(bkgrnd); 
				print(rnge);
				print(hist);
				print("End thresholding settings");
				
			doWand(128, 128);
			roiManager("Add", "threshold");
			selectWindow(duptitle);
			roiManager("Select", "threshold");
				if (getBoolean("Is your bleach correction in Image -> Adjust, or is it under Plugins -> EMBLTools?", "Image->Adjust", "Plugins->EMBLTools") == true) {
					run("Bleach Correction", "correction=[Exponential Fit]");
				} else { 
					run("Bleach Correction", "correction=[Exponential Fit (Frame-wise)]");
				} 
			rename("COR_" + duptitle);
			corduptitle = getTitle();
			
			selectWindow("y = a*exp(-bx) + c");
			rename("graph_" + corduptitle);
			graph = getTitle();
			save(dir + graph + ".tif");
			
			selectWindow(corduptitle);
			run("Subtract Background...", "rolling=10 sliding stack");
			rename("SUB_" + corduptitle);
			subcorduptitle = getTitle();
			run("AVI... ", "compression=None frame=24 save=" + dir + subcorduptitle + ".avi");
			
			selectWindow(subcorduptitle);
			waitForUser("Decide on montage parameters", "When OK is pressed, a montage dialog box will open for you to record your settings in \n \n If you will be repetiviely using the same settings, change the defaults in the code!");
				Dialog.create("Montage settings recorder");
				Dialog.addMessage("This dialog box will record your macro settings and print them to the log \n Make sure to use the same settings on the next window!");
				
				Dialog.addNumber("Columns:", 5);
				Dialog.addNumber("Rows:", 2);
				Dialog.addNumber("Scale factor:", 1);
				Dialog.addNumber("First slice:", 1);
				Dialog.addNumber("Last slice:", 121);
				Dialog.addNumber("Increment:", 12);
				Dialog.addNumber("Border width:", 0);
				Dialog.addNumber("Font size:", 0);
				
				Dialog.addCheckbox("Label slices", false);
				Dialog.addCheckbox("Use foreground color", false);
				
				
				// One can add a Help button that opens a webpage
				Dialog.addHelp("https://imagej.nih.gov/ij/macros/DialogDemo.txt");
				
				// Finally show the GUI, once all parameters have been added
				Dialog.show();
				
				// Once the Dialog is OKed the rest of the code is executed
				// ie one can recover the values in order of appearance 
				// Sliders are number too
				inNumber1 = Dialog.getNumber(); 
				inNumber2 = Dialog.getNumber();
				inNumber3 = Dialog.getNumber();
				inNumber4 = Dialog.getNumber();
				inNumber5 = Dialog.getNumber(); 
				inNumber6 = Dialog.getNumber();
				inNumber7 = Dialog.getNumber();
				inNumber8 = Dialog.getNumber();
				inBoolean1 = Dialog.getChoice();
				inBoolean2 = Dialog.getChoice();
				
				
				// inString  = Dialog.getString();
				// inChoice  = Dialog.getChoice();
				// inBoolean = Dialog.getCheckbox();
				
				print("Montage choices");
				print("Columns:", inNumber1);
				print("Rows:", inNumber2);
				print("Scale factor:", inNumber3);
				print("First slice:", inNumber4);
				print("Last slice:", inNumber5);
				print("Increment:", inNumber6);
				print("Border width:", inNumber7);
				print("Font size:", inNumber8);
				print("Label slices (1=True, 0=False):", inBoolean1);
				print("Use foreground color (1=True, 0=False):", inBoolean2);
				print("End montage 1 choices");
			run("Make Montage...");
			rename("Montage_" + subcorduptitle);
			monsubcorduptitle = getTitle();
			saveAs("Tiff", dir + monsubcorduptitle + ".tif");
			
			selectWindow(subcorduptitle);
			makeRectangle(128, 128, 30, 30);
			waitForUser("Place selection box over desired inset, or change desired inset box size. \n default is 30px X 30px");
			roiManager("Add", "inset");
			Roi.setStrokeColor(255, 255, 255);
			Roi.setStrokeWidth(1);
			run("Duplicate...", "title=[INSET_" + subcorduptitle + "] duplicate");
			insubcorduptitle = getTitle();
			run("AVI... ", "compression=None frame=24 save=" + dir + insubcorduptitle + ".avi");

			selectWindow(insubcorduptitle);
			waitForUser("Decide on montage parameters", "When OK is pressed, a montage dialog box will open for you to record your settings in \n \n If you will be repetiviely using the same settings, change the defaults in the code!");

				Dialog.create("Montage settings recorder");
				Dialog.addMessage("This dialog box will record your macro settings and print them to the log \n Make sure to use the same settings on the next window!");
				
				Dialog.addNumber("Columns:", 5);
				Dialog.addNumber("Rows:", 2);
				Dialog.addNumber("Scale factor:", 1);
				Dialog.addNumber("First slice:", 1);
				Dialog.addNumber("Last slice:", 121);
				Dialog.addNumber("Increment:", 12);
				Dialog.addNumber("Border width:", 0);
				Dialog.addNumber("Font size:", 0);
				
				Dialog.addCheckbox("Label slices", false);
				Dialog.addCheckbox("Use foreground color", false);
				
				
				// One can add a Help button that opens a webpage
				Dialog.addHelp("https://imagej.nih.gov/ij/macros/DialogDemo.txt");
				
				// Finally show the GUI, once all parameters have been added
				Dialog.show();
				
				// Once the Dialog is OKed the rest of the code is executed
				// ie one can recover the values in order of appearance 
				// Sliders are number too
				inNumber1 = Dialog.getNumber(); 
				inNumber2 = Dialog.getNumber();
				inNumber3 = Dialog.getNumber();
				inNumber4 = Dialog.getNumber();
				inNumber5 = Dialog.getNumber(); 
				inNumber6 = Dialog.getNumber();
				inNumber7 = Dialog.getNumber();
				inNumber8 = Dialog.getNumber();
				inBoolean1 = Dialog.getChoice();
				inBoolean2 = Dialog.getChoice();
				
				
				// inString  = Dialog.getString();
				// inChoice  = Dialog.getChoice();
				// inBoolean = Dialog.getCheckbox();
				
				print("Montage choices");
				print("Columns:", inNumber1);
				print("Rows:", inNumber2);
				print("Scale factor:", inNumber3);
				print("First slice:", inNumber4);
				print("Last slice:", inNumber5);
				print("Increment:", inNumber6);
				print("Border width:", inNumber7);
				print("Font size:", inNumber8);
				print("Label slices (1=True, 0=False):", inBoolean1);
				print("Use foreground color (1=True, 0=False):", inBoolean2);
				print("End montage 2 choices");
			run("Make Montage...");
			rename("Montage_" + insubcorduptitle);
			minsubcorduptitle = getTitle();
			saveAs("Tiff", dir + minsubcorduptitle + ".tif");

			selectWindow(subcorduptitle);
			run("Z Project...", "stop=1 projection=[Max Intensity]");
			roiManager("Select", 1);
			Roi.setStrokeColor("white");
			Overlay.addSelection("white", 1);
			saveAs("Tiff", dir + "ref_" + subcorduptitle + ".tif");
			
			selectWindow("Log");
			saveAs("text", dir + "log_" + title + ".txt");
			print("\\Clear");

			roiManager("save", "" + dir + title + ".roi");
			roiManager("deselect");
			roiManager("delete");

			close("*");
		}
		else {
			close("*");
			print("\\Clear");
		}
     }
}


