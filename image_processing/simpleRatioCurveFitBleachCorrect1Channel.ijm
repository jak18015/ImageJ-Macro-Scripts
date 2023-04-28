list = getList("image.titles");

for (i=0; i < list.length; i++) {
	selectWindow(list[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	bleaCor();
}

function bleaCor() {
	title = getTitle();
	makeRectangle(0, 0, width, height);
	xpoints = newArray();
	ypoints = newArray();
	run("Plot Z-axis Profile");
	Plot.getValues(xpoints, ypoints);
	Fit.doFit(11, xpoints, ypoints);
	c = Fit.p(2);
	close(title+"-0-0");
	selectWindow(title);
	run("Bleach Correction", "correction=[Simple Ratio] background="+c);
	dup = getTitle();
	close(title);
	selectWindow(dup);
	rename(title);
}
