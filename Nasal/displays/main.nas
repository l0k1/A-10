# FlightGear loads this file as the reloadable A-10 displays module.
# Aircraft-specific pages live in pages/; reusable
# device, control, page, and navigation behavior lives in core/.

io.include("config.nas");

io.include("core/controls.nas");
io.include("core/page.nas");
io.include("core/system.nas");
io.include("core/device.nas");

io.include("pages/Common/PageOSB.nas");
io.include("pages/A10/PageSADLCode.nas");
io.include("pages/A10/PageSADLBase.nas");
io.include("pages/A10/PageShootThePig.nas");
io.include("pages/A10/PageTac.nas");

var flyupTime = 0;
var flyupVis = 0;

var cursor_pos = [100, -100];
var cursor_posHAS = [0, -256];
var cursor_pos_hsd = [0, -50];
var cursor_click = -1;
var cursor_lock = -1;
var slew_c = 0;
var exp = 0;
var fcrModeChange = 0;
var cursorFCRgps = nil;
var cursorFCRair = 1;

var hsdShowNAV1 = 1;
var hsdShowDLINK = 1;
var hsdShowRINGS = 1;
var hsdShowPRE = 1;
var hsdShowFCR = 1;

var fcrFrz = 0;
var fcrBand = 0;
var fcrChan = 2;

var flirMode = -2;
var tfrMode = 1;
var tfrFreq = 1;
var tfr_current_terr = 1000;
var tfr_range_m = 1000;
var tfr_target_altitude_m = 0;

var rightMPCD = nil;
var displayDevices = {};
var displayListeners = [];
var A10_display = nil;

var displayDebug = 0;
var printDebug = func {
	if (displayDebug) {
		call(print, arg, nil, nil, var err = []);
		if (size(err)) print(err[0]);
	}
};
var printfDebug = func {
	if (displayDebug) {
		var str = call(sprintf, arg, nil, nil, var err = []);
		if (size(err)) print(err[0]);
		else print(str);
	}
};

var cursorZero = func {
	cursor_pos = [0, -256];
};

var swapAircraftSOI = func (soi) {
	if (soi != nil) f16.SOI = soi;
};

var registerDisplayPages = func (module) {
	DisplayPageRegistry.reset();
	var namespace = module.getNamespace();
	foreach (var pageName; DISPLAY_PAGE_IDS) {
		var page = namespace[pageName];
		if (page == nil) die("Display page is not defined: " ~ pageName);
		DisplayPageRegistry.register(page);
	}
	foreach (var layerName; DISPLAY_LAYER_IDS) {
		var layer = namespace[layerName];
		if (layer == nil) die("Display layer is not defined: " ~ layerName);
		DisplayPageRegistry.register(layer);
	}
};

var forcePages = func (selector, system) {
	system.selectPage(selector == 0 ? DISPLAY_PAGE_SELECTOR.off : DISPLAY_PAGE_SELECTOR.on);
};

var buildOsbPositions = func (width, height) {
	return [
		[0, 0.65 * height / 6],
		[0, 1.7 * height / 6],
		[0, 2.7 * height / 6],
		[0, 3.7 * height / 6],
		[0, 4.7 * height / 6],
		[0, 5.5 * height / 6],

		[width, 0.65 * height / 6],
		[width, 1.7 * height / 6],
		[width, 2.7 * height / 6],
		[width, 3.7 * height / 6],
		[width, 4.7 * height / 6],
		[width, 5.5 * height / 6],

		[0.55 * width / 7, 0],
		[1.55 * width / 7, 0],
		[2.55 * width / 7, 0],
		[3.55 * width / 7, 0],
		[4.55 * width / 7, 0],
		[5.55 * width / 7, 0],
		[6.55 * width / 7, 0],

		[0.55 * width / 7, height],
		[1.55 * width / 7, height],
		[2.55 * width / 7, height],
		[3.55 * width / 7, height],
		[4.55 * width / 7, height],
		[5.55 * width / 7, height],
		[6.55 * width / 7, height],
	];
};

var A10MfdRecipient = {
	new: func (_ident) {
		var recipient = emesary.Recipient.new(_ident ~ ".MFD");
		recipient.Receive = func (notification) {
			if (notification == nil) {
				print("bad notification nil");
				return emesary.Transmitter.ReceiptStatus_NotProcessed;
			}
			if (notification.NotificationType == "FrameNotification") {
				if (rightMPCD != nil) rightMPCD.update(notification);
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		recipient.del = func {
			emesary.GlobalTransmitter.DeRegister(me);
		};
		return recipient;
	},
};

var vector_aicontacts_links = [];
var DLRecipient = emesary.Recipient.new("DLRecipient");
var dlRecipientRegistered = 0;
var startDLListener = func {
	if (dlRecipientRegistered) return;
	DLRecipient.radar = radar_system.dlnkRadar;
	DLRecipient.Receive = func(notification) {
		if (notification.NotificationType == "DatalinkNotification") {
			if (me.radar.enabled == 1) vector_aicontacts_links = notification.vector;
			return emesary.Transmitter.ReceiptStatus_OK;
		}
		return emesary.Transmitter.ReceiptStatus_NotProcessed;
	};
	emesary.GlobalTransmitter.Register(DLRecipient);
	dlRecipientRegistered = 1;
};

var buildDisplays = func {
	var osbPositions = buildOsbPositions(displayWidth, displayHeight);
	displayDevices = {};

	foreach (var deviceConfig; DISPLAY_DEVICES) {
		var device = DisplayDevice.new(
			deviceConfig.name,
			[displayWidth, displayHeight],
			DISPLAY_UV_MAP,
			deviceConfig.placementNode,
			deviceConfig.texture
		);
		device.setColorBackground(colorBackground);
		device.setControlTextColors(colorText1, colorBackground);

		var system = DisplaySystem.new();
		device.setDisplaySystem(system);
		system.initDevice(deviceConfig.propertyIndex, osbPositions, font.device.main);
		device.addControlFeedback();
		system.initPages();
		forcePages(deviceConfig.initialSelector, system);

		displayDevices[deviceConfig.slot] = device;
		if (deviceConfig.slot == "rightMPCD") rightMPCD = device;
	}

	A10_display = A10MfdRecipient.new("A10-displaySystem");
	emesary.GlobalTransmitter.Register(A10_display);
};

var main = func (module) {
	print("DISPLAYS LOADING");
	setprop(DISPLAY_RUNTIME_PROPERTY_PATHS.electricalOutput, 1);
	cursorZero();
	registerDisplayPages(module);

	displayListeners = [];
	append(displayListeners, setlistener(DISPLAY_RUNTIME_PROPERTY_PATHS.cursorClick, func (node) {
		if (node.getValue()) slew_c = 1;
	}, 0, 0));

	buildDisplays();
};

var unload = func {
	if (A10_display != nil) {
		A10_display.del();
		A10_display = nil;
	}

	foreach (var deviceConfig; DISPLAY_DEVICES) {
		var device = displayDevices[deviceConfig.slot];
		if (device != nil) device.del();
	}
	displayDevices = {};
	rightMPCD = nil;

	if (dlRecipientRegistered) {
		emesary.GlobalTransmitter.DeRegister(DLRecipient);
		dlRecipientRegistered = 0;
	}

	# modules.Module removes tracked property listeners before calling unload().
	displayListeners = [];
};
