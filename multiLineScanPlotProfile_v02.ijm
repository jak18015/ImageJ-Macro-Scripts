Stack.getDimensions(width, height, channels, slices, frames);
xVal = Array.getSequence(256);
timeArray = Array.getSequence(256);


Table.create("c1-3dPlot");

for (i=0; i < height; i++) {
	Stack.setChannel(1);
	makeLine(0, i, 256, i);
	c1Profile = getProfile();
	Table.setColumn("Y"+""+i+"", c1Profile);
	for (j=0; j < timeArray.length; j++) {timeArray[j] = i;}
	Table.setColumn("Z"+""+i+"", timeArray);
}

//for (i=0; i < height; i++) {
//	Stack.setChannel(2);
//	makeLine(0, i, 256, i);
//	c2Profile = getProfile();
//	Plot.setColor("magenta");
//	Plot.add("line", xVal, c2Profile);
//}


