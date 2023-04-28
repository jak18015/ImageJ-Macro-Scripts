title = getTitle();
list = newArray();
list = Array.concat(list,title);

for (i=0; i < list.length; i++) {
	selectWindow(list[i]);
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Split Channels");
	selectWindow("C1-"+list[i]);
	c1 = getTitle();
	bleaCor();
	cor_c1 = getTitle();
	close(c1);
	close(c1+"-0-0");
	selectWindow("C2-"+list[i]);
	c2 = getTitle();
	bleaCor();
	cor_c2 = getTitle();
	close(c2);
	close(c2+"-0-0");
	run("Merge Channels...", "c1="+cor_c1+" c2="+cor_c2+" create");
	rename(title);
	close("Log");
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
	selectWindow(title);
	run("Bleach Correction", "correction=[Simple Ratio] background="+c);
	
}
