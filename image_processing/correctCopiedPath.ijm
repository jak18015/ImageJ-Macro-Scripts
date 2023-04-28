macro "CorrectCopiedPath" {
	copiedPath = getString("paste the path", "");
	replace(copiedPath, "\\", "/");
	print(copiedPath);
}
