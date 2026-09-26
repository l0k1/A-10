# Defines DisplayPageRegistry and DisplayPageSupport for all A-10 display pages.
# The registry maps configured page names to page definitions; the support mixin
# creates page/layer Canvas groups and loads page SVG elements.
# Individual page behavior lives under pages/, while navigation lives in system.nas.

var DisplayPageRegistry = {
	definitions: {},

	reset: func {
		me.definitions = {};
	},

	register: func (page) {
		me.definitions[page.name] = page;
	},

	get: func (name) {
		return me.definitions[name];
	},
};

var DisplayPageSupport = {
	initPageSvg: func (page) {
		var svgCfg = page["svg"];
		if (svgCfg == nil and page["parents"] != nil and size(page.parents) > 0 and page.parents[0]["svg"] != nil) {
			svgCfg = page.parents[0]["svg"];
		}
		if (svgCfg == nil or page["group"] == nil) return;

		var svgFile = svgCfg["file"];
		if (svgFile == nil) return;

		var defaultFont = (svgCfg["font"] != nil) ? svgCfg["font"] : DISPLAY_SVG_DEFAULT_FONT_FILE;
		var localFontMap = (svgCfg["fontMap"] != nil) ? svgCfg["fontMap"] : [];
		var resolveFont = func (fontMap, family, weight) {
			foreach (var entry; fontMap) {
				if (entry == nil) continue;
				var entryFile = entry["file"];
				if (entryFile == nil) continue;
				var entryFamily = entry["family"];
				var entryWeight = entry["weight"];
				var familyOk = (entryFamily == nil) or (entryFamily == family);
				# Accept quoted family names and CSS fallback lists passed by parsesvg.
				if (!familyOk and family != nil and entryFamily != nil) {
					familyOk = find(entryFamily, family) != -1;
				}
				var weightOk = (entryWeight == nil) or (entryWeight == weight);
				if (familyOk and weightOk) return entryFile;
			}
			return nil;
		};
		var font_mapper = func (family, weight) {
			# A page may override a global family without replacing the shared map.
			var mappedFont = resolveFont(localFontMap, family, weight);
			if (mappedFont == nil) mappedFont = resolveFont(DISPLAY_SVG_FONT_MAP, family, weight);
			if (mappedFont != nil) return mappedFont;
			return defaultFont;
		};
		canvas.parsesvg(page.group, svgFile, {"font-mapper": font_mapper});

		var svgKeys = (svgCfg["keys"] != nil) ? svgCfg["keys"] : [];
		var clipFrame = svgCfg["clipFrame"];
		foreach (var key; svgKeys) {
			var target_el = page.group.getElementById(key);
			page[key] = target_el;
			if (target_el == nil) continue;

			var clip_el = page.group.getElementById(key ~ "_clip");
			if (clip_el == nil) continue;

			clip_el.setVisible(0);
			var tranRect = clip_el.getTransformedBounds();
			if (tranRect == nil or size(tranRect) < 4) continue;

			var clip_rect = sprintf(
				"rect(%d, %d, %d, %d)",
				tranRect[1],
				tranRect[2],
				tranRect[3],
				tranRect[0]
			);
			target_el.set("clip", clip_rect);
			if (clipFrame != nil) target_el.set("clip-frame", clipFrame);
		}
	},

	initPage: func (page) {
		printDebug(me.name," init page ",page.name);
		if (page.needGroup) {
			me.tempGrp = me.canvas.createGroup()
							.set("z-index", zIndex.device.page)
							.set("font", DISPLAY_FONT_FILE)
							.hide();
			page.group = me.tempGrp;
		}
		page.device = me;
		me.initPageSvg(page);
	},

	initLayer: func (layer) {
		printDebug(me.name," init layer ",layer.name);
		me.tempGrp = me.canvas.createGroup()
						.set("z-index", layer["zIndex"] != nil ? layer.zIndex : zIndex.device.layer)
						.set("font", DISPLAY_FONT_FILE)
						.hide();
		layer.group = me.tempGrp;
		layer.device = me;
		# Layers use the same declarative SVG configuration as pages. Parse the
		# artwork and resolve configured element keys before layer setup uses them.
		me.initPageSvg(layer);
		layer.setup();
	},
};

