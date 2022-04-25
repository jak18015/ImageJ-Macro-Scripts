Dialog.create("Montage settings recorder");
Dialog.addMessage("This dialog box will record your macro settings and print them to the log \n Make sure to use the same settings on the next window!");

Dialog.addNumber("Columns:", 5);
Dialog.addNumber("Rows:", 2);
Dialog.addNumber("Scale factor:", 1);
Dialog.addNumber("First slice:", 1);
Dialog.addNumber("Last slice:", 61);
Dialog.addNumber("Increment:", 6);
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