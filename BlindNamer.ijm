// Get the directory containing the images
dir = getDirectory("Choose the directory with the DVs");

// creates a list of all files in the directory
rawlist = getFileList(dir);
//used for making new tables
bin = newArray("");

// creates a list containing only DV files 
for ( i=0; i < rawlist.length; i++) {
	if (matches(rawlist[i], "^.*.dv$") == true) {
		list = Array.concat(list,rawlist[i]);	
	}
}
// removes the 0 from the beginning of the array created by concatenation on the first iteration of the above for loop
list = Array.deleteIndex(list, 0);

// creates new directory where the csv's and images with blind names will be saved
File.makeDirectory(dir + "/blind/");
blind_dir = dir + "/blind/";

//creates the blind key table
Table.create("Blind Key");
Table.setColumn("Image Title", list);

// generates a random name for each image, copies them to the blind folder, and saves the blind table key into the blind folder
for (i=0; i < list.length; i++) {
	rand = randomString();
	Table.set("Blind Title", i, rand);
	Table.save(blind_dir + "BlindKey" + ".csv");
	
	File.copy(dir + list[i], blind_dir + rand + ".dv");
}

// gets the array of blind names to make a blind measurement table
blind_names = Table.getColumn("Blind Title");

// creates the blind measurement table and saves the table to the blind folder
Table.create("Blind Measurement Table");
Table.setColumn("Blind Title", blind_names);
Table.save(blind_dir + "Blind Measurement Table" + ".csv");


//function for creating random names
function randomString() {
    // We define the template and measure the number of positions
    template = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    nChars = lengthOf(template);
    // We define an empty string that will hold the result
    string = "";
    // We will want a final string to be 10-characters long
    for (i=0; i<10; i++) {
        // Define a random position between 0 and the penultime character in template
        idx = maxOf(0, round(random()*nChars-1));
        // Extract and concatenate characters
        string += substring(template, idx, idx+1);
    }
    // return result
    return string;
}