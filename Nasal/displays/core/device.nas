# Defines DisplayDevice, the Canvas-backed representation of one physical A-10 display.
# It combines DisplayControls and DisplayPageSupport, and handles Canvas placement,
# display updates, SOI presentation, colours, swapping, and device cleanup.
# This is shared display infrastructure, not code for any individual page.

var DisplayDevice = {
	parents: [DisplayControls, DisplayPageSupport],

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
		if (me.system != nil) {
			me.system.del();
			me.system = nil;
		}
		me.canvas.del();
		# modules.Module removes listeners before calling displays.unload().
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
		me.input = {};
		foreach (var name; keys(DISPLAY_DEVICE_PROPERTY_PATHS)) {
			me.input[name] = props.globals.getNode(DISPLAY_DEVICE_PROPERTY_PATHS[name], 1);
		}
	},

	setColorBackground: func (colorBackground) {
		me.canvas.setColorBackground(colorBackground);
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

	addSOILines: func () {
		me.tempFrameMarginX = margin.device.frame;
		me.tempFrameMarginY = margin.device.frame;
		# Black mask outside the tactical-format frame. Four closed strips leave
		# the complete framed interior untouched while covering the screen edges.
		me.pageFrameFillGrp = me.canvas.createGroup()
				.set("z-index", zIndex.device.frameFill);
		me.pageFrameFill = me.pageFrameFillGrp.createChild("path")
				.rect(
					0,
					0,
					me.uvMap[0]*me.resolution[0],
					me.tempFrameMarginY
				)
				.rect(
					0,
					me.resolution[1]-me.tempFrameMarginY,
					me.uvMap[0]*me.resolution[0],
					me.tempFrameMarginY
				)
				.rect(
					0,
					me.tempFrameMarginY,
					me.tempFrameMarginX,
					me.resolution[1]-me.tempFrameMarginY*2
				)
				.rect(
					me.uvMap[0]*me.resolution[0]-me.tempFrameMarginX,
					me.tempFrameMarginY,
					me.tempFrameMarginX,
					me.resolution[1]-me.tempFrameMarginY*2
				)
				.setColorFill(displayFrameFillColor)
				.setStrokeLineWidth(0)
				.hide();
		# Tactical-format frame. Pages opt into this independently of SOI.
		me.pageFrame = me.controlGrp.createChild("path")
				.set("z-index", zIndex.deviceObs.frame)
				.moveTo(me.tempFrameMarginX,me.tempFrameMarginY)
				.horiz(me.uvMap[0]*me.resolution[0]-me.tempFrameMarginX*2)
				.vert(me.resolution[1]-me.tempFrameMarginY*2)
				.horiz(-me.uvMap[0]*me.resolution[0]+me.tempFrameMarginX*2)
				.lineTo(me.tempFrameMarginX,me.tempFrameMarginY)
				.setColor(me.colorFront[0], me.colorFront[1], me.colorFront[2], 0.8)
				.hide()
				.setStrokeLineWidth(lineWidth.device.frame);
		# SOI remains a separate cue around the outer display perimeter.
		me.tempSOIMarginX = margin.device.soi;
		me.tempSOIMarginY = margin.device.soi;
		me.soiGlow = me.controlGrp.createChild("path")
				.set("z-index", zIndex.deviceObs.soi)
				.moveTo(me.tempSOIMarginX,me.tempSOIMarginY)
				.horiz(me.uvMap[0]*me.resolution[0]-me.tempSOIMarginX*2)
				.vert(me.resolution[1]-me.tempSOIMarginY*2)
				.horiz(-me.uvMap[0]*me.resolution[0]+me.tempSOIMarginX*2)
				.lineTo(me.tempSOIMarginX,me.tempSOIMarginY)
				.setColor(me.colorFront[0], me.colorFront[1], me.colorFront[2], 0.22)
				.hide()
				.setStrokeLineWidth(lineWidth.device.soiGlow);
		me.soiLine = me.controlGrp.createChild("path")
				.set("z-index", zIndex.deviceObs.soi + 1)
				.moveTo(me.tempSOIMarginX,me.tempSOIMarginY)
				.horiz(me.uvMap[0]*me.resolution[0]-me.tempSOIMarginX*2)
				.vert(me.resolution[1]-me.tempSOIMarginY*2)
				.horiz(-me.uvMap[0]*me.resolution[0]+me.tempSOIMarginX*2)
				.lineTo(me.tempSOIMarginX,me.tempSOIMarginY)
				.setColor(me.colorFront)
				.hide()
				.setStrokeLineWidth(lineWidth.device.soi);
		return me.soiLine;
	},

	setPageFrame: func (visible) {
		me.pageFrameFill.setVisible(visible == 1);
		me.pageFrame.setVisible(visible == 1);
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
		# Shoot the Pig uses the entire Canvas, including the outer cue area.
		var pageAllowsCue = me.system["currPage"] == nil
			or me.system.currPage.name != DISPLAY_PAGES.shootThePig;
		var selected = soi == 1 and pageAllowsCue;
		me.soiGlow.setVisible(selected);
		me.soiLine.setVisible(selected);
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

