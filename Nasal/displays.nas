# Based upon display-system.nas from F-16

print("DISPLAYS LOADING");

setprop("fdm/jsbsim/electric/output/tvtab2",1);

var symbolSize = {
	tad: {
	    contacts: 200,
	    bullseye: 1,
	    ownship: 75,
	    compasFlag: 16,
	    cursor: 16,
	    cursorGhostAir: 18,
	    cursorGhostGnd: 12,
	    steerpoint: 5,
	    contactVelocity: 0.0045,
	    markpoint: 18,
	},
};

var values = {
	vsd: {
		terrainCenter: 0,
	},
	hdg: {
		indicated: 0,
		tape: {
			l1: "0",
			l2: "0",
			l3: "0",
			r1: "0",
			r2: "0",
			r3: "0",
			middleOffset: 0,
			offset: 0,
			middleText: 0,
			indicatedHdg: 0,
		},
	},
};

var margin = {
	device: {
		buttonText: 15,
		fillHeight: 1,
		outline: 1,
	},
	bullseye: {
		y: 50,
		x: 210,
		text: 20,
	},
	tfr: {
		sides: 20,
		bottom: 35,
	},
	has: {
		statusBox: 40,
		searchText: 45,
	},
};

var lineWidth = {
	device: {
		outline: 2,
		x: 3,
		soi: 4,
	},
	bullseyeLayer: {
		eye: 2.5,
		ref: 2,
	},
	arrows: {
		triangle: 3,
	},
	tad: {
	    bullseye: 3,
	    rangeRing: 2,
	    ownship: 2,
	    radarCone: 3,
	    threatRing: 3,
	    line: 2,
	    route: 6,
	    targetTrack: 2,
	    targetsDL: 6,
	    targets: 6,
	    designation: 2,
	    cursor: 2,
	    cursorGhost: 1.5,
	    rangeRings: 8,
	    grid: 4
	},
};

var font = {
	device: {
		main: 18,
		osbLabels: 30,
	},
	tad: {
		contacts: 25,
		gridText: 25,
	},
};

var zIndex = {
	device: {
		osb: 100,
		page: 5,
		pullUp: 20000,
		layer: 200,
		map: 1,
		mapOverlay: 7,
	},
	deviceObs: {
		text: 10,
		outline: 11,
		fill: 9,
		feedback: 7,
		soi: 8,
		soiText: 10,
	},
	tad: {
		mapTiles: 1,
		ownship: 2,
		contacts: 9,
		grid: 3,
		gridText: 4,
		attribution: 4,
		rangeRings: 7,
		lines: 8,
	},

};

var COLOR_YELLOW     = [1.00,1.00,0.00];
var COLOR_BLUE_LIGHT = [0.50,0.50,1.00];
var COLOR_BLUE_WHITE = [0.75,0.75,1.00];
var COLOR_BLUE_VERY_DARK  = [0.00,0.00,0.25];
var COLOR_BLUE_DARK  = [0.00,0.00,0.50];
var COLOR_SKY_LIGHT  = [0.30,0.30,1.00];
var COLOR_RED        = [1.00,0.00,0.00];
var COLOR_WHITE      = [1.00,1.00,1.00];
var COLOR_BROWN      = [0.71,0.40,0.11];
var COLOR_BROWN_DARK = [0.56,0.32,0.09];
var COLOR_GRAY       = [0.25,0.25,0.25,0.50];
var COLOR_GRAY_LIGHT = [0.75,0.75,0.75,0.50];
var COLOR_SKY_DARK   = [0.15,0.15,0.60];
var COLOR_BLACK      = [0.00,0.00,0.00];
var COLOR_BUTTON_TEXT = COLOR_WHITE;


# OSB text
var colorText1 = [getprop("/sim/model/MFD-color/text1/red"), getprop("/sim/model/MFD-color/text1/green"), getprop("/sim/model/MFD-color/text1/blue"), 1];

# Info text
var colorText2 = [getprop("/sim/model/MFD-color/text2/red"), getprop("/sim/model/MFD-color/text2/green"), getprop("/sim/model/MFD-color/text2/blue"), 1];

# red threat circles
var colorCircle1 = [getprop("/sim/model/MFD-color/circle1/red"), getprop("/sim/model/MFD-color/circle1/green"), getprop("/sim/model/MFD-color/circle1/blue")];

# yellow threat circles
var colorCircle2 = [getprop("/sim/model/MFD-color/circle2/red"), getprop("/sim/model/MFD-color/circle2/green"), getprop("/sim/model/MFD-color/circle2/blue")];

# green threat circles
var colorCircle3 = [getprop("/sim/model/MFD-color/circle3/red"), getprop("/sim/model/MFD-color/circle3/green"), getprop("/sim/model/MFD-color/circle3/blue")];

# Not used
var colorDot1 = [getprop("/sim/model/MFD-color/dot1/red"), getprop("/sim/model/MFD-color/dot1/green"), getprop("/sim/model/MFD-color/dot1/blue")];

# White/green radar search targets
var colorDot2 = [getprop("/sim/model/MFD-color/dot2/red"), getprop("/sim/model/MFD-color/dot2/green"), getprop("/sim/model/MFD-color/dot2/blue")];

# Datalink wingman
var colorDot4 = [getprop("/sim/model/MFD-color/dot4/red"), getprop("/sim/model/MFD-color/dot4/green"), getprop("/sim/model/MFD-color/dot4/blue")];

# Bullseye and STPT symbol on FCR
var colorBullseye = [getprop("/sim/model/MFD-color/bullseye/red"), getprop("/sim/model/MFD-color/bullseye/green"), getprop("/sim/model/MFD-color/bullseye/blue")];

# Bulleye direction to ownship text
var colorBetxt = [getprop("/sim/model/MFD-color/betxt/red"), getprop("/sim/model/MFD-color/betxt/green"), getprop("/sim/model/MFD-color/betxt/blue")];

# Own ship in HSD
var colorLine1  = [getprop("/sim/model/MFD-color/line1/red"), getprop("/sim/model/MFD-color/line1/green"), getprop("/sim/model/MFD-color/line1/blue")];

# Horizon in FCR
var colorLine2  = [getprop("/sim/model/MFD-color/line2/red"), getprop("/sim/model/MFD-color/line2/green"), getprop("/sim/model/MFD-color/line2/blue")];

# Steerpoints, cursor and many other symbols
var colorLine3  = [getprop("/sim/model/MFD-color/line3/red"), getprop("/sim/model/MFD-color/line3/green"), getprop("/sim/model/MFD-color/line3/blue")];

# EXP square
var colorLine4  = [getprop("/sim/model/MFD-color/line4/red"), getprop("/sim/model/MFD-color/line4/green"), getprop("/sim/model/MFD-color/line4/blue")];

# Range rings in HSD
var colorLine5  = [getprop("/sim/model/MFD-color/line5/red"), getprop("/sim/model/MFD-color/line5/green"), getprop("/sim/model/MFD-color/line5/blue")];

# FCR range rings and steerpoint legs
var colorLines  = [getprop("/sim/model/MFD-color/lines/red"), getprop("/sim/model/MFD-color/lines/green"), getprop("/sim/model/MFD-color/lines/blue")];

# Not used
var colorLines2 = [getprop("/sim/model/MFD-color/lines2/red"), getprop("/sim/model/MFD-color/lines2/green"), getprop("/sim/model/MFD-color/lines2/blue")];


var colorCubeRed = [255,0,0];
var colorCubeGreen = [0,255,0];
var colorCubeCyan = [0,255,255];

var colorBackground = [0.005,0.005,0.005, 1];
var variantID = 1;
var COLOR_YELLOW     = [1.00,1.00,0.00];
var COLOR_BLUE_LIGHT = [0.50,0.50,1.00];
var COLOR_SKY_LIGHT  = [0.30,0.30,1.00];
var COLOR_RED        = [1.00,0.00,0.00];
var COLOR_WHITE      = [1.00,1.00,1.00];
var COLOR_BROWN      = [0.71,0.40,0.11];
var COLOR_BROWN_DARK = [0.56,0.32,0.09];
var COLOR_GRAY       = [0.25,0.25,0.25,0.50];
var COLOR_GRAY_LIGHT = [0.75,0.75,0.75,0.50];
var COLOR_SKY_DARK   = [0.15,0.15,0.60];
var COLOR_BLACK      = [0.00,0.00,0.00];

var str = func (d) {return ""~d};

var MM2TEX = 2;
var texel_per_degree = 2*MM2TEX;
var KT2KMH = 1.85184;


var PUSHBUTTON   = 0;
var ROCKERSWITCH = 1;

var CursorHSD = 1;
var FACH3 = variantID == 4 or variantID >= 6;#MLU Tape M4.3

# Map vars - Most of this + TAD code is based on F-16 cdu.nas

var tile_size = 256;
var type = "light_nolabels";
var meterPerPixel = [156412,78206,39103,19551,9776,4888,2444,1222,610.984,305.492,152.746,76.373,38.187,19.093,9.547,4.773,2.387,1.193,0.596,0.298];# at equator
var zooms      = [6, 7, 8, 9, 10, 11, 13];
var zoomLevels = [320, 160, 80, 40, 20, 10, 2.5];
var zoomsONC      = [7, 7, 8, 9, 10, 10]; #These are fpr arcgis_onc only, because there is a much more limited range of tile levels
var zoomLevelsONC = [320, 160, 80, 40, 20, 10];
var zoom_init = 2;
var zoom_curr  = zoom_init;
var zoom = zooms[zoom_curr];
var M2TEX = 1/(meterPerPixel[zoom]*math.cos(getprop('/position/latitude-deg')*D2R));
var maps_base = getprop("/sim/fg-home") ~ '/cache/mapsA10';

var providers = {
    arcgis_terrain: {
                templateLoad: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                templateStore: "/arcgis/{z}/{y}/{x}.jpg",
                attribution: ""},
    arcgis_topo: {
                templateLoad: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}",
                templateStore: "/arcgis-topo/{z}/{y}/{x}.jpg",
                attribution: ""},
    arcgis_vfr: {
                templateLoad: "https://tiles.arcgis.com/tiles/ssFJjBXIUyZDrSYZ/arcgis/rest/services/VFR_Sectional/MapServer/tile/{z}/{y}/{x}",
                templateStore: "/arcgis-vfr/{z}/{y}/{x}.jpg",#some of them are png though :(
                attribution: "",
                min: 8, max: 12},
    arcgis_onc: {
                templateLoad: "https://services.arcgisonline.com/arcgis/rest/services/Specialty/World_Navigation_Charts/MapServer/tile/{z}/{y}/{x}",
                templateStore: "/onc/{z}/{y}/{x}.jpg",
                attribution: "",
                min: 8, max: 10},                
};

var providerOption = 1;
var providerOptionLast = providerOption;
var providerOptionTags = ["TOPO ","PHOTO ","VFR_US ","ONC "];
var providerOptions = [
# This one works on Linux and Windows only
["arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo"],
# This one works on MacOS also, so is default
["arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain"],
["arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr"],
["arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc"]
];

var zoom_provider = providerOptions[providerOption];

var makeUrl   = string.compileTemplate(providers[zoom_provider[zoom_curr]].templateLoad);
#var makeUrl   = string.compileTemplate('https://cartodb-basemaps-c.global.ssl.fastly.net/{type}/{z}/{x}/{y}.png');
#var makePath  = string.compileTemplate(maps_base ~ '/cartoL/{z}/{x}/{y}.png');
var makePath  = string.compileTemplate(maps_base ~ providers[zoom_provider[zoom_curr]].templateStore);
var num_tiles = [7, 7];# must be uneven, 7x7 will ensure we never see edge of map tiles when canvas is 1024px high.

var center_tile_offset = [(num_tiles[0] - 1) / 2,(num_tiles[1] - 1) / 2];#(width/tile_size)/2,(height/tile_size)/2];
#  (num_tiles[0] - 1) / 2,
#  (num_tiles[1] - 1) / 2
#];

##
# initialize the map by setting up
# a grid of raster images

var tiles = setsize([], num_tiles[0]);


var last_tile = [-1,-1];
var last_type = type;
var last_zoom = zoom;
var lastLiveMap = 1;#getprop("f16/displays/live-map");
var lastDay   = 1;

var CLEANMAP = 0;
var PLACES   = 1;

var COLOR_DAY   = "rgb(255,255,255)";#"rgb(128,128,128)";# color fill behind map which will modulate to make it darker.
var COLOR_NIGHT = "rgb(128,128,128)";

# var vector_aicontacts_links = [];
# var DLRecipient = emesary.Recipient.new("DLRecipient");
# var startDLListener = func {
#     DLRecipient.radar = radar_system.dlnkRadar;
#     DLRecipient.Receive = func(notification) {
#         if (notification.NotificationType == "DatalinkNotification") {
#             printf("DL recv: %s", notification.NotificationType);
#             if (me.radar.enabled == 1) {
#                 vector_aicontacts_links = notification.vector;
#             }
#             return emesary.Transmitter.ReceiptStatus_OK;
#         }
#         return emesary.Transmitter.ReceiptStatus_NotProcessed;
#     };
#     emesary.GlobalTransmitter.Register(DLRecipient);
# }

var roundAbout = func(x) {
	var y = x - int(x);
	return y < 0.5 ? int(x) : 1 + int(x);
}

