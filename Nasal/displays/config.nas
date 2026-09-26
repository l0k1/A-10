# Shared A-10 display configuration, based upon display-system.nas from F-16.

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
		attribution: 10,
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
var zooms      = [6, 7, 8, 9, 10, 11, 12, 13];
var zoomLevels = [320, 160, 80, 40, 20, 10, 5, 2.5];
var zoomsONC      = [7, 7, 8, 9, 10, 10]; #These are fpr arcgis_onc only, because there is a much more limited range of tile levels
var zoomLevelsONC = [320, 160, 80, 40, 20, 10];
var zoom_init = 2;
var zoom_curr  = zoom_init;
var zoom = zooms[zoom_curr];
var tile_zoom = zoom;
var tile_scale = 1;
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
    mapproject_tpc: {
                templateLoad: "https://fgfs-a10-tiles.b-cdn.net/uk-tpc-onc-v1-20260925/{z}/{x}/{y}.png",
                templateStore: "/fgfs-a10-tiles/{z}/{y}/{x}.png",
                attribution: "(C) OPENSTREETMAP CONTRIBUTORS\nOPENAIP / MAPZEN-TILEZEN TERRAIN\nNATURAL EARTH / OURAIRPORTS\nSIMULATION ONLY",
                min: 7, max: 11},
};

var providerOption = 1;
var providerOptionLast = providerOption;
var providerOptionTags = ["TOPO ","PHOTO ","VFR_US ","ONC ","TPC "];
var providerOptions = [
# This one works on Linux and Windows only
["arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo","arcgis_topo"],
# This one works on MacOS also, so is default
["arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain","arcgis_terrain"],
["arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr","arcgis_vfr"],
["arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc","arcgis_onc"],
["mapproject_tpc","mapproject_tpc","mapproject_tpc","mapproject_tpc","mapproject_tpc","mapproject_tpc","mapproject_tpc","mapproject_tpc"]
];

var zoom_provider = providerOptions[providerOption];

var makeUrl   = string.compileTemplate(providers[zoom_provider[zoom_curr]].templateLoad);
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

# Shared display-core configuration.
var DISPLAY_FONT_FILE = "A10-HUD.ttf";
var DISPLAY_CONTROL_LABEL_FILL_DEFAULT = 1;
var DISPLAY_SVG_DEFAULT_FONT_FILE = DISPLAY_FONT_FILE;
var DISPLAY_SVG_FONT_MAP = [
	{ family: "A10 HUD", file: DISPLAY_FONT_FILE },
	{ family: "A10-HUD", file: DISPLAY_FONT_FILE },
];

var DISPLAY_DEVICE_PROPERTY_PATHS = {
	alt_ft: "instrumentation/altimeter/indicated-altitude-ft",
	alt_true_ft: "position/altitude-ft",
	heading: "instrumentation/heading-indicator/indicated-heading-deg",
	radarStandby: "instrumentation/radar/radar-standby",
	rad_alt: "instrumentation/radar-altimeter/radar-altitude-ft",
	rad_alt_ready: "instrumentation/radar-altimeter/ready",
	rmActive: "autopilot/route-manager/active",
	rmDist: "autopilot/route-manager/wp/dist",
	rmId: "autopilot/route-manager/wp/id",
	rmBearing: "autopilot/route-manager/wp/true-bearing-deg",
	RMCurrWaypoint: "autopilot/route-manager/current-wp",
	roll: "orientation/roll-deg",
	headTrue: "orientation/heading-deg",
	pitch: "orientation/pitch-deg",
	nav0InRange: "instrumentation/nav[0]/in-range",
	APLockHeading: "autopilot/locks/heading",
	APTrueHeadingErr: "autopilot/internal/true-heading-error-deg",
	APnav0HeadingErr: "autopilot/internal/nav1-heading-error-deg",
	APHeadingBug: "autopilot/settings/heading-bug-deg",
	RMActive: "autopilot/route-manager/active",
	nav0Heading: "instrumentation/nav[0]/heading-deg",
	ias: "instrumentation/airspeed-indicator/indicated-speed-kt",
	tas: "instrumentation/airspeed-indicator/true-speed-kt",
	gearsPos: "gear/gear/position-norm",
	latitude: "position/latitude-deg",
	longitude: "position/longitude-deg",
	mach: "instrumentation/airspeed-indicator/indicated-mach",
	inhg: "instrumentation/altimeter/setting-inhg",
	tacanCh: "instrumentation/tacan/display/channel",
	ilsCh: "instrumentation/nav[0]/frequencies/selected-mhz",
	servStatic: "systems/static/serviceable",
	servPitot: "systems/pitot/serviceable",
	servAtt: "instrumentation/attitude-indicator/serviceable",
	servHead: "instrumentation/heading-indicator/serviceable",
	servTurn: "instrumentation/turn-indicator/serviceable",
	dlink_code: "instrumentation/datalink/channel",
	scratchpadHolding: "A-10/displays/mpcd/holding",
};

var displayWidth = 1024;
var displayHeight = 1024;
var displayWidthHalf = displayWidth * 0.5;
var displayHeightHalf = displayHeight * 0.5;
var DISPLAY_UV_MAP = [1, 1];

var DISPLAY_CONTROL_PROPERTY_PATH = func (propertyIndex) {
	return "controls/MFD[" ~ propertyIndex ~ "]/button-pressed";
};

var DISPLAY_PAGES = {
	osb: "PageOSB",
	sadl: "PageSADLBase",
	sadlCode: "PageSADLCode",
	tad: "PageTac",
	angryBirds: "PageAngryBirds",
};

var DISPLAY_PAGE_IDS = [
	DISPLAY_PAGES.osb,
	DISPLAY_PAGES.sadl,
	DISPLAY_PAGES.sadlCode,
	DISPLAY_PAGES.tad,
	DISPLAY_PAGES.angryBirds,
];
var DISPLAY_INITIAL_PAGE_IDS = [
	DISPLAY_PAGES.sadl,
	DISPLAY_PAGES.sadlCode,
	DISPLAY_PAGES.tad,
	DISPLAY_PAGES.angryBirds,
];
var DISPLAY_LAYER_IDS = [];
var DISPLAY_PAGE_SELECTOR = {
	off: DISPLAY_PAGES.sadl,
	on: DISPLAY_PAGES.sadl,
};

var DISPLAY_DEVICES = [
	{
		slot: "rightMPCD",
		name: "rightMPCD",
		propertyIndex: 0,
		placementNode: "canvas_disp",
		texture: "mpcd_canvas.png",
		initialSelector: 1,
	},
];

var DISPLAY_RUNTIME_PROPERTY_PATHS = {
	cursorClick: "controls/displays/cursor-click",
	pageSelector: "/sim/bools/bit",
	electricalOutput: "fdm/jsbsim/electric/output/tvtab2",
};

# The optional tactical-format frame is disabled by the current A-10 pages,
# but retained in the shared core for future SVG-backed formats.
margin.device.feedbackRadius = 35;
margin.device.frame = 10;
margin.device.soi = 10;
lineWidth.device.feedback = 2;
lineWidth.device.frame = 3;
lineWidth.device.soiGlow = 7;
zIndex.device.frameFill = 50;
zIndex.deviceObs.frame = 10001;
var displayFrameFillColor = [0, 0, 0, 1];
