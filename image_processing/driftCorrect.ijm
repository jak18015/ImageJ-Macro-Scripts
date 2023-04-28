setBatchMode(true);
dir1 = "Z:\\Jacob\\Microscopy\\20221113_myof-aid_ac-emfp\\processed\\bleachCorrectionHistogramMatching\\";
dir2 = "Z:\\Jacob\\Microscopy\\20221024_myof-aid_ac-emfp\\processed\\bleachCorrectionHistogramMatching\\";
dir1out = "Z:\\Jacob\\Microscopy\\20211028_MyoF-AID_AC-EmFP_STREAM\\processed\\bleachCorrectDriftCorrectV2\\"
dir2out = "Z:\\Jacob\\Microscopy\\20221024_myof-aid_ac-emfp\\processed\\bleachCorrectDriftCorrect\\";
L1 = getFileList(dir1);
L1out = newArray();
for (i=0; i < L1.length; i++) {
	out = dir1out + L1[i];
	L1out = Array.concat(L1out, out);
	L1[i] = dir1 + L1[i];
}
L2 = getFileList(dir2);
L2out = newArray();
for (i=0; i < L2.length; i++) {
	out = dir2out + L2[i];
	L2out = Array.concat(L2out, out);
	L2[i] = dir2 + L2[i];
}
L3 = Array.concat(L1,L2);
L3out = Array.concat(L1out, L2out);

for (i = 0; i < L3.length; i++) {
	if (matches(L3[i], ".*_R3D.tif")) {
		open(L3[i]);	
		run("Correct 3D drift", "channel=1 multi_time_scale sub_pixel edge_enhance only=0 lowest=1 highest=1 max_shift_x=10.000000000 max_shift_y=10.000000000 max_shift_z=10");
		save(L3out[i]);
	}
}