var hdgOutput = "";
var hdgText = func(x) {
	if (x == 0) {
		return "N";
	} else if (x == 9) {
		return "E";
	} else if (x == 18) {
		return "S";
	} else if (x == 27) {
		return "W";
	} else {
		hdgOutput = sprintf("%d", x);
		return hdgOutput;
	}
}

#  ██████  ███████ ██    ██ ██  ██████ ███████ 
#  ██   ██ ██      ██    ██ ██ ██      ██      
#  ██   ██ █████   ██    ██ ██ ██      █████   
#  ██   ██ ██       ██  ██  ██ ██      ██      
#  ██████  ███████   ████   ██  ██████ ███████ 
#                                              
#                                              

var DisplayDevice = {
	new: func (name, resolution, uvMap, node, texture) {
		var device = {parents : [DisplayDevice] };
		device.canvas = canvas.new({
                			"name": name,
                           	"size": resolution,
                            "view": resolution,
                    		"mipmapping": 1
                    	});
		device.resolution = resolution;
		device.canvas.addPlacement({"node": node, "texture": texture});
		device.controls = {master:{"device": device}};
		device.controlPositions = {};
		device.listeners = [];
		device.uvMap = uvMap;
		device.name = name;
		device.system = nil;
		#device.addPullUpCue();
		device.new = func {return nil;};
		#device.timer = maketimer(0.25, device, device.loop);
		return device;
	},

	del: func {
		me.canvas.del();
		foreach(l ; me.listeners) {
			call(func removelistener(l),[],nil,nil,var err = []);
		}
		me.listeners = [];
		#call(func me.timer.stop(),[],nil,nil,err = []);
		#me.timer = nil;
		me.del = func {};
	},

	start: func {
		#me.timer.start();#timers dont really work in modules
		#me.start=func{};
	},

	loop: func {
		me.update(notifications.frameNotification);
		me.setSOI(me["aircraftSOI"] == 1);
	},

	setupProperties: func {
        me.input = {
            alt_ft:               "instrumentation/altimeter/indicated-altitude-ft",
            alt_true_ft:          "position/altitude-ft",
            heading:              "instrumentation/heading-indicator/indicated-heading-deg",
            radarStandby:         "instrumentation/radar/radar-standby",
            rad_alt:              "instrumentation/radar-altimeter/radar-altitude-ft",
            rad_alt_ready:        "instrumentation/radar-altimeter/ready",
            rmActive:             "autopilot/route-manager/active",
            rmDist:               "autopilot/route-manager/wp/dist",
            rmId:                 "autopilot/route-manager/wp/id",
            rmBearing:            "autopilot/route-manager/wp/true-bearing-deg",
            RMCurrWaypoint:       "autopilot/route-manager/current-wp",
            roll:                 "instrumentation/attitude-indicator/indicated-roll-deg",
            headTrue:             "orientation/heading-deg",
            roll:                 "orientation/roll-deg",
            pitch:                "orientation/pitch-deg",
            nav0InRange:          "instrumentation/nav[0]/in-range",
            APLockHeading:        "autopilot/locks/heading",
            APTrueHeadingErr:     "autopilot/internal/true-heading-error-deg",
            APnav0HeadingErr:     "autopilot/internal/nav1-heading-error-deg",
            APHeadingBug:         "autopilot/settings/heading-bug-deg",
            RMActive:             "autopilot/route-manager/active",
            nav0Heading:          "instrumentation/nav[0]/heading-deg",
            ias:                  "instrumentation/airspeed-indicator/indicated-speed-kt",
            tas:                  "instrumentation/airspeed-indicator/true-speed-kt",
            gearsPos:             "gear/gear/position-norm",
            latitude:             "position/latitude-deg",
            longitude:            "position/longitude-deg",
            mach:                 "instrumentation/airspeed-indicator/indicated-mach",
            inhg:                 "instrumentation/altimeter/setting-inhg",
            tacanCh:              "instrumentation/tacan/display/channel",
            ilsCh:                "instrumentation/nav[0]/frequencies/selected-mhz",
            servStatic:				 "systems/static/serviceable",
            servPitot:				 "systems/pitot/serviceable",
            servAtt                   : "instrumentation/attitude-indicator/serviceable",
            servHead                  : "instrumentation/heading-indicator/serviceable",
            servTurn                  : "instrumentation/turn-indicator/serviceable",
            dlink_code                : "instrumentation/datalink/channel",
            scratchpadHolding		  : "A-10/displays/mpcd/holding",

        };

        foreach(var name; keys(me.input)) {
            me.input[name] = props.globals.getNode(me.input[name], 1);
        }
    },

	setColorBackground: func (colorBackground) {
		me.canvas.setColorBackground(colorBackground);
	},

	addControls: func (type, prefix, from, to, property, positions) {
		if (contains(DisplayDevice, prefix)) {print("Illegal prefix");return;}
		me[prefix] = func (node) {
			me.tempActionValue = node.getValue();
			
			if (me.tempActionValue > 0) {
				#printDebug(me.name,": ",prefix, " action :", me.tempActionValue);
				me.cntlFeedback.setTranslation(me.controlPositions[prefix][me.tempActionValue-1]);
				me.cntlFeedback.setVisible(FACH3);
				me.cntlFeedback.update();
				#print("fb ON  ",me.controlPositions[prefix][me.tempActionValue-1][0],",",me.controlPositions[prefix][me.tempActionValue-1][1]);
				me.controlAction(type, prefix~(me.tempActionValue), me.tempActionValue);
			} else {
				me.cntlFeedback.hide();
				me.cntlFeedback.update();
				#print("fb OFF  ");
			}
		};
		me.controlPositions[prefix] = positions;
		for(var i = from; i <= to; i += 1) {
			me.controls[prefix~i] = {
				parents: [me.controls.master],
				name: prefix~i,
			};
		}
		if (me["controlGrp"] == nil) {
			me.controlGrp = me.canvas.createGroup()
								.set("z-index", zIndex.device.osb)
								.set("font","A10-HUD.ttf");
		}
		me.controls.master.setControlText = func (text, positive = 1, outline = 0, rear = 0, blink = 0) {
			# rear is adjustment of the fill in x axis

			# store for later SWAP option
			me.contentText = text;
			me.contentPositive = positive;
			me.contentOutline = outline;

			if (text == nil or text == "") {
				me.letters.setVisible(0);
				me.outline.setVisible(0);
				me.fill.setVisible(0);
				#me.fill.setColor((!positive)?me.device.colorFront:me.device.colorBack);
				#me.fill.setColorFill((!positive)?me.device.colorFront:me.device.colorBack);
				return;
			}
			me.letters.setVisible(1);
			me.letters.setText(text);
			me.letters.setColor(positive?me.device.colorFront:me.device.colorBack);
			me.outline.setVisible(positive and outline);
			me.fill.setVisible(1);
			me.fill.setColor((!positive)?me.device.colorFront:me.device.colorBack);
			me.fill.setColorFill((!positive)?me.device.colorFront:me.device.colorBack);
			me.linebreak = find("\n", text) != -1?2:1;
			me.lettersCount = size(text);
			if (me.linebreak == 2) {
				me.split = split("\n", text);
				if (size(me.split)>1) me.lettersCount = math.max(size(me.split[0]),size(me.split[1]));
			}
			me.fill.setScale(me.lettersCount/4,me.linebreak);
			me.outline.setScale(1.05*me.lettersCount/4,me.linebreak);
		};
		append(me.listeners, setlistener(property, me[prefix],0,0));
	},

	resetControls: func {
		me.tempKeys = keys(me.controls);
		foreach(var key; me.tempKeys) {
			if (me.controls[key]["parents"]!= nil) me.controls[key].setControlText("");
		}
	},

	update: func (noti) {
		if (me.system.supportSOI()) {
			# Lines or text
			me.setSOI(me["aircraftSOI"] == 1);
		} else {
			# Neither
			me.setSOI(-1);
		}
		me.system.update(noti);
	},

	controlAction: func {},

	setDisplaySystem: func (system) {
		me.system = system;
		system.setDevice(me);
	},

	addControlText: func (prefix, controlName, pos, posIndex, alignmentH=0, alignmentV=0) {
		me.tempX = me.controlPositions[prefix][posIndex][0]+pos[0];
		me.tempY = me.controlPositions[prefix][posIndex][1]+pos[1];

		me.alignment  = alignmentH==0?"center-":(alignmentH==-1?"left-":"right-");
		me.alignment ~= alignmentV==0?"center":(alignmentV==-1?"top":"bottom");
		me.letterWidth  = 0.7 * font.device.osbLabels;
		me.letterHeight = 0.9 * font.device.osbLabels;
		me.myCenter = [me.tempX, me.tempY];
		me.controls[controlName].letters = me.controlGrp.createChild("text")
				.set("z-index", zIndex.deviceObs.text)
				.setAlignment(me.alignment)
				.setTranslation(me.tempX, me.tempY)
				.setFontSize(font.device.osbLabels, 1.1)
				.setText(right(controlName,4))
				.setColor(me.colorFront);
		me.controls[controlName].outline = me.controlGrp.createChild("path")
				.set("z-index", zIndex.deviceObs.outline)
				.setStrokeLineJoin("round") # "miter", "round" or "bevel"
				.moveTo(me.tempX-me.letterWidth*2*alignmentH-me.letterWidth*2-me.myCenter[0]-margin.device.outline, me.tempY-me.letterHeight*alignmentV*0.5-me.letterHeight*0.5-margin.device.outline-me.myCenter[1])
				.horiz(me.letterWidth*4+margin.device.outline*2)
				.vert(me.letterHeight*1.0+margin.device.outline*2)
				.horiz(-me.letterWidth*4-margin.device.outline*2)
				.vert(-me.letterHeight*1.0-margin.device.outline*2)
				.close()
				.setColor(me.colorFront)
				.hide()
				.setStrokeLineWidth(lineWidth.device.outline)
				.setTranslation(me.myCenter);
		me.controls[controlName].fill = me.controlGrp.createChild("path")
				.set("z-index", zIndex.deviceObs.fill)
				.setStrokeLineJoin("round") # "miter", "round" or "bevel"
				.moveTo(me.tempX-me.letterWidth*2*alignmentH-me.letterWidth*2-me.myCenter[0], me.tempY-me.letterHeight*alignmentV*0.5-me.letterHeight*0.5-margin.device.fillHeight-me.myCenter[1])
				.horiz(me.letterWidth*4)
				.vert(me.letterHeight*1.0+margin.device.fillHeight)
				.horiz(-me.letterWidth*4)
				.vert(-me.letterHeight*1.0-margin.device.fillHeight)
				.close()
				.setColorFill(me.colorBack)
				.setColor(me.colorBack)
				.setStrokeLineWidth(lineWidth.device.outline)
				.setTranslation(me.myCenter);
	},

	addPullUpCue: func {
        me.pullup_cue = me.canvas.createGroup().set("z-index", zIndex.device.pullUp);
        me.pullup_cue.createChild("path")
           .moveTo(0, 0)
           .lineTo(me.uvMap[0]*me.resolution[0], me.uvMap[1]*me.resolution[1])
           .moveTo(0, me.uvMap[1]*me.resolution[1])
           .lineTo(me.uvMap[0]*me.resolution[0], 0)
           .setStrokeLineWidth(lineWidth.device.x)
           .setColor(colorCircle1);
    },

    pullUpCue: func (vis) {
    	me.pullup_cue.setVisible();
    },

    addControlFeedback: func {
    	me.feedbackRadius = 35;
    	me.cntlFeedback = me.controlGrp.createChild("path")
	            .moveTo(-me.feedbackRadius,0)
	            .arcSmallCW(me.feedbackRadius,me.feedbackRadius, 0,  me.feedbackRadius*2, 0)
	            .arcSmallCW(me.feedbackRadius,me.feedbackRadius, 0, -me.feedbackRadius*2, 0)
	            .close()
	            .setStrokeLineWidth(2)
	            .set("z-index",zIndex.deviceObs.feedback)
	            .setColor(colorDot2[0],colorDot2[1],colorDot2[2],0.15)
	            .setColorFill(colorDot2[0],colorDot2[1],colorDot2[2],0.3)
	            .hide();
    },

	addSOILines: func () {
		me.tempMarginX = 11;
		me.tempMarginY = 10;
		me.soiLine = me.controlGrp.createChild("path")
				.set("z-index", zIndex.deviceObs.soi)
				.moveTo(me.tempMarginX,me.tempMarginY)
				.horiz(me.uvMap[0]*me.resolution[0]-me.tempMarginX*2)
				.vert(me.resolution[1]-me.tempMarginY*2)
				.horiz(-me.uvMap[0]*me.resolution[0]+me.tempMarginX*2)
				.lineTo(me.tempMarginX,me.tempMarginY)
				.setColor(me.colorFront)
				.hide()
				.setStrokeLineWidth(lineWidth.device.soi);
		return me.soiLine;
	},

	addSOIText: func (info) {
		me.soiText = me.controlGrp.createChild("text")
				.set("z-index", zIndex.deviceObs.soiText)
				.setColor(me.colorFront)
				.setAlignment("center-center")
				.setTranslation(me.uvMap[0]*me.resolution[0]*0.5, me.uvMap[1]*me.resolution[1]*0.30)
				.setFontSize(me.fontSize)
				.setText(info);
		return me.soiText;
	},

	setSOI: func (soi) {
		# -1 will remove both text and square
		me.soiLine.setVisible(1); #really good hack to simulate it always being SOI...
		# me.soiText.setVisible(soi == 1);
		me.soiText.setVisible(0);
		me.soi = soi;
	},

	setF16SOI: func (no) {
		# What number f16 regards this device as
		me.aircraftSOI = no;
	},

	getSOIPrio: func {
		return me.system.getSOIPrio();
	},

	setControlTextColors: func (foreground, background) {
		me.colorFront = foreground;
		me.colorBack  = background;
	},

	initPage: func (page) {
		printDebug(me.name," init page ",page.name);
		if (page.needGroup) {
			me.tempGrp = me.canvas.createGroup()
							.set("z-index", zIndex.device.page)
							.set("font","A10-HUD.ttf")
							.hide();
			page.group = me.tempGrp;
		}
		page.device = me;
	},

	initLayer: func (layer) {
		printDebug(me.name," init layer ",layer.name);
		me.tempGrp = me.canvas.createGroup()
						.set("z-index", zIndex.device.layer)
						.set("font","A10-HUD.ttf")
						.hide();
		layer.group = me.tempGrp;
		layer.device = me;
		layer.setup();
	},

	setSwapDevice: func (swapper) {
		me.swapWith = swapper;
	},

	swap: func {
		var myPageName = me.system.currPage.name;
		var otherPageName = me.swapWith.system.currPage.name;
		var mySoi = me.soi;
		var otherSoi = me.swapWith.soi;
		me.system.selectPage(otherPageName);
		me.swapWith.system.selectPage(myPageName);
		me.setSOI(otherSoi);
		me.swapWith.setSOI(mySoi);
		# The ==1 must be here below since soi can be -1 in the device:
		swapAircraftSOI(otherSoi == 1?me.aircraftSOI:mySoi==1?(me.swapWith.aircraftSOI):nil);
	},
};


