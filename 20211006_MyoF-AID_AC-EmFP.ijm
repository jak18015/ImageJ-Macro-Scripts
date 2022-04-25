// This script applies to the image set with the same name located in my Microscopy folder
// The goals of this script are as follows:
// 1. Since this is a 1-channel image, Edit the LUT to grey
// 2. Split the z channel into the 3 respective planes
// 3. Set the brightness and contrast for optimal viewing of each slice
// 4. Save each z as an uncompressed .avi with a 15fps frame rate into the output folder, the "processed" folder within the parent image folder


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

ImageTitle=getTitle();
resetMinAndMax
saveAs("avi", "compression=None frame=15 save=[" + ImageTitle + ".avi]");