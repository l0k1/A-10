print("AN/ARC-164 loading ************");

var freq = nil;
var chan = nil;
var displays = canvas.new({
	"name": "ARC164",
	"size": [128, 64],
	"view": [128,64],
	"mipmapping": 1,
	});

displays.addPlacement({"node": "UHF_Displays", "texture": "arc-164-canvas.png"});
displays.setColorBackground(0.018, 0.020, 0.05, 1.00);
displayGroup = displays.createGroup();
displayGroup.show();
#cmspDispGroup.set("color", 0,1,0,1)
displayGroup.set("font", "DSEG/DSEG14/Classic/DSEG14ClassicRegular.ttf");

freq = displayGroup.createChild("text")
	.setFontSize(27,1)
	.setColor(0.96,0.99,0.34)
	.setAlignment("left-top")
	.setText("291.725");
chan = displayGroup.createChild("text")
	.setFontSize(27,1.2)
	.setColor(0.96,0.99,0.34)
	.setAlignment("left-top")
	.setTranslation(-1.5,32)
	.setText("04");