#  ███████ ██    ██ ███████ ████████ ███████ ███    ███ 
#  ██       ██  ██  ██         ██    ██      ████  ████ 
#  ███████   ████   ███████    ██    █████   ██ ████ ██ 
#       ██    ██         ██    ██    ██      ██  ██  ██ 
#  ███████    ██    ███████    ██    ███████ ██      ██ 
#                                                       
#                                                       

var DisplaySystem = {
	new: func () {
		var system = {parents : [DisplaySystem] };
		system.new = func {return nil;};
		return system;
	},

	del: func {
		
	},

	setDevice: func (device) {
		me.device = device;
	},

	initDevice: func (propertyNum, controlPositions, fontSize) {
		me.device.addControls(PUSHBUTTON,  "OSB", 1, 26, "controls/MFD["~propertyNum~"]/button-pressed", controlPositions);
		#me.device.addControls(ROCKERSWITCH,"GAIN", 0, 1, "f16/avionics/mfd-"~(propertyNum?"r":"l")~"-gain", controlPositions);
		me.device.fontSize = fontSize;

		for (var i = 1; i <= 6; i+= 1) {
			me.device.addControlText("OSB", "OSB"~i, [margin.device.buttonText, 0], i-1,-1);
		}
		for (var i = 7; i <= 12; i+= 1) {
			me.device.addControlText("OSB", "OSB"~i, [-margin.device.buttonText, 0], i-1,1);
		}
		for (var i = 13; i <= 19; i+= 1) {
			me.device.addControlText("OSB", "OSB"~i, [0, margin.device.buttonText], i-1,0,-1);
		}
		for (var i = 20; i <= 26; i+= 1) {
			me.device.addControlText("OSB", "OSB"~i, [0, -margin.device.buttonText], i-1,0,1);
		}
		me.device.addSOILines();
		me.device.addSOIText("NOT SOI");
		me.device.setSOI(-1);
	},

	getSOIPrio: func {
		return me.currPage.supportSOI?me.currPage.soiPrio:-1;
	},

	initPage: func (pageName) {
		if (DisplaySystem[pageName] == nil) {print(pageName," does not exist");return;}
		me.tempPageInstance = DisplaySystem[pageName].new();
		me.device.initPage(me.tempPageInstance);
		me.pages[me.tempPageInstance.name] = me.tempPageInstance;
	},

	initLayer: func (layerName) {
		me.tempLayerInstance = DisplaySystem[layerName].new();
		me.device.initLayer(me.tempLayerInstance);
		me.layers[me.tempLayerInstance.name] = me.tempLayerInstance;
	},

	initPages: func () {
		me.pages = {};
		me.layers = {};

		
		me.initPage("PageSADLBase");
		me.initPage("PageSADLCode");
		me.initPage("PageTac");

#		me.device.doubleTimerRunning = nil;
		me.device.controlAction = func (type, controlName, propvalue) {
			me.tempLink = me.system.currPage.links[controlName];
			me.system.currPage.controlAction(controlName);
			if (me.tempLink != nil) {
#				if (me.doubleTimerRunning == nil) {
#					settimer(func me.controlActionDouble(), 0.25);
#					me.doubleTimerRunning = me.tempLink;
#					printDebug("Timer starting: ",me.doubleTimerRunning);
#				} elsif (me.doubleTimerRunning == me.tempLink) {
#					me.doubleTimerRunning = nil;
#					me.system.osbSelect = [me.tempLink, me.system.currPage];
#					me.system.selectPage("PageOSB");
#					printDebug("Doubleclick special");
#				} else {
#					me.doubleTimerRunning = nil;
					me.system.selectPage(me.tempLink);
#					printDebug("Timer interupted. Going to ",me.tempLink);
#				}
			}
		};

#		me.device.controlActionDouble = func {
#			printDebug("Timer ran: ",me.doubleTimerRunning);
#			if (me.doubleTimerRunning != nil) {
#				me.system.selectPage(me.doubleTimerRunning);
#				me.doubleTimerRunning = nil;
#			}
#		};

		append(me.device.listeners, setlistener("/sim/bools/bit", func(node) {
            forcePages(node.getValue(), me);
        },0,0));
	},

	fetchLayer: func (layerName) {
		if (me.layers[layerName] == nil) {
			print("\n",me.device.name,": no such layer ",layerName);
			print("Available layers: ");
			foreach(var layer; keys(me.layers)) {
				print(layer);
			}
			print();
		}
		return me.layers[layerName];
	},

	supportSOI: func {
		return me.currPage.supportSOI;
	},

	update: func (noti) {
		me.currPage.update(noti);
		foreach(var layer; me.currPage.layers) {
			me.fetchLayer(layer).update(noti);
		}
	},

	selectPage: func (pageName) {
		if (me.pages[pageName] == nil) {print(me.device.name," page not found: ",pageName);return;}
		me.wasSOI = me.device.soi == 1;# The ==1 must be here since soi can be -1 in the device
		if (me["currPage"] != nil) {
			if(me.currPage.needGroup) me.currPage.group.hide();
			me.currPage.exit();
			foreach(var layer; me.currPage.layers) {
				me.fetchLayer(layer).group.hide();
			}
		}
		me.currPage = me.pages[pageName];
		if(me.currPage.needGroup) me.currPage.group.show();
		me.currPage.enter();
		#me.currPage.update(nil);
		foreach(var layer; me.currPage.layers) {
			me.fetchLayer(layer).group.show();
		}
	},

	PageOSB: {
		name: "PageOSB",
		isNew: 1,
		supportSOI: 0,
		needGroup: 1,
		new: func {
			me.instance = {parents:[DisplaySystem.PageOSB]};
			me.instance.group = nil;
			return me.instance;
		},
		setup: func {
			printDebug(me.name," on ",me.device.name," is being setup");
			me.pageText = me.group.createChild("text")
				.set("z-index", 10)
				.setColor(colorText1)
				.setAlignment("center-center")
				.setTranslation(displayWidthHalf, displayHeight*0.30)
				.setFontSize(me.device.fontSize)
				.setText("Select desired OSB");
		},
		enter: func {
			printDebug("Enter ",me.name~" on ",me.device.name);
			if (me.isNew) {
				me.setup();
				me.isNew = 0;
			}
			me.device.resetControls();
			me.device.controls["OSB10"].setControlText("FCR");
			me.device.controls["OSB11"].setControlText("WPN");
			me.device.controls["OSB12"].setControlText("SMS");
			me.device.controls["OSB13"].setControlText("HSD");
			me.device.controls["OSB14"].setControlText("DTE");
			me.device.controls["OSB15"].setControlText("HAS");
			me.device.controls["OSB16"].setControlText("FCR\nMODE");
			me.device.controls["OSB17"].setControlText("MENU");
			me.device.controls["OSB19"].setControlText("CANCEL");
		},
		controlAction: func (controlName) {
			printDebug(me.name,": ",controlName," activated on ",me.device.name);
			if (controlName == "OSB19") {
				me.device.system.selectPage(me.device.system.osbSelect[1].name);
			} elsif (controlName == "OSB10") {
                me.device.system.osbSelect[1].links[me.device.system.osbSelect[0]] = "PageFCR";
                me.device.system.selectPage(me.device.system.osbSelect[1].name);
            } elsif (controlName == "OSB11") {
                me.device.system.osbSelect[1].links[me.device.system.osbSelect[0]] = "PageSMSWPN";
                me.device.system.selectPage(me.device.system.osbSelect[1].name);
            } elsif (controlName == "OSB12") {
                me.device.system.osbSelect[1].links[me.device.system.osbSelect[0]] = "PageSMSINV";
                me.device.system.selectPage(me.device.system.osbSelect[1].name);
            } elsif (controlName == "OSB13") {
                me.device.system.osbSelect[1].links[me.device.system.osbSelect[0]] = "PageHSD";
                me.device.system.selectPage(me.device.system.osbSelect[1].name);
            } elsif (controlName == "OSB14") {
                me.device.system.osbSelect[1].links[me.device.system.osbSelect[0]] = "PageDTE";
                me.device.system.selectPage(me.device.system.osbSelect[1].name);
            } elsif (controlName == "OSB15") {
                me.device.system.osbSelect[1].links[me.device.system.osbSelect[0]] = "PageHAS";
                me.device.system.selectPage(me.device.system.osbSelect[1].name);
            } elsif (controlName == "OSB16") {
                me.device.system.osbSelect[1].links[me.device.system.osbSelect[0]] = "PageFCRMode";
                me.device.system.selectPage(me.device.system.osbSelect[1].name);
            } elsif (controlName == "OSB17") {
                me.device.system.osbSelect[1].links[me.device.system.osbSelect[0]] = "PageTMenu";
                me.device.system.selectPage(me.device.system.osbSelect[1].name);
            }
		},
		update: func (noti = nil) {			
		},
		exit: func {
			printDebug("Exit ",me.name~" on ",me.device.name);
		},
		links: {
		},
		layers: [],
	},

#  .d8888b.        d8888 8888888b.  888            .d8888b.   .d88888b.  8888888b.  8888888888 
# d88P  Y88b      d88888 888  "Y88b 888           d88P  Y88b d88P" "Y88b 888  "Y88b 888        
# Y88b.          d88P888 888    888 888           888    888 888     888 888    888 888        
#  "Y888b.      d88P 888 888    888 888           888        888     888 888    888 8888888    
#     "Y88b.   d88P  888 888    888 888           888        888     888 888    888 888        
#       "888  d88P   888 888    888 888           888    888 888     888 888    888 888        
# Y88b  d88P d8888888888 888  .d88P 888           Y88b  d88P Y88b. .d88P 888  .d88P 888        
#  "Y8888P" d88P     888 8888888P"  88888888       "Y8888P"   "Y88888P"  8888888P"  8888888888
                                
	PageSADLCode: {
		name: "PageSADLCode",
		isNew: 1,
		supportSOI: 0,
		needGroup: 1,
		new: func {
			me.instance = {parents:[DisplaySystem.PageSADLCode]};
			me.instance.group = nil;
			return me.instance;
		},
		setup: func {
			printDebug(me.name," on ",me.device.name," is being setup");
			me.pageText = me.group.createChild("text")
				.set("z-index", 10)
				.setColor(colorText1)
				.setAlignment("center-center")
				.setTranslation(displayWidthHalf, displayHeightHalf)
				.setFontSize(me.device.fontSize*3)
				.setText("UTC: 00:00:00");
			me.dateText = me.group.createChild("text")
				.set("z-index", 10)
				.setColor(colorText1)
				.setAlignment("center-center")
				.setTranslation(displayWidthHalf, displayHeightHalf-font.device.main*4)
				.setFontSize(me.device.fontSize*3)
				.setText("MMDDYYYY");
			me.sadlCode = me.group.createChild("text")
				.set("z-index", 10)
				.setColor(colorText1)
				.setAlignment("center-center")
				.setTranslation(displayWidthHalf, displayHeightHalf-font.device.main*8)
				.setFontSize(me.device.fontSize*3)
				.setText("SADL: INOP");
			me.scratchpad = me.group.createChild("text")
				.set("z-index", 10)
				.setColor(colorText1)
				.setAlignment("center-center")
				.setTranslation(displayWidthHalf, displayHeightHalf+font.device.main*4)
				.setFontSize(me.device.fontSize*3)
				.setText("HOLDING");

			me.pageText.enableUpdate();
			me.dateText.enableUpdate();
			me.sadlCode.enableUpdate();
			me.scratchpad.enableUpdate();
			me.scratchpad.hide();
		},
		enter: func {
			printDebug("Enter ",me.name~" on ",me.device.name);
			if (me.isNew) {
				me.setup();
				me.isNew = 0;
			}
			me.device.resetControls();
			me.device.controls["OSB16"].setControlText("SAVE");
			me.device.controls["OSB6"].setControlText("0");
			me.device.controls["OSB20"].setControlText("1");
			me.device.controls["OSB21"].setControlText("2");
			me.device.controls["OSB22"].setControlText("3");
			me.device.controls["OSB23"].setControlText("4");
			me.device.controls["OSB24"].setControlText("5");
			me.device.controls["OSB25"].setControlText("6");
			me.device.controls["OSB26"].setControlText("7");

		},
		keypadEntry: func(keyPressed){
			# Thanks naviat!
			setprop("A-10/displays/mpcd/holding", (getprop("A-10/displays/mpcd/holding") * 10) + keyPressed);
		},
		keypadSet: func {
			if (getprop("A-10/displays/mpcd/holding")>0){
				setprop("instrumentation/datalink/channel", getprop("A-10/displays/mpcd/holding"));
				setprop("A-10/displays/mpcd/holding", 0);
			}
		},
		controlAction: func (controlName) {
			printDebug(me.name,": ",controlName," activated on ",me.device.name);
			if (controlName == "OSB16") {
				me.keypadSet();
			} elsif (controlName == "OSB6") {
				me.keypadEntry(0);
			} elsif (controlName == "OSB20") {
				me.keypadEntry(1);
			} elsif (controlName == "OSB21") {
				me.keypadEntry(2);
			} elsif (controlName == "OSB22") {
				me.keypadEntry(3);
			} elsif (controlName == "OSB23") {
				me.keypadEntry(4);
			} elsif (controlName == "OSB24") {
				me.keypadEntry(5);
			} elsif (controlName == "OSB25") {
				me.keypadEntry(6);
			} elsif (controlName == "OSB26") {
				me.keypadEntry(7);
			}
		},
		update: func (noti = nil) {
			me.pageText.updateText(sprintf("UTC: %s", noti.getproper("utcTime")));
			me.dateText.updateText(sprintf("%02d%02d%02d", noti.getproper("utcMonth"), noti.getproper("utcDay"), noti.getproper("utcYear")));	
			me.sadlCode.updateText(sprintf("SADL: %i", noti.getproper("sadlCode")));
			if (noti.getproper("scratchpadHolding") > 0) {
				me.scratchpad.show();
				me.scratchpad.updateText(sprintf("NEW: %i", noti.getproper("scratchpadHolding")));
			} else {me.scratchpad.hide();}
		},
		exit: func {
			printDebug("Exit ",me.name~" on ",me.device.name);
		},
		links: {
			"OSB16": "PageSADLBase",
			"OSB18": "PageTMenu",
		},
		layers: [],
	},  

                                                                        
#  .d8888b.        d8888 8888888b.  888           888888b.         d8888  .d8888b.  8888888888 
# d88P  Y88b      d88888 888  "Y88b 888           888  "88b       d88888 d88P  Y88b 888        
# Y88b.          d88P888 888    888 888           888  .88P      d88P888 Y88b.      888        
#  "Y888b.      d88P 888 888    888 888           8888888K.     d88P 888  "Y888b.   8888888    
#     "Y88b.   d88P  888 888    888 888           888  "Y88b   d88P  888     "Y88b. 888        
#       "888  d88P   888 888    888 888           888    888  d88P   888       "888 888        
# Y88b  d88P d8888888888 888  .d88P 888           888   d88P d8888888888 Y88b  d88P 888        
#  "Y8888P" d88P     888 8888888P"  88888888      8888888P" d88P     888  "Y8888P"  8888888888


	PageSADLBase: {
		name: "PageSADLBase",
		isNew: 1,
		supportSOI: 0,
		needGroup: 1,
		new: func {
			me.instance = {parents:[DisplaySystem.PageSADLBase]};
			me.instance.group = nil;
			return me.instance;
		},
		setup: func {
			printDebug(me.name," on ",me.device.name," is being setup");
			me.pageText = me.group.createChild("text")
				.set("z-index", 10)
				.setColor(colorText1)
				.setAlignment("center-center")
				.setTranslation(displayWidthHalf, displayHeightHalf)
				.setFontSize(me.device.fontSize*3)
				.setText("UTC: 00:00:00");
			me.dateText = me.group.createChild("text")
				.set("z-index", 10)
				.setColor(colorText1)
				.setAlignment("center-center")
				.setTranslation(displayWidthHalf, displayHeightHalf-font.device.main*4)
				.setFontSize(me.device.fontSize*3)
				.setText("01022025");
			me.sadlCode = me.group.createChild("text")
				.set("z-index", 10)
				.setColor(colorText1)
				.setAlignment("center-center")
				.setTranslation(displayWidthHalf, displayHeightHalf-font.device.main*8)
				.setFontSize(me.device.fontSize*3)
				.setText("SADL: 4096");

			me.pageText.enableUpdate();
			me.dateText.enableUpdate();
			me.sadlCode.enableUpdate();
		},
		enter: func {
			printDebug("Enter ",me.name~" on ",me.device.name);
			if (me.isNew) {
				me.setup();
				me.isNew = 0;
			}
			me.device.resetControls();
			# me.device.controls["OSB1"].setControlText("OSB1");
			# me.device.controls["OSB2"].setControlText("OSB2");
			# me.device.controls["OSB3"].setControlText("OSB3");
			# me.device.controls["OSB4"].setControlText("OSB4");
			# me.device.controls["OSB5"].setControlText("OSB5");
			# me.device.controls["OSB6"].setControlText("OSB6");
			# me.device.controls["OSB7"].setControlText("OSB7");
			# me.device.controls["OSB8"].setControlText("OSB8");
			# me.device.controls["OSB9"].setControlText("OSB9");
			# me.device.controls["OSB10"].setControlText("OSB10");
			# me.device.controls["OSB11"].setControlText("OSB11");
			# me.device.controls["OSB12"].setControlText("OSB12");
			# me.device.controls["OSB13"].setControlText("OSB13");
			# me.device.controls["OSB14"].setControlText("OSB14");
			# me.device.controls["OSB15"].setControlText("OSB15");
			# me.device.controls["OSB16"].setControlText("OSB16");
			# me.device.controls["OSB17"].setControlText("OSB17");
			# me.device.controls["OSB18"].setControlText("OSB18");
			# me.device.controls["OSB19"].setControlText("OSB19");
			# me.device.controls["OSB20"].setControlText("OSB20");
			# me.device.controls["OSB21"].setControlText("OSB21");
			# me.device.controls["OSB22"].setControlText("OSB22");
			# me.device.controls["OSB23"].setControlText("OSB23");
			# me.device.controls["OSB24"].setControlText("OSB24");
			# me.device.controls["OSB25"].setControlText("OSB25");
			# me.device.controls["OSB26"].setControlText("OSB26");
			me.device.controls["OSB16"].setControlText("SET");
			me.device.controls["OSB20"].setControlText("SADL");
			me.device.controls["OSB21"].setControlText("TAC");
		},
		controlAction: func (controlName) {
			printDebug(me.name,": ",controlName," activated on ",me.device.name);
		},
		update: func (noti = nil) {
			me.pageText.updateText(sprintf("UTC: %s", noti.getproper("utcTime")));
			me.dateText.updateText(sprintf("%02d%02d%02d", noti.getproper("utcMonth"), noti.getproper("utcDay"), noti.getproper("utcYear")));	
			me.sadlCode.updateText(sprintf("SADL: %i", noti.getproper("sadlCode")));	
		},
		exit: func {
			printDebug("Exit ",me.name~" on ",me.device.name);
		},
		links: {
			"OSB16": "PageSADLCode",
			"OSB20": "PageSADLBase",
			"OSB21": "PageTac",
		},
		layers: [],
	},


# 88888888888     d8888 8888888b.  
#     888        d88888 888  "Y88b 
#     888       d88P888 888    888 
#     888      d88P 888 888    888 
#     888     d88P  888 888    888 
#     888    d88P   888 888    888 
#     888   d8888888888 888  .d88P 
#     888  d88P     888 8888888P"


	PageTac: {
		name: "PageTac",
		isNew: 1,
		supportSOI: 0,
		needGroup: 1,
		new: func {
			me.instance = {parents:[DisplaySystem.PageTac]};
			me.instance.group = nil;
			return me.instance;
			#me.group
		},
		setup: func {
			printDebug(me.name," on ",me.device.name," is being setup");
			# me.setupSymbols();

	        me.setupVariables();
	        me.calcGeometry();
	        me.calcZoomLevels();
	        me.initMap();
	        me.setupProperties();# before setup map
	        me.setupMap();
	        me.setupGrid();# after setupgrid
	        me.setupLines();
	        me.setupSymbols();
	        me.setupTargets();
	        me.setupAttr();	        
	        me.loadedCDU = 1;
	        me.loopTimer = maketimer(0.25, me, me.loop);
        	me.loopTimer.start();
        	startDLListener();
        	me.setRangeInfo();
        	me.tadInit = 1;
		},
		loop: func {
			me.whereIsMap();
			me.updateMap();
			me.updateGrid();
			me.updateSymbols();
			me.updateRoute();
			me.updateTargets();
			me.updateAttr();
		},
	    setupVariables: func {
	        me.mapShowPlaces = 1;
	        me.mapSelfCentered = 1;
	        me.day = 1;
	        me.mapShowGrid = 0;
	        me.mapShowAFB = 0;
	    },
		setupProperties: func {
	        me.input = {
	            alt_ft:               "instrumentation/altimeter/indicated-altitude-ft",
	            alt_true_ft:          "position/altitude-ft",
	            heading:              "orientation/heading-deg",
	            radarStandby:         "instrumentation/radar/radar-standby",
	            rad_alt:              "instrumentation/radar-altimeter/radar-altitude-ft",
	            rad_alt_ready:        "instrumentation/radar-altimeter/ready",
	            rmActive:             "autopilot/route-manager/active",
	            rmDist:               "autopilot/route-manager/wp/dist",
	            rmId:                 "autopilot/route-manager/wp/id",
	            rmBearing:            "autopilot/route-manager/wp/true-bearing-deg",
	            RMCurrWaypoint:       "autopilot/route-manager/current-wp",
	            roll:                 "instrumentation/attitude-indicator/indicated-roll-deg",
	            timeElapsed:          "sim/time/elapsed-sec",
	            headTrue:             "orientation/heading-deg",
	            fpv_up:               "instrumentation/fpv/angle-up-deg",
	            fpv_right:            "instrumentation/fpv/angle-right-deg",
	            roll:                 "orientation/roll-deg",
	            pitch:                "orientation/pitch-deg",
	            radar_serv:           "instrumentation/radar/serviceable",
	            nav0InRange:          "instrumentation/nav[0]/in-range",
	            APLockHeading:        "autopilot/locks/heading",
	            APTrueHeadingErr:     "autopilot/internal/true-heading-error-deg",
	            APnav0HeadingErr:     "autopilot/internal/nav1-heading-error-deg",
	            APHeadingBug:         "autopilot/settings/heading-bug-deg",
	            RMActive:             "autopilot/route-manager/active",
	            nav0Heading:          "instrumentation/nav[0]/heading-deg",
	            ias:                  "instrumentation/airspeed-indicator/indicated-speed-kt",
	            tas:                  "instrumentation/airspeed-indicator/true-speed-kt",
	            latitude:             "position/latitude-deg",
	            longitude:            "position/longitude-deg",
	            datalink:             "/instrumentation/datalink/on",
	            crashSec:             "instrumentation/radar/time-till-crash",
	            servAtt                   : "instrumentation/attitude-indicator/serviceable",
	            servHead                  : "instrumentation/heading-indicator/serviceable",
	            servTurn                  : "instrumentation/turn-indicator/serviceable",
	            routeActive:		 "autopilot/route-manager/active",
	        };

	        foreach(var name; keys(me.input)) {
	            me.input[name] = props.globals.getNode(me.input[name], 1);
	        }
	    },
	    calcGeometry: func {
        me.max_x = displayWidth;
        me.max_y = displayHeight;
        me.ehsiScale = 1;
        me.ehsiCanvas = 0;
        me.ehsiPosX = 0;
        me.ehsiPosY = 512+512/2;
        me.defaultOwnPosition = 0.65 * me.ehsiPosY;
        me.ownPosition = me.defaultOwnPosition;
   		},
	    calcZoomLevels: func {
	        me.M2TEXinit = 1/(meterPerPixel[zooms[zoom_init]]*math.cos(getprop('/position/latitude-deg')*D2R));
	        if (zoomLevels[zoom_init]*NM2M*me.M2TEXinit > me.defaultOwnPosition * 2) {
	            #print("Reduce zoom x4");
	            forindex (var zoomLvl ; zoomLevels) {
	                zooms[zoomLvl] = zooms[zoomLvl]-2;
	            }
	        } elsif (zoomLevels[zoom_init]*NM2M*me.M2TEXinit > me.defaultOwnPosition) {
	            #print("Reduce zoom x2");
	            forindex (var zoomLvl ; zoomLevels) {
	                zooms[zoomLvl] = zooms[zoomLvl]-1;
	            }
	        } elsif (zoomLevels[zoom_init]*NM2M*me.M2TEXinit < me.defaultOwnPosition * 0.5) {
	            #print("Increase zoom x2");
	            forindex (var zoomLvl ; zoomLevels) {
	                zooms[zoomLvl] = zooms[zoomLvl]+1;
	            }
	        } elsif (zoomLevels[zoom_init]*NM2M*me.M2TEXinit < me.defaultOwnPosition * 0.25) {
	            #print("Increase zoom x4");
	            forindex (var zoomLvl ; zoomLevels) {
	                zooms[zoomLvl] = zooms[zoomLvl]+2;
	            }
	        }
	        me.M2TEXinit = 1/(meterPerPixel[zooms[zoom_init]]*math.cos(getprop('/position/latitude-deg')*D2R));
	    },
	    toggleDay: func {
        	me.day = !me.day;
        	me.device.controls["OSB3"].setControlText(me.day?"DIM":"LIGHT");
    	},
	    toggleGrid: func {
	        me.mapShowGrid = !me.mapShowGrid;
	        me.device.controls["OSB8"].setControlText(me.mapShowGrid?"GRID\nOFF":"GRID\nON ");
	    },

	    toggleAFB: func {
	        me.mapShowAFB = !me.mapShowAFB;
	    },

	    toggleHdgUp: func {
	        me.hdgUp = !me.hdgUp;
	        me.device.controls["OSB16"].setControlText(me.hdgUp?"MAP\nUP":"HDG\nUP");
	    },
	    setupLines: func {
	        # Used by lines and route
	        me.linesGroup = me.mapCenter.createChild("group").set("z-index",zIndex.tad.lines);
	    },
#                          888            
#                          888            
#                          888            
# 888d888 .d88b.  888  888 888888 .d88b.  
# 888P"  d88""88b 888  888 888   d8P  Y8b 
# 888    888  888 888  888 888   88888888 
# 888    Y88..88P Y88b 888 Y88b. Y8b.     
# 888     "Y88P"   "Y88888  "Y888 "Y8888
	    updateRoute: func {
	    	me.linesGroup.removeAllChildren();
	        if (me.input.routeActive.getValue()) {
	            me.plan = flightplan();
	            me.planSize = me.plan.getPlanSize();
	            me.stptPrevPos = nil;
	            for (me.j = 0; me.j < me.planSize;me.j+=1) {
	                me.wp = me.plan.getWP(me.j);
	                me.stptPos = me.laloToTexelMap(me.wp.lat,me.wp.lon);
	                me.wp = me.linesGroup.createChild("path")
	                    .moveTo(me.stptPos[0]-8,me.stptPos[1])
	                    .arcSmallCW(8,8, 0, 8*2, 0)
	                    .arcSmallCW(8,8, 0,-8*2, 0)
	                    .setStrokeLineWidth(lineWidth.tad.route)
	                    .set("z-index",6)
	                    .setColor(colorText1)
	                    .update();
	                if (me.plan.current == me.j) {
	                    me.wp.setColorFill(colorText1);
	                }
	                if (me.stptPrevPos != nil) {
	                    me.linesGroup.createChild("path")
	                        .moveTo(me.stptPos)
	                        .lineTo(me.stptPrevPos)
	                        .setStrokeLineWidth(lineWidth.tad.route)
	                        .set("z-index",6)
	                        .setColor(colorText1)
	                        .update();
	                }
	                me.stptPrevPos = me.stptPos;
	            }
	        }
	    },
#                                 888               888          
#                                 888               888          
#                                 888               888          
# .d8888b  888  888 88888b.d88b.  88888b.   .d88b.  888 .d8888b  
# 88K      888  888 888 "888 "88b 888 "88b d88""88b 888 88K      
# "Y8888b. 888  888 888  888  888 888  888 888  888 888 "Y8888b. 
#      X88 Y88b 888 888  888  888 888 d88P Y88..88P 888      X88 
#  88888P'  "Y88888 888  888  888 88888P"   "Y88P"  888  88888P' 
#               888                                              
#          Y8b d88P                                              
#           "Y88P"
	    setupSymbols: func {
	        # ownship symbol
	        canvas.parsesvg(me.rootCenter, "Aircraft/A-10/Nasal/a10.svg");
	        me.selfSymbol = me.rootCenter.getElementById("aircraftIcon")
	        		.setColor(colorText1)
	                .set("z-index", zIndex.tad.ownship)
	                .setStrokeLineWidth(0.8)
	                .setScale(4);

	        me.outerRadius  = zoomLevels[zoom_curr]*NM2M*M2TEX;
	        #me.mediumRadius = me.outerRadius*0.6666;
	        me.innerRadius  = me.outerRadius*0.5;
	        #var innerTick    = 0.85*innerRadius*math.cos(45*D2R);
	        #var outerTick    = 1.15*innerRadius*math.cos(45*D2R);

	        me.conc = me.rootCenter.createChild("path")
	            .moveTo(me.innerRadius,0)
	            .arcSmallCW(me.innerRadius,me.innerRadius, 0, -me.innerRadius*2, 0)
	            .arcSmallCW(me.innerRadius,me.innerRadius, 0,  me.innerRadius*2, 0)
	            .moveTo(me.outerRadius,0)
	            .arcSmallCW(me.outerRadius,me.outerRadius, 0, -me.outerRadius*2, 0)
	            .arcSmallCW(me.outerRadius,me.outerRadius, 0,  me.outerRadius*2, 0)
	            .moveTo(0,-me.innerRadius)#north
	            .vert(-15)
	            .lineTo(3,-me.innerRadius-15+2)
	            .lineTo(0,-me.innerRadius-15+4)
	            .moveTo(0,me.innerRadius-15)#south
	            .vert(30)
	            .moveTo(-me.innerRadius,0)#west
	            .horiz(-15)
	            .moveTo(me.innerRadius,0)#east
	            .horiz(15)
	            .setStrokeLineWidth(lineWidth.tad.rangeRings)
	            .set("z-index",zIndex.tad.rangeRings)
	            .setColor(colorLine5);

	        # me.bullseye = me.sadlFeatures.createChild("path")
	        #     .moveTo(-symbolSize.bullseye,0)
	        #     .arcSmallCW(symbolSize.bullseye,symbolSize.bullseye, 0,  symbolSize.bullseye*2, 0)
	        #     .arcSmallCW(symbolSize.bullseye,symbolSize.bullseye, 0, -symbolSize.bullseye*2, 0)
	        #     .moveTo(-symbolSize.bullseye*3/5,0)
	        #     .arcSmallCW(symbolSize.bullseye*3/5,symbolSize.bullseye*3/5, 0,  symbolSize.bullseye*3/5*2, 0)
	        #     .arcSmallCW(symbolSize.bullseye*3/5,symbolSize.bullseye*3/5, 0, -symbolSize.bullseye*3/5*2, 0)
	        #     .moveTo(-symbolSize.bullseye/5,0)
	        #     .arcSmallCW(symbolSize.bullseye/5,symbolSize.bullseye/5, 0,  symbolSize.bullseye/5*2, 0)
	        #     .arcSmallCW(symbolSize.bullseye/5,symbolSize.bullseye/5, 0, -symbolSize.bullseye/5*2, 0)
	        #     .setStrokeLineWidth(lineWidth.bullseye)
	        #     .set("z-index",layer_z.map.bullseye)
	        #     .setColor(COLOR_BLUE_LIGHT);

	        # me.gpsSpot = me.sadlFeatures.createChild("path")
	        #     .moveTo(-symbolSize.gpsSpot,0)
	        #     .arcSmallCW(symbolSize.gpsSpot,symbolSize.gpsSpot, 0,  symbolSize.gpsSpot*2, 0)
	        #     .arcSmallCW(symbolSize.gpsSpot,symbolSize.gpsSpot, 0, -symbolSize.gpsSpot*2, 0)
	        #     .moveTo(-symbolSize.gpsSpot*3/5,0)
	        #     .arcSmallCW(symbolSize.gpsSpot*3/5,symbolSize.gpsSpot*3/5, 0,  symbolSize.gpsSpot*3/5*2, 0)
	        #     .arcSmallCW(symbolSize.gpsSpot*3/5,symbolSize.gpsSpot*3/5, 0, -symbolSize.gpsSpot*3/5*2, 0)
	        #     .setStrokeLineWidth(lineWidth.gpsSpot)
	        #     .set("z-index",layer_z.map.gpsSpot)
	        #     .setColor(COLOR_BLACK);
	    },
	    updateSymbols: func {
	        # me.bullPt = steerpoints.getNumber(steerpoints.index_of_bullseye);
	        # me.bullOn = me.bullPt != nil and steerpoints.bullseyeMode;
	        # if (me.bullOn) {
	        #     me.bullLat = me.bullPt.lat;
	        #     me.bullLon = me.bullPt.lon;
	        #     me.bullseye.setTranslation(me.laloToTexelMap(me.bullLat,me.bullLon));            
	        # }
	        # me.bullseye.setVisible(me.bullOn);

	        # me.gpsPt = steerpoints.getNumber(steerpoints.index_of_weapon_gps);
	        # me.bullOn = me.gpsPt != nil;
	        # if (me.bullOn) {
	        #     me.gpsLat = me.gpsPt.lat;
	        #     me.gpsLon = me.gpsPt.lon;
	        #     me.gpsSpot.setTranslation(me.laloToTexelMap(me.gpsLat,me.gpsLon));            
	        # }
	        # me.gpsSpot.setVisible(me.bullOn);

	        me.concScale = zoomLevels[zoom_init]*NM2M*me.M2TEXinit/me.outerRadius;
	        me.conc.setScale(me.concScale);
	        me.conc.setStrokeLineWidth(lineWidth.tad.rangeRings/me.concScale);
	        me.conc.setVisible(zoom_curr != size(zoomLevels)-1);
	        me.conc.setColor(me.day?colorText1:colorText1);
	        if (me.input.servHead.getValue()) me.conc.setRotation(-me.input.heading.getValue()*D2R);

	        if(me.hdgUp) {
	            # me.hdgUpText.setText(me.input.servHead.getValue()?"HDG UP":"FAIL");
	            me.rootCenter.setRotation(0);
	        } else {
	            # me.hdgUpText.setText(me.input.servHead.getValue()?"MAP UP":"FAIL");
	            if (me.input.servHead.getValue()) me.rootCenter.setRotation(me.input.heading.getValue()*D2R);
	        }
	        # me.dayText.setText(me.day?"DAY":"NIGHT");
	        # me.instrText.setText(me.instrConf[me.instrView].descr);
	        # me.mapText.setText(providerOptionTags[providerOption]);
	        # me.gridText.setText(me.mapShowGrid?"GRID":"CLEAN");
	        # me.afbText.setText(me.mapShowAFB?"AFB  ON":"AFB OFF");
	        # me.afbText.setVisible(me.instrConf[me.instrView].showMap);
	        # me.afbTextBK.setVisible(me.instrConf[me.instrView].showMap);
	        # me.gridTextBK.setVisible(me.instrConf[me.instrView].showMap);
	        # me.mapTextBK.setVisible(me.instrConf[me.instrView].showMap);
	        # me.hdgUpTextBK.setVisible(me.instrConf[me.instrView].showMap);
	        # me.dayTextBK.setVisible(me.instrConf[me.instrView].showMap);
	        # me.rangeTextBK.setVisible(me.instrConf[me.instrView].showMap);
	        # me.instrTextBK.setVisible(1);
	        # me.gridText.setVisible(me.instrConf[me.instrView].showMap);
	        # me.mapText.setVisible(me.instrConf[me.instrView].showMap);
	        # me.dayText.setVisible(me.instrConf[me.instrView].showMap);
	        # me.hdgUpText.setVisible(me.instrConf[me.instrView].showMap);
	        # me.rangeText.setVisible(me.instrConf[me.instrView].showMap);
	    },

# 8888888b.  888      d8b          888      
# 888  "Y88b 888      Y8P          888      
# 888    888 888                   888      
# 888    888 888      888 88888b.  888  888 
# 888    888 888      888 888 "88b 888 .88P 
# 888    888 888      888 888  888 888888K  
# 888  .d88P 888      888 888  888 888 "88b 
# 8888888P"  88888888 888 888  888 888  888

	    setupTargets: func {
	        me.maxB = 12;
	        me.blepTriangle = setsize([],me.maxB);
	        me.blepTriangleVel = setsize([],me.maxB);
	        me.blepTriangleText = setsize([],me.maxB);
	        me.blepTriangleVelLine = setsize([],me.maxB);
	        me.blepTrianglePaths = setsize([],me.maxB);
	        me.lnkTA= setsize([],me.maxB);
	        me.lnkT = setsize([],me.maxB);
	        me.lnk  = setsize([],me.maxB);
	        for (var i = 0;i<me.maxB;i+=1) {
	                me.blepTriangle[i] = me.mapCenter.createChild("group")
	                                .set("z-index",zIndex.tad.contacts);
	                me.blepTriangleVel[i] = me.blepTriangle[i].createChild("group");
	                me.blepTriangleText[i] = me.blepTriangle[i].createChild("text")
	                                .setAlignment("center-top")
	                                .setFontSize(font.tad.contacts, 1.0)
	                                .setTranslation(0,symbolSize.tad.contacts/5.5);
	                me.blepTriangleVelLine[i] = me.blepTriangleVel[i].createChild("path")
	                                .lineTo(0,-10)
	                                .setTranslation(0,-symbolSize.tad.contacts/7)
	                                .setStrokeLineWidth(lineWidth.tad.targets);
	                me.blepTrianglePaths[i] = me.blepTriangle[i].createChild("path")
	                                .moveTo(-symbolSize.tad.contacts/8,symbolSize.tad.contacts/14)
	                                .horiz(symbolSize.tad.contacts/4)
	                                .lineTo(0,-symbolSize.tad.contacts/7)
	                                .lineTo(-symbolSize.tad.contacts/8,symbolSize.tad.contacts/14)
	                                .set("z-index",10)
	                                .setStrokeLineWidth(lineWidth.tad.targets);
	                me.lnk[i] = me.mapCenter.createChild("path")
	                                .moveTo(-symbolSize.tad.contacts/10,-symbolSize.tad.contacts/10)
	                                .vert(symbolSize.tad.contacts/5)
	                                .horiz(symbolSize.tad.contacts/5)
	                                .vert(-symbolSize.tad.contacts/5)
	                                .horiz(-symbolSize.tad.contacts/5)
	                                .moveTo(0,-symbolSize.tad.contacts/10)
	                                .vert(-symbolSize.tad.contacts/10)
	                                .hide()
	                                .set("z-index",zIndex.tad.contacts)
	                                .setStrokeLineWidth(lineWidth.tad.targetsDL);
	                me.lnkT[i] = me.mapCenter.createChild("text")
	                                .setAlignment("center-bottom")
	                                .set("z-index",zIndex.tad.contacts)
	                                .setFontSize(font.tad.contacts, 1.0);
	                me.lnkTA[i] = me.mapCenter.createChild("text")
	                                .setAlignment("center-top")
	                                .set("z-index",zIndex.tad.contacts)
	                                .setFontSize(font.tad.contacts, 1.0);
	        }
	        # me.selection = me.mapCenter.createChild("path")
	        #         .moveTo(-symbolSize.tad.contacts/7, 0)
	        #         .arcSmallCW(symbolSize.tad.contacts/7, symbolSize.tad.contacts/7, 0, (symbolSize.tad.contacts/7)*2, 0)
	        #         .arcSmallCW(symbolSize.tad.contacts/7, symbolSize.tad.contacts/7, 0, -(symbolSize.tad.contacts/7)*2, 0)
	        #         .setColor(COLOR_YELLOW)
	        #         .set("z-index",zIndex.tad.contacts)
	        #         .setStrokeLineWidth(2);
	    },

	    updateTargets: func {
	        me.i = 0;#triangles
	        me.ii = 0;#dlink
	        me.selected = 0;

	        me.rando = rand();
	        # me.rdrprio = radar_system.apg68Radar.getPriorityTarget();
	        me.selfHeading = radar_system.self.getHeading();

	        if (1) {
	            # printf("%d DLs",size(vector_aicontacts_links));
	            foreach(contact; vector_aicontacts_links) {
	                me.blue = contact.blue;
	                # print("a");
	                me.blueIndex = contact.blueIndex;
	                me.paintBlep(contact);
	                contact.rando = me.rando;
	            }
	        }

	        for (;me.i<me.maxB;me.i+=1) {
	            me.blepTriangle[me.i].hide();
	        }
	        for (;me.ii<me.maxB;me.ii+=1) {
	            me.lnk[me.ii].hide();
	            me.lnkT[me.ii].hide();
	            me.lnkTA[me.ii].hide();
	        }
	        # me.selection.setVisible(me.selected);
	    },

	    paintBlep: func (contact) {
	        me.color = me.blue == 1?colorText1:(me.blue == 2?COLOR_RED:COLOR_YELLOW);
	        if (me.blue != 0) {
	            me.c_rng = contact.getRange()*M2NM;
	            me.c_rbe = contact.getDeviationHeading();
	            me.c_hea = contact.getHeading();
	            me.c_alt = contact.get_altitude();
	            me.c_spd = contact.getSpeed();
	        }


	        me.rot = 22.5*math.round( geo.normdeg((me.c_hea))/22.5 )*D2R;#Show rotation in increments of 22.5 deg
	        #me.trans = [me.distPixels*math.sin(me.c_rbe*D2R),-me.distPixels*math.cos(me.c_rbe*D2R)];
	        me.transCoord = contact.getCoord();
	        me.trans = me.laloToTexelMap(me.transCoord.lat(),me.transCoord.lon());

	        if (me.blue != 1 and me.i < me.maxB) {
	            me.blepTrianglePaths[me.i].setColor(me.color);
	            me.blepTriangle[me.i].setTranslation(me.trans);
	            me.blepTriangle[me.i].show();
	            me.blepTrianglePaths[me.i].setRotation(me.rot);
	            me.blepTriangleVel[me.i].setRotation(me.rot);
	            me.blepTriangleVelLine[me.i].setScale(1,me.c_spd*0.0045);
	            me.blepTriangleVelLine[me.i].setColor(me.color);
	            me.lockAlt = sprintf("%02d", math.round(me.c_alt*0.001));
	            me.blepTriangleText[me.i].setText(me.lockAlt);
	            me.blepTriangleText[me.i].setColor(me.color);
	            me.i += 1;
	            if (me.blue == 2 and me.ii < me.maxB) {
	                me.lnkT[me.ii].setColor(me.color);
	                me.lnkT[me.ii].setTranslation(me.trans[0],me.trans[1]-symbolSize.tad.contacts/4.5);
	                me.lnkT[me.ii].setText(""~me.blueIndex);
	                me.lnk[me.ii].hide();
	                me.lnkT[me.ii].show();
	                me.lnkTA[me.ii].hide();
	                me.ii += 1;
	            }
	        } elsif (me.blue == 1 and me.ii < me.maxB) {
	            me.lnk[me.ii].setColor(me.color);
	            me.lnk[me.ii].setTranslation(me.trans);
	            me.lnk[me.ii].setRotation(me.rot);
	            #me.lnkT[me.ii].setRotation(me.selfHeading*D2R);
	            #me.lnkTA[me.ii].setRotation(me.selfHeading*D2R);
	            me.lnkT[me.ii].setColor(me.color);
	            me.lnkTA[me.ii].setColor(me.color);
	            me.lnkT[me.ii].setTranslation(me.trans[0],me.trans[1]-symbolSize.tad.contacts/4.5);
	            me.lnkTA[me.ii].setTranslation(me.trans[0],me.trans[1]+symbolSize.tad.contacts/5.5);
	            me.lnkT[me.ii].setText(""~me.blueIndex);
	            me.lnkTA[me.ii].setText(sprintf("%02d", math.round(me.c_alt*0.001)));
	            me.lnk[me.ii].show();
	            me.lnkTA[me.ii].show();
	            me.lnkT[me.ii].show();
	            me.ii += 1;
	        }
	    },
	    setupAttr: func {
	        me.attrText = me.group.createChild("text")
	            .set("z-index",zIndex.tad.attribution)
	            .setColor(COLOR_WHITE)
	            .setFontSize(font.device.main, 1.0)
	            .setText("")
	            .setAlignment("center-center")
	            .setTranslation(me.max_x*0.5,me.max_y*0.5)
	            .setFont("NotoMono-Regular.ttf");
	    },

	    updateAttr: func {
	        # every once in a while display attribution for 4 seconds.
	        me.attrText.setText(providers[zoom_provider[zoom_curr]].attribution);
	        me.attrText.setVisible(math.mod(int(me.input.timeElapsed.getValue()*0.25), 120) == 0)
	    },
		zoomIn: func() {
	        zoom_curr += 1;
	        if (zoom_curr >= size(zooms)) {
	            zoom_curr = size(zooms) - 1;
	        }
	        me.changeProvider();
	    },

	    zoomOut: func() {
	        zoom_curr -= 1;
	        if (zoom_curr < 0) {
	            zoom_curr = 0;
	        }
	        me.changeProvider();
	    },

	    checkZoom: func {
	        if(providers[providerOptions[providerOption][zoom_curr]]["max"] != nil) {
	            while(zooms[zoom_curr] > providers[providerOptions[providerOption][zoom_curr]]["max"]) {
	                zoom_curr -= 1;
	            }
	        }
	        if(providers[providerOptions[providerOption][zoom_curr]]["min"] != nil) {
	            while(zooms[zoom_curr] < providers[providerOptions[providerOption][zoom_curr]]["min"]) {
	                zoom_curr += 1;
	            }
	        }
	        zoom = zooms[zoom_curr];
	        M2TEX = 1/(meterPerPixel[zoom]*math.cos(getprop('/position/latitude-deg')*D2R));
	        me.setRangeInfo();
	    },

	    toggleMap: func {
	        providerOption += 1;
	        # print(providerOption);
	        if (providerOption > size(providerOptions)-1) providerOption = 0;
	        zoom_provider = providerOptions[providerOption];
	        me.changeProvider();
	        me.device.controls["OSB4"].setControlText(providerOptionTags[providerOption]);
	    },

	    changeProvider: func {
	        me.checkZoom();
	        makeUrl   = string.compileTemplate(providers[zoom_provider[zoom_curr]].templateLoad);
	        makePath  = string.compileTemplate(maps_base ~ providers[zoom_provider[zoom_curr]].templateStore);
	    },

	    setRangeInfo: func  {
	        me.range = zoomLevels[zoom_curr];#(me.outerRadius/M2TEX)*M2NM;
	        #me.rangeText.setText(sprintf("%d", me.range));#print(sprintf("Map range %5.1f NM", me.range));
	        me.device.controls["OSB7"].setControlText(sprintf("%d", me.range));
	        # me.rangeArrowDown.setVisible(me.instrConf[me.instrView].showMap and zoom_curr < size(zoomLevels)-1);
	        # me.rangeArrowUp.setVisible(me.instrConf[me.instrView].showMap and zoom_curr > 0);
	    },

	    laloToTexel: func (la, lo) {
	        me.coord = geo.Coord.new();
	        me.coord.set_latlon(la, lo);
	        me.coordSelf = geo.Coord.new();#TODO: dont create this every time method is called
	        me.coordSelf.set_latlon(me.lat_own, me.lon_own);
	        me.angle = (me.coordSelf.course_to(me.coord)-me.input.heading.getValue())*D2R;
	        me.pos_xx        = -me.coordSelf.distance_to(me.coord)*M2TEX * math.cos(me.angle + math.pi/2);
	        me.pos_yy        = -me.coordSelf.distance_to(me.coord)*M2TEX * math.sin(me.angle + math.pi/2);
	        return [me.pos_xx, me.pos_yy];#relative to rootCenter
	    },
	    
	    laloToTexelMap: func (la, lo) {
	        me.coord = geo.Coord.new();
	        me.coord.set_latlon(la, lo);
	        me.coordSelf = geo.Coord.new();#TODO: dont create this every time method is called
	        me.coordSelf.set_latlon(me.lat, me.lon);
	        me.angle = (me.coordSelf.course_to(me.coord))*D2R;
	        me.pos_xx        = -me.coordSelf.distance_to(me.coord)*M2TEX * math.cos(me.angle + math.pi/2);
	        me.pos_yy        = -me.coordSelf.distance_to(me.coord)*M2TEX * math.sin(me.angle + math.pi/2);
	        return [me.pos_xx, me.pos_yy];#relative to mapCenter
	    },

	    TexelToLaLoMap: func (x,y) {#relative to map center
	        x /= M2TEX;
	        y /= M2TEX;
	        me.mDist  = math.sqrt(x*x+y*y);
	        if (me.mDist == 0) {
	            return [me.lat, me.lon];
	        }
	        me.acosInput = clamp(x/me.mDist,-1,1);
	        if (y<0) {
	            me.texAngle = math.acos(me.acosInput);#unit circle on TI
	        } else {
	            me.texAngle = -math.acos(me.acosInput);
	        }
	        #printf("%d degs %0.1f NM", me.texAngle*R2D, me.mDist*M2NM);
	        me.texAngle  = -me.texAngle*R2D+90;#convert from unit circle to heading circle, 0=up on display
	        me.headAngle = me.input.heading.getValue()+me.texAngle;#bearing
	        #printf("%d bearing   %d rel bearing", me.headAngle, me.texAngle);
	        me.coordSelf = geo.Coord.new();#TODO: dont create this every time method is called
	        me.coordSelf.set_latlon(me.lat, me.lon);
	        me.coordSelf.apply_course_distance(me.headAngle, me.mDist);

	        return [me.coordSelf.lat(), me.coordSelf.lon()];
	    },
	    setupGrid: func {
	        me.gridGroup = me.mapCenter.createChild("group")
	            .set("z-index", zIndex.tad.grid);
	        me.gridGroupText = me.mapCenter.createChild("group")
	            .set("z-index", zIndex.tad.gridText);
	        me.last_lat = 0;
	        me.last_lon = 0;
	        me.last_range = 0;
	        me.last_result = 0;
	        me.gridTextO = [];
	        me.gridTextA = [];
	        me.gridTextMaxA = -1;
	        me.gridTextMaxO = -1;
	    },

	    updateGrid: func {
	        #line finding algorithm taken from $fgdata mapstructure:
	        var lines = [];
	        if (!me.mapShowGrid) {
	            me.gridGroup.hide();
	            me.gridGroupText.hide();
	            return;
	        }
	        if (zoomLevels[zoom_curr] == 160) {
	            me.granularity_lon = 2;
	            me.granularity_lat = 2;
	        } elsif (zoomLevels[zoom_curr] == 80) {
	            me.granularity_lon = 1;
	            me.granularity_lat = 1;
	        } elsif (zoomLevels[zoom_curr] == 40) {
	            me.granularity_lon = 0.5;
	            me.granularity_lat = 0.5;
	        } elsif (zoomLevels[zoom_curr] == 20) {
	            me.granularity_lon = 0.25;
	            me.granularity_lat = 0.25;
	        } else {
	            me.gridGroup.hide();
	            me.gridGroupText.hide();
	            return;
	        }
	        
	        var delta_lon = me.granularity_lon;
	        var delta_lat = me.granularity_lat;

	        # Find the nearest lat/lon line to the map position.  If we were just displaying
	        # integer lat/lon lines, this would just be rounding.
	        
	        var lat = delta_lat * math.round(me.lat / delta_lat);
	        var lon = delta_lon * math.round(me.lon / delta_lon);
	        
	        var range = 0.75*me.max_y*M2NM/M2TEX;#simplified
	        #printf("grid range=%d %.3f %.3f",range,me.lat,me.lon);

	        # Return early if no significant change in lat/lon/range - implies no additional
	        # grid lines required
	        if ((lat == me.last_lat) and (lon == me.last_lon) and (range == me.last_range)) {
	            lines = me.last_result;
	        } else {

	            # Determine number of degrees of lat/lon we need to display based on range
	            # 60nm = 1 degree latitude, degree range for longitude is dependent on latitude.
	            var lon_range = 1;
	            call(func{lon_range = geo.Coord.new().set_latlon(lat,lon,me.input.alt_ft.getValue()*FT2M).apply_course_distance(90.0, range*NM2M).lon() - lon;},nil, var err=[]);
	            #courseAndDistance
	            if (size(err)) {
	                #printf("fail lon %.7f  lat %.7f  ft %.2f  ft %.2f",lon,lat,me.input.alt_ft.getValue(),range*NM2M);
	                # typically this fail close to poles. Floating point exception in geo asin.
	            }
	            var lat_range = range/60.0;

	            lon_range = delta_lon * math.ceil(lon_range / delta_lon);
	            lat_range = delta_lat * math.ceil(lat_range / delta_lat);

	            lon_range = math.clamp(lon_range,delta_lon,250);
	            lat_range = math.clamp(lat_range,delta_lat,250);
	            
	            #printf("range lon %f  lat %f",lon_range,lat_range);
	            for (var x = (lon - lon_range); x <= (lon + lon_range); x += delta_lon) {
	                var coords = [];
	                if (x>180) {
	                #   x-=360;
	                    continue;
	                } elsif (x<-180) {
	                #   x+=360;
	                    continue;
	                }
	                # We could do a simple line from start to finish, but depending on projection,
	                # the line may not be straight.
	                for (var y = (lat - lat_range); y <= (lat + lat_range); y +=  delta_lat) {
	                    append(coords, {lon:x, lat:y});
	                }
	                var ddLon = math.round(math.fmod(abs(x), 1.0) * 60.0);
	                append(lines, {
	                    id: x,
	                    type: "lon",
	                    text1: sprintf("%4d",int(x)),
	                    text2: ddLon==0?"":ddLon~"",
	                    path: coords,
	                    equals: func(o){
	                        return (me.id == o.id and me.type == o.type); # We only display one line of each lat/lon
	                    }
	                });
	            }
	            
	            # Lines of latitude
	            for (var y = (lat - lat_range); y <= (lat + lat_range); y += delta_lat) {
	                var coords = [];
	                if (y>90 or y<-90) continue;
	                # We could do a simple line from start to finish, but depending on projection,
	                # the line may not be straight.
	                for (var x = (lon - lon_range); x <= (lon + lon_range); x += delta_lon) {
	                    append(coords, {lon:x, lat:y});
	                }

	                var ddLat = math.round(math.fmod(abs(y), 1.0) * 60.0);
	                append(lines, {
	                    id: y,
	                    type: "lat",
	                    text: str(int(y))~(ddLat==0?"   ":" "~ddLat),
	                    path: coords,
	                    equals: func(o){
	                        return (me.id == o.id and me.type == o.type); # We only display one line of each lat/lon
	                    }
	                });
	            }
	#printf("range %d  lines %d",range, size(lines));
	        }
	        me.last_result = lines;
	        me.last_lat = lat;
	        me.last_lon = lon;
	        me.last_range = range;
	        
	        
	        me.gridGroup.removeAllChildren();
	        #me.gridGroupText.removeAllChildren();
	        me.gridTextNoA = 0;
	        me.gridTextNoO = 0;
	        me.gridH = me.max_y*0.80;
	        foreach (var line;lines) {
	            var skip = 1;
	            me.posi1 = [];
	            foreach (var coord;line.path) {
	                if (!skip) {
	                    me.posi2 = me.laloToTexelMap(coord.lat,coord.lon);
	                    me.aline.lineTo(me.posi2);
	                    if (line.type=="lon") {
	                        var arrow = [(me.posi1[0]*4+me.posi2[0])/5,(me.posi1[1]*4+me.posi2[1])/5];
	                        me.aline.moveTo(arrow);
	                        me.aline.lineTo(arrow[0]-7,arrow[1]+10);
	                        me.aline.moveTo(arrow);
	                        me.aline.lineTo(arrow[0]+7,arrow[1]+10);
	                        me.aline.moveTo(me.posi2);
	                        if (me.posi2[0]<me.gridH and me.posi2[0]>-me.gridH and me.posi2[1]<me.gridH and me.posi2[1]>-me.gridH) {
	                            # sadly when zoomed in alot it draws too many crossings, this condition should help
	                            me.setGridTextO(line.text1,[me.posi2[0]-20,me.posi2[1]+5]);
	                            if (line.text2 != "") {
	                                me.setGridTextO(line.text2,[me.posi2[0]+12,me.posi2[1]+5]);
	                            }
	                        }
	                    } else {
	                        me.posi3 = [(me.posi1[0]+me.posi2[0])*0.5, (me.posi1[1]+me.posi2[1])*0.5-5];
	                        if (me.posi3[0]<me.gridH and me.posi3[0]>-me.gridH and me.posi3[1]<me.gridH and me.posi3[1]>-me.gridH) {
	                            # sadly when zoomed in alot it draws too many crossings, this condition should help
	                            me.setGridTextA(line.text,me.posi3);
	                        }
	                    }
	                    me.posi1=me.posi2;
	                } else {
	                    me.posi1 = me.laloToTexelMap(coord.lat,coord.lon);
	                    me.aline = me.gridGroup.createChild("path")
	                        .moveTo(me.posi1)
	                        .setStrokeLineWidth(lineWidth.tad.grid)
	                        .setColor(colorText1);
	                }
	                skip = 0;
	            }
	        }
	        for (me.jjjj = me.gridTextNoO;me.jjjj<=me.gridTextMaxO;me.jjjj+=1) {
	            me.gridTextO[me.jjjj].hide();
	        }
	        for (me.kkkk = me.gridTextNoA;me.kkkk<=me.gridTextMaxA;me.kkkk+=1) {
	            me.gridTextA[me.kkkk].hide();
	        }
	        me.gridGroupText.update();
	        me.gridGroup.update();
	        me.gridGroupText.show();
	        me.gridGroup.show();
	    },

	    setGridTextO: func (text, pos) {
	        if (me.gridTextNoO > me.gridTextMaxO) {
	                append(me.gridTextO,me.gridGroupText.createChild("text")
	                        .setText(text)
	                        .setColor(colorText1)
	                        .setAlignment("center-top")
	                        .setTranslation(pos)
	                        .setFontSize(font.tad.gridText, 1));
	            me.gridTextMaxO += 1;   
	        } else {
	            me.gridTextO[me.gridTextNoO].setText(text).setTranslation(pos);
	        }
	        me.gridTextO[me.gridTextNoO].show();
	        me.gridTextNoO += 1;
	    },
	    
	    setGridTextA: func (text, pos) {
	        if (me.gridTextNoA > me.gridTextMaxA) {
	                append(me.gridTextA,me.gridGroupText.createChild("text")
	                        .setText(text)
	                        .setColor(colorText1)
	                        .setAlignment("center-bottom")
	                        .setTranslation(pos)
	                        .setFontSize(font.tad.gridText, 1));
	            me.gridTextMaxA += 1;   
	        } else {
	            me.gridTextA[me.gridTextNoA].setText(text).setTranslation(pos);
	        }
	        me.gridTextA[me.gridTextNoA].show();
	        me.gridTextNoA += 1;
	    },

	#  ███    ███  █████  ██████  
	#  ████  ████ ██   ██ ██   ██ 
	#  ██ ████ ██ ███████ ██████  
	#  ██  ██  ██ ██   ██ ██      
	#  ██      ██ ██   ██ ██      
	#                             
	#                             
	    initMap: func {
	        # map groups
	        me.mapCentrum = me.group.createChild("group")
	            .set("z-index", zIndex.device.map)
	            .setTranslation(me.max_x*0.5,me.max_y*0.5);
	        me.mapCenter = me.mapCentrum.createChild("group");
	        me.mapRot = me.mapCenter.createTransform();
	        me.mapFinal = me.mapCenter.createChild("group")
	            .set("z-index",  zIndex.tad.mapTiles);
	        me.rootCenter = me.group.createChild("group")
	            .setTranslation(me.max_x/2,me.max_y/2)
	            .set("z-index",  zIndex.device.mapOverlay);

	        me.hdgUp = 1;
	    },

	    setupMap: func {
	        me.mapFinal.removeAllChildren();
	        for(var x = 0; x < num_tiles[0]; x += 1) {
	            tiles[x] = setsize([], num_tiles[1]);
	            for(var y = 0; y < num_tiles[1]; y += 1) {
	                tiles[x][y] = me.mapFinal.createChild("image", sprintf("map-tile-%03d-%03d",x,y)).set("z-index", 15);#.set("size", "256,256");
	                if (me.day == 1) {
	                    tiles[x][y].set("fill", COLOR_DAY);
	                } else {
	                    tiles[x][y].set("fill", COLOR_NIGHT);
	                }
	            }
	        }
	    },

	    whereIsMap: func {
	        # update the map position
	        me.lat_own = me.input.latitude.getValue();
	        me.lon_own = me.input.longitude.getValue();
	        if (me.mapSelfCentered) {
	            # get current position
	            me.lat = me.lat_own;
	            me.lon = me.lon_own;# TODO: USE GPS/INS here.
	        }       
	        M2TEX = 1/(meterPerPixel[zoom]*math.cos(me.lat*D2R));
	    },

	    updateMap: func {
	        me.rootCenter.setVisible(1);
	        me.mapCentrum.setVisible(1);
	        if (!1) {
	            return;
	        }
	        # update the map
	        if (lastDay != me.day or providerOptionLast != providerOption)  {
	            me.setupMap();
	        }
	        me.rootCenterY = me.ownPosition;#me.canvasY*0.875-(me.canvasY*0.875)*me.ownPosition;
	        if (!me.mapSelfCentered) {
	            me.lat_wp   = me.input.latitude.getValue();
	            me.lon_wp   = me.input.longitude.getValue();
	            me.tempReal = me.laloToTexel(me.lat,me.lon);
	            me.rootCenter.setTranslation(me.max_x/2-me.tempReal[0], me.rootCenterY-me.tempReal[1]);
	            #me.rootCenterTranslation = [width/2-me.tempReal[0], me.rootCenterY-me.tempReal[1]];
	        } else {
	            me.tempReal = [0,0];
	            me.rootCenter.setTranslation(me.max_x/2, me.rootCenterY);
	            #me.rootCenterTranslation = [width/2, me.rootCenterY];
	        }
	        me.mapCentrum.setTranslation(me.max_x/2, me.rootCenterY);

	        me.n = math.pow(2, zoom);
	        me.center_tile_float = [
	            me.n * ((me.lon + 180) / 360),
	            (1 - math.ln(math.tan(me.lat * D2R) + 1 / math.cos(me.lat * D2R)) / math.pi) / 2 * me.n
	        ];
	        # center_tile_offset[1]
	        me.center_tile_int = [math.floor(me.center_tile_float[0]), math.floor(me.center_tile_float[1])];

	        me.center_tile_fraction_x = me.center_tile_float[0] - me.center_tile_int[0];
	        me.center_tile_fraction_y = me.center_tile_float[1] - me.center_tile_int[1];
	        #printf("\ncentertile: %d,%d fraction %.2f,%.2f",me.center_tile_int[0],me.center_tile_int[1],me.center_tile_fraction_x,me.center_tile_fraction_y);
	        me.tile_offset = [math.floor(num_tiles[0]/2), math.floor(num_tiles[1]/2)];

	        # 3x3 example: (same for both canvas-tiles and map-tiles)
	        #  *************************
	        #  * -1,-1 *  0,-1 *  1,-1 *
	        #  *************************
	        #  * -1, 0 *  0, 0 *  1, 0 *
	        #  *************************
	        #  * -1, 1 *  0, 1 *  1, 1 *
	        #  *************************
	        #
	        # x goes from -180 lon to +180 lon (zero to me.n)
	        # y goes from +85.0511 lat to -85.0511 lat (zero to me.n)
	        #
	        # me.center_tile_float is always positives, it denotes where we are in x,y (floating points)
	        # me.center_tile_int is the x,y tile that we are in (integers)
	        # me.center_tile_fraction is where in that tile we are located (normalized)
	        # me.tile_offset is the negative buffer so that we show tiles all around us instead of only in x,y positive direction

	#print();
	#var posx = 0;
	#var posy = 0;
	        for(var xxx = 0; xxx < num_tiles[0]; xxx += 1) {
	            for(var yyy = 0; yyy < num_tiles[1]; yyy += 1) {
	                tiles[xxx][yyy].setTranslation(-math.floor((me.center_tile_fraction_x - xxx+me.tile_offset[0]) * tile_size), -math.floor((me.center_tile_fraction_y - yyy+me.tile_offset[1]) * tile_size));
	#var xxxx = posx -math.floor((me.center_tile_fraction_x - xxx+me.tile_offset[0]) * tile_size);
	#var yyyy = posy -math.floor((me.center_tile_fraction_y - yyy+me.tile_offset[1]) * tile_size);
	#printf("Pos %d,%d  (%d,%d)", -math.floor((me.center_tile_fraction_x - xxx+me.tile_offset[0]) * tile_size), -math.floor((me.center_tile_fraction_y - yyy+me.tile_offset[1]) * tile_size),xxxx,yyyy);                
	#printf("  center_tile_fraction_x(%.3f)-xxx(%d)+tile_offset(%.3f) =%.3f  [*tile_size=%.3f]",me.center_tile_fraction_x,xxx,me.tile_offset[0],me.center_tile_fraction_x - xxx+me.tile_offset[0],(me.center_tile_fraction_x - xxx+me.tile_offset[0]) * tile_size);
	#posx = math.floor((me.center_tile_fraction_x - xxx+me.tile_offset[0]) * tile_size);
	#posy = math.floor((me.center_tile_fraction_y - yyy+me.tile_offset[1]) * tile_size);
	            }
	        }

	        me.liveMap = 1;# TODO: Read from property if allow internet access
	        me.zoomed = zoom != last_zoom;
	        if(me.center_tile_int[0] != last_tile[0] or me.center_tile_int[1] != last_tile[1] or type != last_type or me.zoomed or me.liveMap != lastLiveMap or lastDay != me.day or providerOptionLast != providerOption)  {
	            for(var x = 0; x < num_tiles[0]; x += 1) {
	                for(var y = 0; y < num_tiles[1]; y += 1) {
	                    # inside here we use 'var' instead of 'me.' due to generator function, should be able to remember it.
	                    var xx = me.center_tile_int[0] + x - me.tile_offset[0];
	                    if (xx < 0) {
	                        # when close to crossing 180 longitude meridian line, make sure we see the tiles on the positive side of the line.
	                        xx = me.n + xx;#print(xx~" from "~(xx-me.n));
	                    } elsif (xx >= me.n) {
	                        # when close to crossing 180 longitude meridian line, make sure we dont double load the tiles on the negative side of the line.
	                        xx = xx - me.n;#print(xx~" from "~(xx+me.n));
	                    }
	                    var pos = {
	                        z: zoom,
	                        x: xx,
	                        y: me.center_tile_int[1] + y - me.tile_offset[1],
	                        type: type
	                    };

	                    (func {# generator function
	                        var img_path = makePath(pos);
	                        var tile = tiles[x][y];
	                        logprint(LOG_DEBUG, 'showing ' ~ img_path);
	                        if( io.stat(img_path) == nil and me.liveMap == 1) { # image not found, save in $FG_HOME
	                            var img_url = makeUrl(pos);
	                            logprint(LOG_DEBUG, 'requesting ' ~ img_url);
	                            http.save(img_url, img_path)
	                                .done(func(r) {
	                                    logprint(LOG_DEBUG, 'received image ' ~ img_path~" " ~ r.status ~ " " ~ r.reason);
	                                    logprint(LOG_DEBUG, ""~(io.stat(img_path) != nil));
	                                    tile.set("src", img_path);# this sometimes fails with: 'Cannot find image file' if use me. instead of var.
	                                    tile.update();
	                                    })
	                              #.done(func {logprint(LOG_DEBUG, 'received image ' ~ img_path); tile.set("src", img_path);})
	                              .fail(func (r) {logprint(LOG_INFO, 'Failed to get image ' ~ img_path ~ ' ' ~ r.status ~ ': ' ~ r.reason);
	                                            tile.set("src", "Aircraft/A-10/Nasal/displays/emptyTile.png");
	                                            tile.update();
	                                            });
	                        } elsif (io.stat(img_path) != nil) {# cached image found, reusing
	                            logprint(LOG_DEBUG, 'loading ' ~ img_path);
	                            tile.set("src", img_path);
	                            tile.update();
	                        } else {
	                            # internet not allowed, so noise tile shown
	                            tile.set("src", "Aircraft/A-10/Nasal/displays/noiseTile.png");
	                            tile.update();
	                        }
	                    })();
	                }
	            }

	        last_tile = me.center_tile_int;
	        last_type = type;
	        last_zoom = zoom;
	        lastLiveMap = me.liveMap;
	        lastDay = me.day;
	        providerOptionLast = providerOption;
	        }

	        if (me.hdgUp and me.input.servHead.getValue()) me.mapCenter.setRotation(-me.input.heading.getValue()*D2R);
	        else me.mapCenter.setRotation(0);
	        #switched to direct rotation to try and solve issue with approach line not updating fast.
	        me.mapCenter.update();
	    },
		enter: func {
			printDebug("Enter ",me.name~" on ",me.device.name);
			if (me.isNew) {
				me.setup();
				me.isNew = 0;
			}
			me.device.resetControls();
			me.device.controls["OSB1"].setControlText("OUT");
			me.device.controls["OSB2"].setControlText("IN");
			me.device.controls["OSB3"].setControlText(me.day?"DIM":"LIGHT");
			me.device.controls["OSB4"].setControlText(providerOptionTags[providerOption]);
			me.device.controls["OSB7"].setControlText("80");
			me.device.controls["OSB8"].setControlText("GRID\nON ");
			me.device.controls["OSB16"].setControlText("MAP\nUP");
			me.device.controls["OSB20"].setControlText("SADL");
			me.device.controls["OSB21"].setControlText("TAD");
			if (me.tadInit == 1){
				me.loopTimer.start();
			};

		},
		controlAction: func (controlName) {
			printDebug(me.name,": ",controlName," activated on ",me.device.name);
			if (controlName == "OSB1") {
				me.zoomOut();
			} elsif (controlName == "OSB2") {
				me.zoomIn();
			} elsif (controlName == "OSB3") {
				me.toggleDay();
			} elsif (controlName == "OSB4") {
				me.toggleMap();
			} elsif (controlName == "OSB16") {
				me.toggleHdgUp();
			} elsif (controlName == "OSB8") {
				me.toggleGrid();
			}
		},
		update: func (noti = nil) {
		},
		exit: func {
			printDebug("Exit ",me.name~" on ",me.device.name);
			me.loopTimer.stop();
		},
		links: {
			"OSB20": "PageSADLBase",
			"OSB21": "PageTac",
		},
		layers: [],
	},


#  ███████ ███    ██ ██████       ██████  ███████     ██████   █████   ██████  ███████ ███████ 
#  ██      ████   ██ ██   ██     ██    ██ ██          ██   ██ ██   ██ ██       ██      ██      
#  █████   ██ ██  ██ ██   ██     ██    ██ █████       ██████  ███████ ██   ███ █████   ███████ 
#  ██      ██  ██ ██ ██   ██     ██    ██ ██          ██      ██   ██ ██    ██ ██           ██ 
#  ███████ ██   ████ ██████       ██████  ██          ██      ██   ██  ██████  ███████ ███████ 
#                                                                                              
#                                                                                              

};

