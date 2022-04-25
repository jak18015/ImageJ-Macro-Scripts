dir = getDirectory("files to rename");
list = getFileList(dir);
for (i = 0; i < list.length; i++) {
	oldname = File.getName(dir+list[i]);
	oldname = split(oldname, "_");
	Array.print(oldname);
	old1 = Array.slice(oldname,0,3);
	old2 = Array.slice(oldname,3);
	Array.print(old1);
	Array.print(old2);
	new1 = newArray("minusiaa");
	Array.print(new1);
	new1 = Array.concat(old1,new1,old2);
	Array.print(new1);
	new2 = String.join(new1, "_");
	print(new2);
	File.rename(dir+list[i], dir+new2);
}
