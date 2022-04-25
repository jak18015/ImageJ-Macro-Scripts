
// My modified Make Montage

				Dialog.create("Jacob's Montage");
				
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
				columns = Dialog.getNumber(); 
				rows = Dialog.getNumber();
				scale_factor = Dialog.getNumber();
				first_slice = Dialog.getNumber();
				last_slice = Dialog.getNumber(); 
				increment = Dialog.getNumber();
				border_width = Dialog.getNumber();
				font_size = Dialog.getNumber();
				label_slices = Dialog.getCheckbox();
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
				print("Font size:", font_size);
				print("Label slices (1=True, 0=False):", label_slices);
				print("Use foreground color (1=True, 0=False):", use_foreground_color);
				print("-------------------------------");
				print("End montage  choices");
				print("-------------------------------\n");

					
					if (label_slices == false) {
							label_slices = "";
					}
					else {
						label_slices = " label";
					}

					if (use_foreground_color == false) {
						use_foreground_color = "";
					}
					else {
						use_foreground_color = " use";
					}
			run("Make Montage...", "columns=" + columns + " rows=" + rows + " scale=" + scale_factor + label_slices + use_foreground_color);

// Montage end