var flyupTime = 0;
var flyupVis = 0;
# updateFlyup = func(notification=nil) {
#     #if (me.current_page != nil) {
#         flyupTime = getprop("instrumentation/radar/time-till-crash");
#         if (flyupTime != nil and flyupTime > 0 and flyupTime < 8) {
#             flyupVis = math.mod(getprop("sim/time/elapsed-sec"), 0.50) < 0.25;
#         } else {
#             flyupVis = 0;
#         }
#         rightMPCD.pullUpCue(flyupVis);
#         leftMFD.pullUpCue(flyupVis);
#     #}
# }

# Cursor stuff
var cursor_pos = [100,-100];
var cursor_posHAS = [0,-256];
var cursor_pos_hsd = [0, -50];
var cursor_click = -1;
var cursor_lock = -1;
var slew_c = 0;
var exp = 0;
var fcrModeChange = 0;
var cursorFCRgps = nil;
var cursorFCRair = 1;


setlistener("controls/displays/cursor-click", func (node) {if (node.getValue()) {slew_c = 1;}},0,0);

var cursorZero = func {
    cursor_pos = [0,-256];
}
cursorZero();

var hsdShowNAV1 = 1;
var hsdShowDLINK = 1;
var hsdShowRINGS = 1;
var hsdShowPRE = 1;
var hsdShowFCR = 1;

