print("*****Loaded CMSC_disp.nas *****");
#this works.
#var jmr = canvas.new({
#  "name": "jmr",
#  "size": [128, 16],
#  "view": [128, 16],
#  "mipmapping": 1,
#});
#jmr.addPlacement({"node": "jmr_canvas", "texture": "jmrcanvas.png"});
# jmr.setColorBackground(0.018, 0.020, 0.05, 1.00);
#jmrDispGroup = jmr.createGroup();
#jmrDispGroup.show();
#jmrTxt = jmrDispGroup.createChild("text")
#      .setFontSize(16, 0.95)
#      .setColor(0,1,0)
#      .setAlignment("left-top")
#      .setFont("LED-8.ttf")
#      .setText("JMRTXT");

#jmrTxt.setText("OFF");
var jmr = nil;
var mws = nil;
var cms = nil;
var cmsc = canvas.new({
  "name": "cmsc",
  "size": [128, 64],
  "view": [128,64],
  "mipmapping": 1,
});

cmsc.addPlacement({"node": "cmsc_canvas", "texture": "CMSCcanvas.png"});
cmsc.setColorBackground(0.018, 0.020, 0.05, 1.00);
cmscDispGroup = cmsc.createGroup();
#cmspDispGroup.set("color", 0,1,0,1)
cmscDispGroup.set("font", "LED-8.ttf");
#cmscDispGroup.show();

jmr = cmscDispGroup.createChild("text")
    .setFontSize(16, 0.8)
    .setColor(0,1,0)
    .setAlignment("left-top")
    .setText("JMRTXT");

mws = cmscDispGroup.createChild("text")
    .setFontSize(16, 0.8)
    .setColor(0,1,0)
    .setAlignment("left-top")
    .setText("MWSTXT")
    .setTranslation(0, 17);

cmsmode = cmscDispGroup.createChild("text")
    .setFontSize(16, 0.8)
    .setColor(0,1,0)
    .setAlignment("left-top")
    .setText("D")
    .setTranslation(0, 35);

chaffcount = cmscDispGroup.createChild("text")
    .setFontSize(16, 0.8)
    .setColor(0,1,0)
    .setAlignment("left-top")
    .setText("000")
    .setTranslation(18, 35);

flarecount = cmscDispGroup.createChild("text")
    .setFontSize(16, 0.8)
    .setColor(0,1,0)
    .setAlignment("left-top")
    .setText("000")
    .setTranslation(70, 35);

#TODO: Add cms disp diamond + cms programs (maybe.)

jmr.setText("ABCD1234");
mws.setText("ABCD1234");

var cmspLoop = func {
  if (getprop("A-10/avionics/ew-mode-knob") == 1) {
     cmsmode.setText("M");
  } else {
    cmsmode.setText("X");
  }
  settimer(cmspLoop, 0.25);
}

var cmsCountLoop = func {
  var cmsCount = getprop("ai/submodels/submodel[3]/count");
  chaffcount.setText(sprintf("%3d", math.clamp(cmsCount,000,300)));
  flarecount.setText(sprintf("%3d", math.clamp(cmsCount,000,300)));
  settimer(cmsCountLoop, 0.25);
}

var jmrLoop = func {
  if (getprop("A-10/avionics/ew-jmr-switch") == 1) {
     jmr.setText("INOP");
  } else {
    jmr.setText("OFF");
  }
  settimer(jmrLoop, 1);
}

var mwsLoop = func {
  var mwsProp = getprop("payload/armament/MAW-active");
  if (getprop("A-10/avionics/ew-mws-switch") == 1) {
    if (getprop("payload/armament/MAW-active") == 1) {
      mws.setText("INBOUND");
    } else {
      mws.setText("ACTIVE");
    }
  } else {
    mws.setText("OFF");
    }
  settimer(mwsLoop, 0.25);
}



cmspLoop();
cmsCountLoop();
mwsLoop();
jmrLoop();


#vars for dynamic content
#jmrStatus = "";
#mwsStatus = "";
#chaff = "";
#flare = "";
#cmspMode = ""; #X: STBY, M: MAN, S: Semi, A: Auto


print("***** End CMSC_disp.nas *****");
