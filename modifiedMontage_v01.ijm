macro "modifiedMontage" {

merge = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);


//                   Montage begin
//===========================================================//
			if (frames > 135) {
				frames = 135;
				}
			defaultinc = 10;
			defaultinc = round(defaultinc);
			defaultframes = 9*defaultinc + 1;
			defaultinc = toString(defaultinc, 0);
			defaultframes = toString(defaultframes, 0);


			selectWindow(merge);

			// My modified Make Montage
			Dialog.createNonBlocking("Jacob's Montage");
			Dialog.addMessage("NOTE: When making a montage, both the first and last frame appear in the panel. \n i.e. a 10 panel montage of frames 40-80 with an increment of 4 will only go to 76");
			Dialog.addMessage("NOTE: When making a montage, both the first and last frame appear in the panel."
			+ "\n \n i.e. 4 panel montages with an increment of 4 have 12 frames from first to last (4,8,12,16)");
			Dialog.addNumber("Columns:", 5);
			Dialog.addNumber("Rows:", 2);
			Dialog.addNumber("Scale factor:", 1);
			Dialog.addNumber("First slice:", 1);
			Dialog.addNumber("Last slice:", defaultframes);
			Dialog.addNumber("Increment:", defaultinc);
			Dialog.addNumber("Border width:", 0);
			
			Dialog.addCheckbox("Use foreground color", false);
				
				
			// One can add a Help button that opens a webpage
			Dialog.addHelp("https://imagej.nih.gov/ij/macros/DialogDemo.txt");
			
			// Finally show the GUI, once all parameters have been added
			Dialog.show();
				
			// Once the Dialog is OKed the rest of the code is executed
			// ie one can recover the values in order of appearance 
			// Sliders are number too
			columns = Dialog.getNumber(); 
			rows = Dialog.getNumber();
			scale_factor = Dialog.getNumber();
			first_slice = Dialog.getNumber();
			last_slice = Dialog.getNumber(); 
			increment = Dialog.getNumber();
			border_width = Dialog.getNumber();
			use_foreground_color = Dialog.getCheckbox();
				
				
			// inString  = Dialog.getString();
			// inChoice  = Dialog.getChoice();
			// inBoolean = Dialog.getCheckbox();
	
			print("\n-------------------------------");
			print("Montage choices");
			print("-------------------------------");
			print("Columns:", columns);
			print("Rows:", rows);
			print("Scale factor:", scale_factor);
			print("First slice:", first_slice);
			print("Last slice:", last_slice);
			print("Increment:", increment);
			print("Border width:", border_width);
			print("Use foreground color (1=True, 0=False):", use_foreground_color);
			print("-------------------------------");
			print("End montage  choices");
			print("-------------------------------\n");

				if (use_foreground_color == 0) {
					use_foreground_color = "";
				}
				else {
					use_foreground_color = " use";
				}
			selectWindow(merge);

			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + use_foreground_color);
			rename("merge_montage");
			merge_montage = getTitle();

			// inset begin
			selectWindow(merge);
			run("Duplicate...", "title=[ref_" + merge + "] duplicate frames=1");
			ref_merge = getTitle();
			
			selectWindow(ref_merge);
			makeRectangle(128, 128, 32, 32);
			waitForUser("Place selection box over desired inset, or change desired inset box size. \n default is 32px X 32px");
			run("Select Bounding Box");
			roiManager("Add");
			roiManager("select", 0);
			roiManager("rename", "inset");
			Roi.setStrokeColor(255, 255, 255);
			Roi.setStrokeWidth(1);
			Overlay.addSelection
			run("Duplicate...", "title=[inset_" + merge + "] duplicate");
			
			inset_merge = getTitle();
			
//                   Inset montage begin
//===========================================================//
				
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + " first=" + first_slice + " last=" + last_slice + " increment=" + increment + " border=" + border_width + use_foreground_color);
			rename(inset_merge + "_montage");
			inset_merge_montage = getTitle();
			roiManager("delete");
			
//                      Montage end
//===========================================================//

}