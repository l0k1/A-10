var PageSADLCode = {
		name: "PageSADLCode",
		isNew: 1,
		supportSOI: 0,
		needGroup: 1,
		showFrame: 1,
		new: func {
			me.instance = {parents:[PageSADLCode]};
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
};
