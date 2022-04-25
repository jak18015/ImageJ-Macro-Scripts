list = getList("image.titles");
for( j=0; j<list.length; j++) {
	selectWindow(list[j]);
	run("Out [-]");
	run("Out [-]");
	run("Out [-]");
	run("Out [-]");
	}
for(i = 0; i<list.length; i++) {
	selectWindow(list[i]);
	run("Original Scale");
	if (getBoolean("horizontal or vertical parasite orientation", "horizontal", "vertical") == true) {
		if (getBoolean("parasite pointing left or right", "left", "right") == true) {
			run("Rotate 90 Degrees Right");
			}
		else {
			run("Rotate 90 Degrees Left");
		}
		}
	else {
		if (getBoolean("parasite pointing down or up", "down", "up") == true) {
			run("Flip Vertically");
			}	
		}
	run("Out [-]");
	run("Out [-]");
	run("Out [-]");
	}
list = getList("image.titles");
for (q = 0; q < list.length; q++) {
	selectWindow(list[q]);
	run("Original Scale");
}

