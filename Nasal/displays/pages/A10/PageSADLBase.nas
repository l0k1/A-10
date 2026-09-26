var PageSADLBase = {
		name: "PageSADLBase",
		isNew: 1,
		supportSOI: 0,
		needGroup: 1,
		showFrame: 1,
		new: func {
			me.instance = {parents:[PageSADLBase]};
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
			me.device.controls["OSB16"].setControlText("SET");
			me.device.controls["OSB20"].setControlText("SADL");
			me.device.controls["OSB21"].setControlText("TAC");
			me.device.controls["OSB22"].setControlText("BIRD");
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
			"OSB22": "PageShootThePig",
		},
		layers: [],
};
