list = getList("image.titles");

for (i=0; i < list.length; i++) {

selectWindow(list[i]);
	run("8-bit");
	title = getTitle();
	dir = getDirectory("image");
	dirArray = split(dir, "\\");
	dirArray = Array.deleteIndex(dirArray, 3);
	dir = String.join(dirArray, "\\") + "\\";
	print("Processed dir: " + dir);
	File.makeDirectory(dir + "labMeetingPresentation");
	dir = dir + "labMeetingPresentation" + File.separator;
	Stack.getDimensions(width, height, channels, slices, frames);
	if (slices > 1) {
		waitForUser("set the best Z in "+list[i]);
		run("Reduce Dimensionality...", "channels frames");
	}

//Process image for proper montaging
makeRectangle(20, 20, 180, 180);
waitForUser("Place selection box over vacuole. \n default is 200px X 200px");


run("Crop");
merge = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
	frameInterval = Stack.getFrameInterval();

selectWindow(merge);
run("Split Channels");
selectWindow("C1-"+merge);
	run("Bleach Correction", "correction=[Exponential Fit]");
	c1=getTitle();
	run("Green");
	close("y = a*exp(-bx) + c");
selectWindow("C2-"+merge);
	run("Bleach Correction", "correction=[Exponential Fit]");
	c2=getTitle();
	run("Magenta");
	close("y = a*exp(-bx) + c");
run("Merge Channels...", "c1="+c1+" c2="+c2+" create keep");
rename(merge+"_DUP");
merge = getTitle();

selectWindow(c1);
	run("AVI... ", "compression=None frame=24 save=" + dir + c1 + ".avi");
selectWindow(c2);
	run("AVI... ", "compression=None frame=24 save=" + dir + c2 + ".avi");
selectWindow(merge);
	run("AVI... ", "compression=None frame=24 save=" + dir + merge + ".avi");
	}