# Defines DisplaySystem, one page/navigation controller per A-10 display device.
# It instantiates registered pages, routes OSB actions, changes the current page,
# manages layers and page visibility, and runs page cleanup before Canvas teardown.
# This is shared display infrastructure, not code for any individual page.

var DisplaySystem = {
	new: func () {
		var system = {parents : [DisplaySystem] };
		system.new = func {return nil;};
		return system;
	},

	del: func {
		if (me["pages"] != nil) {
			foreach (var pageName; keys(me.pages)) {
				var page = me.pages[pageName];
				if (page["loopTimer"] != nil) {
					call(func page.loopTimer.stop(), [], nil, nil, var err = []);
					page.loopTimer = nil;
				}
				if (page["timer"] != nil) {
					call(func page.timer.stop(), [], nil, nil, var timerErr = []);
					page.timer = nil;
				}
				if (page["del"] != nil) {
					call(func page.del(), [], nil, nil, var err = []);
				}
			}
		}
		if (me["layers"] != nil) {
			foreach (var layerName; keys(me.layers)) {
				me.destroyLayer(layerName);
			}
		}
		me.pages = {};
		me.layers = {};
		me.currPage = nil;
		me.device = nil;
	},

	setDevice: func (device) {
		me.device = device;
	},

	initDevice: func (propertyNum, controlPositions, fontSize) {
		me.device.addControls(PUSHBUTTON, "OSB", 1, 26, DISPLAY_CONTROL_PROPERTY_PATH(propertyNum), controlPositions);
		me.device.fontSize = fontSize;

		# A-10 numbering: OSB1..6 left, 7..12 right,
		# 13..19 top, and 20..26 bottom.
		for (var i = 1; i <= 6; i += 1) {
			me.device.addControlText("OSB", "OSB" ~ i, [margin.device.buttonText, 0], i - 1, -1);
		}
		for (var i = 7; i <= 12; i += 1) {
			me.device.addControlText("OSB", "OSB" ~ i, [-margin.device.buttonText, 0], i - 1, 1);
		}
		for (var i = 13; i <= 19; i += 1) {
			me.device.addControlText("OSB", "OSB" ~ i, [0, margin.device.buttonText], i - 1, 0, -1);
		}
		for (var i = 20; i <= 26; i += 1) {
			me.device.addControlText("OSB", "OSB" ~ i, [0, -margin.device.buttonText], i - 1, 0, 1);
		}
		me.device.addSOILines();
		me.device.addSOIText("NOT SOI");
		me.device.setSOI(-1);
	},

	getSOIPrio: func {
		return me.currPage.supportSOI?me.currPage.soiPrio:-1;
	},

	initPage: func (pageName) {
		if (DisplayPageRegistry.get(pageName) == nil) {print(pageName," does not exist");return;}
		me.tempPageInstance = DisplayPageRegistry.get(pageName).new();
		me.device.initPage(me.tempPageInstance);
		me.pages[me.tempPageInstance.name] = me.tempPageInstance;
	},

	initLayer: func (layerName) {
		if (me.layers[layerName] != nil) return me.layers[layerName];
		if (DisplayPageRegistry.get(layerName) == nil) {
			print(me.device.name, " layer not found: ", layerName);
			return nil;
		}
		me.tempLayerInstance = DisplayPageRegistry.get(layerName).new();
		me.device.initLayer(me.tempLayerInstance);
		me.layers[me.tempLayerInstance.name] = me.tempLayerInstance;
		return me.tempLayerInstance;
	},

	initPages: func () {
		me.pages = {};
		me.layers = {};

		foreach (var pageName; DISPLAY_INITIAL_PAGE_IDS) me.initPage(pageName);



		me.device.controlAction = func (type, controlName, propvalue) {
			me.tempLink = me.system.currPage.links[controlName];
			me.system.currPage.controlAction(controlName);
			if (me.tempLink != nil) me.system.selectPage(me.tempLink);
		};

		append(me.device.listeners, setlistener(DISPLAY_RUNTIME_PROPERTY_PATHS.pageSelector, func(node) {
            forcePages(node.getValue(), me);
        },0,0));
	},

	layerListContains: func (layerNames, layerName) {
		if (layerNames == nil) return 0;
		foreach (var candidate; layerNames) {
			if (candidate == layerName) return 1;
		}
		return 0;
	},

	fetchLayer: func (layerName) {
		if (me.layers[layerName] == nil) return me.initLayer(layerName);
		return me.layers[layerName];
	},

	showLayer: func (layerName) {
		var layer = me.fetchLayer(layerName);
		if (layer == nil) return;
		layer.group.show();
		if (layer["enter"] != nil) {
			call(func layer.enter(), [], nil, nil, var err = []);
			if (size(err)) print(err[0]);
		}
	},

	hideLayer: func (layerName) {
		var layer = me.layers[layerName];
		if (layer == nil) return;
		if (layer["exit"] != nil) {
			call(func layer.exit(), [], nil, nil, var err = []);
			if (size(err)) print(err[0]);
		}
		layer.group.hide();
	},

	destroyLayer: func (layerName) {
		var layer = me.layers[layerName];
		if (layer == nil) return;

		me.hideLayer(layerName);
		if (layer["loopTimer"] != nil) {
			call(func layer.loopTimer.stop(), [], nil, nil, var timerErr = []);
			if (size(timerErr)) print(timerErr[0]);
			layer.loopTimer = nil;
		}
		if (layer["listeners"] != nil) {
			foreach (var listener; layer.listeners) {
				call(func removelistener(listener), [], nil, nil, var listenerErr = []);
				if (size(listenerErr)) print(listenerErr[0]);
			}
			layer.listeners = [];
		}
		if (layer["del"] != nil) {
			call(func layer.del(), [], nil, nil, var delErr = []);
			if (size(delErr)) print(delErr[0]);
		}
		if (layer["group"] != nil) {
			call(func layer.group.del(), [], nil, nil, var groupErr = []);
			if (size(groupErr)) print(groupErr[0]);
			layer.group = nil;
		}
		layer.device = nil;
		delete(me.layers, layerName);
	},

	setLayers: func (page, layerNames) {
		if (layerNames == nil) layerNames = [];
		var nextLayers = [];
		foreach (var layerName; layerNames) {
			if (!me.layerListContains(DISPLAY_LAYER_IDS, layerName)) {
				print(me.device.name, " invalid layer: ", layerName);
				return 0;
			}
			if (!me.layerListContains(nextLayers, layerName)) append(nextLayers, layerName);
		}

		var previousLayers = page.layers;
		if (previousLayers == nil) previousLayers = [];
		var pageIsActive = me.currPage == page;

		foreach (var layerName; previousLayers) {
			if (me.layerListContains(nextLayers, layerName)) continue;
			var usedByActivePage = !pageIsActive
				and me.currPage != nil
				and me.layerListContains(me.currPage.layers, layerName);
			if (!usedByActivePage) me.destroyLayer(layerName);
		}

		page.layers = nextLayers;
		if (pageIsActive) {
			foreach (var layerName; nextLayers) {
				if (!me.layerListContains(previousLayers, layerName)) me.showLayer(layerName);
			}
		}
		return 1;
	},

	supportSOI: func {
		return me.currPage.supportSOI;
	},

	update: func (noti) {
		me.currPage.update(noti);
		foreach(var layer; me.currPage.layers) {
			var layerInstance = me.fetchLayer(layer);
			if (layerInstance != nil) layerInstance.update(noti);
		}
	},

	selectPage: func (pageName) {
		if (me.pages[pageName] == nil) {print(me.device.name," page not found: ",pageName);return;}
		me.wasSOI = me.device.soi == 1;# The ==1 must be here since soi can be -1 in the device
		if (me["currPage"] != nil) {
			if(me.currPage.needGroup) me.currPage.group.hide();
			me.currPage.exit();
			foreach(var layer; me.currPage.layers) {
				me.hideLayer(layer);
			}
		}
		me.currPage = me.pages[pageName];
		if(me.currPage.needGroup) me.currPage.group.show();
		me.currPage.enter();
		me.device.setPageFrame(me.currPage["showFrame"] != nil and me.currPage.showFrame);
		#me.currPage.update(nil);
		foreach(var layer; me.currPage.layers) {
			me.showLayer(layer);
		}
	},
};