var fcrFrz = 0;
var fcrBand = 0;
var fcrChan = 2;

var flirMode = -2;
var tfrMode  =  1;
var tfrFreq  =  1;
var tfr_current_terr = 1000;
var tfr_range_m = 1000;
var tfr_target_altitude_m = 0;

var rightMPCD = nil;

var swapAircraftSOI = func (soi) {
	if (soi != nil) {
		f16.SOI = soi;
	}
}

var A10MfdRecipient =
{
    new: func(_ident)
    {
        var new_class = emesary.Recipient.new(_ident~".MFD");

        new_class.Receive = func(notification)
        {
            if (notification == nil)
            {
                print("bad notification nil");
                return emesary.Transmitter.ReceiptStatus_NotProcessed;
            }

            if (notification.NotificationType == "FrameNotification")
            {
                rightMPCD.update(notification);
                return emesary.Transmitter.ReceiptStatus_OK;
            }
            return emesary.Transmitter.ReceiptStatus_NotProcessed;
        };
        new_class.del = func {
        	emesary.GlobalTransmitter.DeRegister(me);
        };
        return new_class;
    },
};
var A10_display = nil;

var vector_aicontacts_links = [];
var DLRecipient = emesary.Recipient.new("DLRecipient");
var startDLListener = func {
    DLRecipient.radar = radar_system.dlnkRadar;
    DLRecipient.Receive = func(notification) {
        if (notification.NotificationType == "DatalinkNotification") {
            # printf("DL recv: %s", notification.NotificationType);
            if (me.radar.enabled == 1) {
                vector_aicontacts_links = notification.vector;
            }
            return emesary.Transmitter.ReceiptStatus_OK;
        }
        return emesary.Transmitter.ReceiptStatus_NotProcessed;
    };
    emesary.GlobalTransmitter.Register(DLRecipient);
}

