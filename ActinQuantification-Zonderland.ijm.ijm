
/* To create a new macro from this code: 
 *  Plugins -> New -> Macro
 *  Copy the code in this window, save it and press run.
 *  
 *  The macro works by (automatically) selecting the cell and nucleus and drawing a line through the middle of cell or nucleus. 
 * Everything that is not the selected cell is removed and the line that is over the cell is cut up in a number of 'bins'.
 * The average intensity of pixels over that bin is taken and added to the csv file.
 * The average intensity of pixels over the nucleus (in the actin slice) and in the whole cell are also measured. 
 * 
 * Note: Don't edit the .csv file in excel. Somehow this 'damages' the file so that it can't be processed further in R (or I don't know how to at least). Edit it in TextEdit/Notepad.
 * 
 * To customize settings:
 * Threshold and particle analysis settings for cell selection will be dependent on the images, look for 'threshold' and 'analyze particles' to play with the settings. 
 * Look for 'bin' to customize the binnumber
 * 
 */

DataGroup = "";
waitForUser("Choose where to save the data file.\nIf the folder already contains a data file from this macro, it will add it to that file\nPress OK to choose the folder"); 
SaveFolder = getDirectory("Choose a Directory");

while(1){
MacroHelp = 	"<html>"
    		 +"<h1>Actin Distribution quantification</h1>"
  			  +"<h2>Created by: Jip Zonderland and Paul Wieringa</h2>"
  			  +"<h3>For more information and explanation, see paper</h3>";
  			  
Dialog.create("Actin Quantification");
Dialog.addHelp(MacroHelp);

items = newArray("Automatic cell selection", "Manual cell selection", "Measure manually drawn line", "Optional: Z project Max intensity");
Dialog.addRadioButtonGroup("Options", items, 5, 1, "Manual cell selection");
lineoptions = newArray("Line perpendicular through the cell", "Line in line with the cell", "Line perpendicular through the nucleus", "Line in line with the nucleus");
Dialog.addRadioButtonGroup("Line creation", lineoptions, 2, 2, "Line perpendicular through the cell");
Dialog.addMessage("");
Dialog.addMessage("Which slice (channel number) contains the: ");
NucleusSlice = 1; 
ActinSlice = 2;
Dialog.addNumber("Nucleus", NucleusSlice); 
Dialog.addNumber("Actin", ActinSlice);
Dialog.addMessage("");

Dialog.addMessage("The name of your data group, don't forget!");
Dialog.addString("Data Group: ", DataGroup);
items2 = newArray("Analyze all files in a folder", "Analyze already opened image");
Dialog.addRadioButtonGroup("Analysis type", items2, 1, 2, "Analyze all files in a folder");
Dialog.show;
Selection = Dialog.getRadioButton;
Selection2 = Dialog.getRadioButton;
Selection3 = Dialog.getRadioButton;
NucleusSlice = Dialog.getNumber();
ActinSlice = Dialog.getNumber();
DataGroup = Dialog.getString();

largestROI = 0;
SelectedCell = 0;
ActinOverNucleus = "Not available";
ActinNucleusCellArray = newArray("0", "0");
ActinAverageCell = "Not available";

if(DataGroup == "" && Selection != "Optional: Z project Max intensity") {
	exit("You didn't fill out a data group, macro aborted");
}

if(Selection3 == "Analyze all files in a folder") {
	waitForUser("Choose the folder that contains your images, the macro will measure all images.\nThe easiest way to order your data is to put each image set (experimental condition) in a seperate folder.\nPress OK to continue and choose the folder");

	DataFolder = getDirectory("Choose a Directory"); //creates array of all files in the folder
	TifFiles = listTifFiles(DataFolder); //keeps only the .tif .tiff files

	if(Selection == "Automatic cell selection") {
		
		c=0;
		while (c < TifFiles.length) {
			NextImage = DataFolder+TifFiles[c];
			open(NextImage);
			c++;
			largestROI = ClearBackground(NucleusSlice, ActinSlice);
			if (Selection2 == "Line perpendicular through the nucleus" || Selection2 == "Line in line with the nucleus") {
				ActinNucleusCellArray = LineThroughNucleus(NucleusSlice, ActinSlice, largestROI, Selection2);
				WriteData(SaveFolder, ActinNucleusCellArray, DataGroup);
			}
			if(Selection2 == "Line perpendicular through the cell" || Selection2 == "Line in line with the cell") {
				ActinNucleusCellArray = LineThroughCell(NucleusSlice, ActinSlice, largestROI, Selection2);
				WriteData(SaveFolder, ActinNucleusCellArray, DataGroup);	
			}
		}
	}

	
	if(Selection == "Manual cell selection") {
		c=0;
		while (c < TifFiles.length) {
			NextImage = DataFolder+TifFiles[c];
			open(NextImage);
			c++;
		SelectedCell = ClearBackgroundManual(NucleusSlice, ActinSlice);
		ActinNucleusCellArray = CreateLineManual(NucleusSlice, ActinSlice, SelectedCell, Selection2);
		WriteData(SaveFolder, ActinNucleusCellArray, DataGroup);
		}
	}

	if(Selection == "Measure manually drawn line") {
		c=0;
		while (c < TifFiles.length) {
			NextImage = DataFolder+TifFiles[c];
			open(NextImage);
			c++;
		setTool("line");	
		waitForUser("Draw your line and press OK");
		WriteData(SaveFolder, ActinNucleusCellArray, DataGroup);
		}
	}

	if(Selection == "Optional: Z project Max intensity") {
		NewFolder = "Max Intensity Images";
		File.makeDirectory(DataFolder+NewFolder);
		
		c=0;
		while (c < TifFiles.length) {
			NextImage = DataFolder+TifFiles[c];
			open(NextImage);
			c++;	
			run("Z Project...", "projection=[Max Intensity]");
			ImageName = getInfo("window.title");
			savePath = DataFolder+NewFolder+File.separator+ImageName;
			saveAs("tiff", savePath);
			close();
			close();
		}
	}

	
}



if(Selection3 == "Analyze already opened image") {
	
	
	if(Selection == "Automatic cell selection") {
		largestROI = ClearBackground(NucleusSlice, ActinSlice);
		if (Selection2 == "Line perpendicular through the nucleus" || Selection2 == "Line in line with the nucleus") {
			ActinNucleusCellArray = LineThroughNucleus(NucleusSlice, ActinSlice, largestROI, Selection2);
			WriteData(SaveFolder, ActinNucleusCellArray, DataGroup);
		}
	

		if(Selection2 == "Line perpendicular through the cell" || Selection2 == "Line in line with the cell") {
			ActinNucleusCellArray = LineThroughCell(NucleusSlice, ActinSlice, largestROI, Selection2);
			WriteData(SaveFolder, ActinNucleusCellArray, DataGroup);	
		}
	
	
	}

	
	if(Selection == "Manual cell selection") {
		SelectedCell = ClearBackgroundManual(NucleusSlice, ActinSlice);
		ActinNucleusCellArray = CreateLineManual(NucleusSlice, ActinSlice, SelectedCell, Selection2);
		WriteData(SaveFolder, ActinNucleusCellArray, DataGroup);
	}

	if(Selection == "Measure manually drawn line") {
		setTool("line");
		waitForUser("Draw your line and press OK");
		WriteData(SaveFolder, ActinNucleusCellArray, DataGroup);
	}

	if(Selection == "Optional: Z project Max intensity") {
		run("Z Project...", "projection=[Max Intensity]");
	}


} //close while loop of Dialog window


//functions


function ClearBackground(NucleusSlice, ActinSlice) {
//Clean Actin image of all the background around the cell

setSlice(ActinSlice);

run("Clear Results"); 
roiManager("reset"); 

imgTitle = getTitle();
run("Duplicate...", "duplicate");
run("Auto Threshold", "method=Default white");
run("Invert", "slice");
run("Fill Holes", "slice");
run("Analyze Particles...", "size=200-Infinity display add in_situ slice");

//automatic selection of largest ROI
roiManager("select",0);
largestROI = 0;
a=0;
if(roiManager("count")>1) {
	AreaP = 0;
	AreaN = 0;

	while (a < roiManager("count") ) {
		getStatistics(AreaP);
		roiManager("select", a);
		getStatistics(AreaN);
		a++;
		if (AreaN > AreaP) {
			largestROI = roiManager("index");
		}
	}		
}

close();
selectWindow(imgTitle);
roiManager("select", largestROI);
setBackgroundColor(0, 0, 0);
run("Clear Outside", "slice");

return largestROI;
}

function LineThroughNucleus(NucleusSlice, ActinSlice, largestROI, Selection2) {
a = roiManager("count");

setSlice(NucleusSlice);
//select nucleus within ROI (largest ROI in cell)
run("Convert to Mask", "method=Default background=Light only");
run("Invert", "slice");
run("Fill Holes", "slice");
roiManager("select", largestROI);
setSlice(NucleusSlice);
run("Set Measurements...", "mean center fit redirect=None decimal=0");
run("Analyze Particles...", "size=25-Infinity display add in_situ slice");

run("Clear Results"); 

roiManager("select", a);
largestROINuc = roiManager("index");
//variable a is always 1 more than the number of ROIs in the actin image, and will therefore now have the index number of the 1st ROI in the nucleus. We can continue searching for the largest ROI in the measured cell, by starting at a.
	AreaP = 0;
	AreaN = 0;

	while (a < roiManager("count") ) {
		getStatistics(AreaP);
		roiManager("select", a);
		getStatistics(AreaN);
		a++;
		if (AreaN > AreaP) {
			largestROINuc = roiManager("index");
		}
	}

	
//measure average actin intensity in the cell
run("Clear Results");
roiManager("select", largestROI)
run("Measure");
ActinInCell = getResult("Mean");

//measure average actin intensity over nucleus
roiManager("select", largestROINuc);
roiManager("remove slice info");
setSlice(ActinSlice);
roiManager("select", largestROINuc);

run("Measure"); //measures average actin intensity over nucleus. Value comes under "Mean"
ActinOverNucleus = getResult("Mean");

ActinNucleusCellArray = newArray(ActinOverNucleus, ActinInCell); //make array to be returned from the function

Xmid = getResult("XM");
Ymid = getResult("YM");

if(Selection2 == "Line perpendicular through the nucleus") {
Angle = getResult("Angle")+90;
}
if(Selection2 == "Line in line with the nucleus") {
Angle = getResult("Angle");
}


//convert to radius
Angle = Angle * 3.14159265359 / 180;

//Converts coordinates to pixel if there is a scale
getPixelSize(unit, pw, ph);
Xmid = Xmid / pw;
Ymid = Ymid / ph;
	
//Calculate line coordinates and make line, always bigger than the image
Linelength = getWidth();
Yplus = sin(Angle) * Linelength;
Xplus = cos(Angle) * Linelength;

Xend = Xmid+Xplus;
Yend = Ymid-Yplus;
Xbegin = Xmid-Xplus;
Ybegin = Ymid+Yplus;
makeLine(Xbegin, Ybegin, Xend, Yend);

return ActinNucleusCellArray;

}


function LineThroughCell(NucleusSlice, ActinSlice, largestROI, Selection2) {
	a = roiManager("count");

setSlice(NucleusSlice);
//select nucleus within ROI (largest ROI in cell)
run("Convert to Mask", "method=Default background=Light only");
run("Invert", "slice");
run("Fill Holes", "slice");
roiManager("select", largestROI);
setSlice(NucleusSlice);
run("Set Measurements...", "mean center fit redirect=None decimal=0");
run("Analyze Particles...", "size=25-Infinity display add in_situ slice");

if(roiManager("count")==a){ //in case there are no ROI's in the NucleusSlice, it selects the last ROI in the list
	a = a-1; 
}

run("Clear Results"); 

roiManager("select", a);
largestROINuc = roiManager("index");
//variable a is always 1 more than the number of ROIs in the actin image, and will therefore now have the index number of the 1st ROI in the nucleus. We can continue searching for the largest ROI in the measured cell, by starting at a.
	AreaP = 0;
	AreaN = 0;

	while (a < roiManager("count") ) {
		getStatistics(AreaP);
		roiManager("select", a);
		getStatistics(AreaN);
		a++;
		if (AreaN > AreaP) {
			largestROINuc = roiManager("index");
		}
	}
	

roiManager("select", largestROINuc);
roiManager("remove slice info");
setSlice(ActinSlice);
roiManager("select", largestROINuc); //select nucleus

run("Measure"); //measures average actin intensity over nucleus. Value comes under "Mean"
ActinOverNucleus = getResult("Mean");

//measure average actin intensity in the cell
run("Clear Results");
roiManager("select", largestROI)
run("Measure");
ActinInCell = getResult("Mean");

ActinNucleusCellArray = newArray(ActinOverNucleus, ActinInCell); //make array to be returned from the function

Xmid = getResult("XM");
Ymid = getResult("YM");

if(Selection2 == "Line perpendicular through the cell") {
Angle = getResult("Angle")+90;
}
if(Selection2 == "Line in line with the cell") {
Angle = getResult("Angle");
}


//convert to radius
Angle = Angle * 3.14159265359 / 180;

//Converts coordinates to pixel if there is a scale
getPixelSize(unit, pw, ph);
Xmid = Xmid / pw;
Ymid = Ymid / ph;
	
//Calculate line coordinates and make line, always bigger than the image
Linelength = getWidth();
Yplus = sin(Angle) * Linelength;
Xplus = cos(Angle) * Linelength;

Xend = Xmid+Xplus;
Yend = Ymid-Yplus;
Xbegin = Xmid-Xplus;
Ybegin = Ymid+Yplus;
makeLine(Xbegin, Ybegin, Xend, Yend);

return ActinNucleusCellArray;
}



function ClearBackgroundManual(Nucleusslice, ActinSlice) {
//Clean Actin image of all the background around the cell
setSlice(ActinSlice);

run("Clear Results"); 
roiManager("reset"); 

imgTitle = getTitle();
run("Duplicate...", "duplicate");
run("Auto Threshold", "method=Default white");
run("Invert", "slice");
run("Fill Holes", "slice");
run("Analyze Particles...", "size=200-Infinity display add in_situ slice");
SelectedCell = 0;
if(roiManager("count")>1){
	setTool("line");
	waitForUser("Click on the ROI number in your cell of interest");
	SelectedCell = roiManager("index");
}

close();
selectWindow(imgTitle);
roiManager("select", SelectedCell);
setBackgroundColor(0, 0, 0);
run("Clear Outside", "slice");

return SelectedCell;

}

function CreateLineManual(NucleusSlice, ActinSlice, SelectedCell, Selection2) {
roiManager("deselect");
roiCount = roiManager("count");
setSlice(NucleusSlice);

run("Convert to Mask", "method=Default background=Light only");
run("Invert", "slice");
run("Fill Holes", "slice");
run("Set Measurements...", "mean center fit redirect=None decimal=0");
run("Analyze Particles...", "size=25-Infinity display add in_situ slice");


SelectedNucleus = SelectedCell; //in case there are no ROI's in the NucleusSlice, it selects the last ROI of the cell
if(roiManager("count")>(roiCount+1)){ //check if there's more than 1 ROI that could be the nucleus
	setTool("line");
	waitForUser("Click on the ROI number in the nucleus of your cell of interest");
	SelectedNucleus = roiManager("index");
}
if(roiManager("count")==roiCount+1) { //in case there is 1 nuclear ROI
	SelectedNucleus = roiCount; 
} 

run("Clear Results");
roiManager("select", SelectedNucleus);
roiManager("remove slice info");
setSlice(ActinSlice);
roiManager("select", SelectedNucleus);
run("Measure"); //measures average actin intensity over nucleus. Value comes under "Mean"
ActinOverNucleus = getResult("Mean");

//measure average actin intensity in the cell
run("Clear Results");
roiManager("select", SelectedCell)
run("Measure");
ActinInCell = getResult("Mean");

ActinNucleusCellArray = newArray(ActinOverNucleus, ActinInCell);


if(Selection2 == "Line perpendicular through the nucleus" || Selection2 == "Line in line with the nucleus") {
	roiManager("select", SelectedNucleus);
	run("Measure");
}

if(Selection2 == "Line perpendicular through the cell" || Selection2 == "Line in line with the cell") {
	roiManager("select", SelectedCell);
	run("Measure");
}

Xmid = getResult("XM");
Ymid = getResult("YM");

if(Selection2 == "Line perpendicular through the nucleus" || Selection2 == "Line perpendicular through the cell") {
Angle = getResult("Angle")+90;
}
if(Selection2 == "Line in line with the nucleus" || Selection2 == "Line in line with the cell") {
Angle = getResult("Angle");
}
//convert to radius
Angle = Angle * 3.14159265359 / 180;

//Converts coordinates to pixel if there is a scale
getPixelSize(unit, pw, ph);
Xmid = Xmid / pw;
Ymid = Ymid / ph;
	
//Calculate line coordinates and make line, always bigger than the image
Linelength = getWidth();
Yplus = sin(Angle) * Linelength;
Xplus = cos(Angle) * Linelength;

Xend = Xmid+Xplus;
Yend = Ymid-Yplus;
Xbegin = Xmid-Xplus;
Ybegin = Ymid+Yplus;
makeLine(Xbegin, Ybegin, Xend, Yend);

return ActinNucleusCellArray;
}








function WriteData(SaveFolder, ActinNucleusCellArray, DataGroup) {

//Measure average actin over the cell


//if the retrieved path doesn't exist, redirect to the home directory 
if(lengthOf(SaveFolder)<1){
	dataPath = getDirectory("home"); 
	print("Data folder not available, file saved in home directory");
}

//print(dataPath);

//rewrite data path to include file data name
dataPath = SaveFolder+"actin_data.csv";


if(!File.exists(dataPath)){

	header = "DataGroup; Index; ImageID; BinSize; Bin; Average; AverageNuclearActin; AverageCellActin\n";
	
	File.saveString(header, dataPath);

	index = 1;
	
}
else{

	tempString = File.openAsString(dataPath);

	tempString = split(tempString, "\n");

	tempString = tempString[tempString.length-1];

	tempString = split(tempString, ";");

	index = parseInt(tempString[1])+1;
		
}

//initialize bin size
bin = 10;

///assumes a line has been drawn

//extract data from the line
data = getProfile();



i=0;
//trim black space
	while(data[0]==0 || isNaN(data[0])==1){

		//print(i);
		i++;

		data = Array.slice(data,1,data.length-1); 

		if(data.length == 0){

			exit("you fail!");

		}
		
	}

	while(data[data.length-1]==0 || isNaN(data[data.length-1])==1){

		data = Array.slice(data,0,data.length-2); 
		
	}


//determine line lengthOf(str)
dataSize = data.length;
//print(dataSize);

ActinOverNucleus = ActinNucleusCellArray[0];
AverageActinCell = ActinNucleusCellArray[1];

imageTag = getInfo("image.filename");

//test that data is real
if(dataSize > 0){

	binSize = dataSize/bin;
	
	for(i = 0; i < bin; i++) {

		//print("bin number: " +i);

		sumbox = 0;
		avgbox = 0;

		binStart = i*binSize;
		binEnd = (i+1)*binSize;

		//print("start: "+binStart+"; end "+binEnd+"; size "+data.length);
		
		binEnd = minOf(binEnd,data.length);
		pixelCount = binEnd-binStart;
		
		for(j = binStart; j < binEnd;j++){

			//print("bin number: " +i +"; count number: "+ j);

			sumbox = sumbox + data[j];
			
		}

		//average the summed pixel intensity over the length of the bin
		//account for the overcount of j
		avgbox = sumbox/pixelCount;

		//print(pixelCount);

		//"DataGroup; Index; ImageID; BinSize; Bin; Average; ActinOverNucleus"
		File.append( DataGroup+";"+index+";"+imageTag+";"+binSize+";"+i+";"+avgbox+";"+ActinOverNucleus+";"+AverageActinCell, dataPath);

		//reset holders
		avgbox = 0;
		sumbox = 0;

		//index increment
		index++;
	
	}




}
else{

	print("No data points found");
}

}




function listTifFiles(DataFolder) {
     
     list = getFileList(DataFolder);
     list2 = newArray(list.length);//create a blank array of same size
     Array.fill(list2, 1); //make all values 1 - code that it's not a valid file name
     x=0;
     for (i=0; i<list.length; i++) {

	//test if '.tif' exists some where (including .TIF, TIFF or .tiff) and 
     	if(indexOf(toLowerCase(list[i]),".tif")>0 && (lengthOf(list[i])-indexOf(list[i], ".tif"))!=4){
		newName = replace(list[i],substring(list[i], indexOf(list[i],".")),".tif");
		File.rename(DataFolder+list[i], DataFolder+newName);
		
		//test if file is open
		if(isOpen(list[i])){
			//if so, close and reload it
			selectWindow(list[i]);
			close();
			open(DataFolder+newName);
		}
		
		list[i] = newName;

     	}
    
     	if (endsWith(list[i], ".tif")==1){
     		
		list2[x]=list[i];//insert only tif files		
		x++; 
     	}
     }
     return list2;//return the tif images
}
