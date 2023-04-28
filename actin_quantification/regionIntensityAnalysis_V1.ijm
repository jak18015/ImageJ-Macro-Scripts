xlPath = "Z:\\Jacob\\Microscopy\\20211028_MyoF-AID_AC-EmFP_STREAM\\processed\\actinRegionProfilesV3\\";
xlName = "regionProfiles_V3";

//setBatchMode(true);
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
run("Set Measurements...", "area mean min redirect=None decimal=9");
run("Cascade");
list = getList("image.titles");
for (image = 0; image < list.length; image++) {
	selectWindow(list[image]);
	setLocation(screenWidth/4, screenHeight/4, 512, 512);
	Dialog.createNonBlocking("How many parasites?");
	Dialog.addNumber("parasite number: ", 2);
	Dialog.setLocation(screenWidth/3,screenHeight/8);
	Dialog.show();
	parasiteCount = Dialog.getNumber();
	
	if (matches(list[image], ".*minusIAA_[0-9].*")) {treatment = "Control";}
	if (matches(list[image], ".*plusIAA_[0-9].*")) {treatment = "MyoF-KD";}
	
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Gaussian Blur...", "sigma=1 stack");
	run("8-bit");
	run("Auto Local Threshold", "method=Bernsen radius=1 parameter_1=0 parameter_2=0 white stack");
	for (f = 1; f <= frames; f++) {
		Stack.setFrame(f);
		run("Create Selection");
		setOption("WaitForCompletion", true);
		roiManager("add");
	}
	roiCount = roiManager("count");
	for (r = 0; r < roiCount; r++) {
		roiManager("select", r);
		roiManager("measure");
	}
	selectWindow("Results");
	areaArray = Table.getColumn("Area");
	for (a=0; a < areaArray.length; a++) {
		if ((areaArray.length - a > 1) == true) {
			Table.set("diff", a+1, areaArray[a+1] - areaArray[a]);
			Table.set("absDiff", a+1, abs(areaArray[a+1] - areaArray[a]));
			Table.set("AbsDiffPerParasite", a+1, (abs(areaArray[a+1] - areaArray[a])/parasiteCount));
			Table.set("AreaPerParasite", a+1, (areaArray[a]/parasiteCount));
		}
		Table.set("img", a, list[image]);
		Table.set("frame", a, "frame_" + a+1);
		Table.set("treatment", a, treatment);
		Table.set("parasiteCount", a, parasiteCount);
		
	}
	wawa
	run("Read and Write Excel", "stack_results dataset_label = [" +year+month+dayOfMonth+ "]  no_count_column file=["+xlPath+xlName+".xlsx]");
	roiManager("save", xlPath+list[image] + ".zip");
	run("Clear Results");
	close("Results");
	roiManager("deselect");
	roiManager("delete");
}
		