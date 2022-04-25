Table.open("C:\\Users\\jakek\\OneDrive\\Desktop\\ProcessDirectories.csv");
list = Table.getColumn("ImagePath");


Dialog.createNonBlocking("ObservationStation_1.0");
Dialog.addMessage("Use this dialog box to record notes about"
+ "\nthe description and your conclusion from the image set "
+ "\nwhile going through them."
+ "\n \nThis box does not prevent any actions being done within ImageJ."
+ "\n \nnote: these are saved into the .csv table", 16, 000000);

Dialog.addString("Description: ", "initialText", 100);
Dialog.addString("Conclusion: ", "initialText", 100);
  items = newArray("None", "1", "2", "3", "> 3");
  Dialog.addRadioButtonGroup("Need more imaging sets?", items, 5, 1, "Two");

Dialog.show();

description = Dialog.getString();
conclusion = Dialog.getString();
need_more = Dialog.getRadioButton();

Table.set("Description", 0, description);
Table.set("Conclusion", 0, conclusion);
Table.set("Need more?", 0, need_more);