var displayWidth     = 1024;#552 * 0.795;
var displayHeight    = 1024;#482 * 1;
var displayWidthHalf = displayWidth  *  0.5;
var displayHeightHalf= displayHeight  *  0.5;

var forcePages = func (v, system) {
	if (v == 0) {
        system.selectPage("PageSADLBase");
    } elsif (v == 1) {
        system.selectPage("PageSADLBase");
    }
}

var main = func (module) {
	# TEST CODE:
	var height = 1024;#482;
	var width  = 1024;#552;

	rightMPCD = DisplayDevice.new("rightMPCD", [width,height], [1, 1], "canvas_disp", "mpcd_canvas.png");
	rightMPCD.setColorBackground(colorBackground);

	rightMPCD.setControlTextColors(colorText1, colorBackground);

	width *= 1;#0.795;

	var osbPositions = [
		[0, 0.65*height/6],
		[0, 1.7*height/6],
		[0, 2.7*height/6],
		[0, 3.7*height/6],
		[0, 4.7*height/6],
		[0, 5.5*height/6],

		[width, 0.65*height/6],
		[width, 1.7*height/6],
		[width, 2.7*height/6],
		[width, 3.7*height/6],
		[width, 4.7*height/6],
		[width, 5.5*height/6],


		[0.55*width/7, 0],
		[1.55*width/7, 0],
		[2.55*width/7, 0],
		[3.55*width/7, 0],
		[4.55*width/7, 0],
		[5.55*width/7, 0],
		[6.55*width/7, 0],

		[0.55*width/7, height],
		[1.55*width/7, height],
		[2.55*width/7, height],
		[3.55*width/7, height],
		[4.55*width/7, height],
		[5.55*width/7, height],
		[6.55*width/7, height],
	];


	var mfdSystem1 = DisplaySystem.new();
	rightMPCD.setDisplaySystem(mfdSystem1);

	mfdSystem1.initDevice(0, osbPositions, font.device.main);

	rightMPCD.addControlFeedback();


	mfdSystem1.initPages();


	forcePages(1, mfdSystem1);

	A10_display = A10MfdRecipient.new("A10-displaySystem");
	emesary.GlobalTransmitter.Register(A10_display);
}

#var theMaster = nil;

var unload = func {
	if (rightMPCD != nil) {
		rightMPCD.del();
		rightMPCD = nil;
	}
	DisplayDevice = nil;
	DisplaySystem = nil;

	A10_display.del();
}

var displayDebug = 0;
var printDebug = func {if (displayDebug) {call(print,arg,nil,nil,var err = []); if(size(err)) print (err[0]);}};
var printfDebug = func {if (displayDebug) {var str = call(sprintf,arg,nil,nil,var err = []);if(size(err))print (err[0]);else print (str);}};
# Note calling printf directly with call() will sometimes crash the sim, so we call sprintf instead.


# main(nil);# disable this line if running as module