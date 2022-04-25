//Get image dimensions for frame number, and title for naming in results table
getDimensions(width, height, channels, slices, frames);
title = getTitle();
path = getDirectory("image");
setOption("WaitForCompletion", true);
	waitForUser("Draw line", "Draw line segment");
roiManager("add");
roiManager("select", 0);
roiManager("rename", title);

for (i = 0; i < frames; i++) {
    profile = getProfile();
    Array.print(profile);
    run("Next Slice [>]");
}
save(path + title + "_LINESCAN.txt");
roiManager("save selected", path + title + "_ROI.zip");