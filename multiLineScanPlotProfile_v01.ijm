Stack.getDimensions(width, height, channels, slices, frames);
xVal = Array.getSequence(256);
yVal = Array.getSequence(256);
for (i=0; i < yVal.length; i++) {
	yVal[i] = 0;
}
Plot.create("Title", "X-axis Label", "Y-axis Label", xVal, yVal);
//for (i=0; i < height; i++) {
//	Stack.setChannel(1);
//	makeLine(0, i, 256, i);
//	c1Profile = getProfile();
//	Plot.setColor("green");
//	Plot.add("line", xVal, c1Profile);
//}

for (i=0; i < height; i++) {
	Stack.setChannel(2);
	makeLine(0, i, 256, i);
	c2Profile = getProfile();
	Plot.setColor("magenta");
	Plot.add("line", xVal, c2Profile);
}


