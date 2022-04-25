str = “”;
for (i=1;i<=nSlices; i++){
profile = getProfile();
for (j=1; j<profile.length; j++) { str=str+profile[j] + “\t”; } str=str+”\n”; run(“Next Slice [>]”);
}
print(str)
dir = getDirectory(“image”);
f = File.open(dir+”/profile.txt”);
print(f, str);