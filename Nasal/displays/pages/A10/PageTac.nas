var PageTac = {
		name: "PageTac",
		isNew: 1,
		supportSOI: 0,
		needGroup: 1,
		showFrame: 1,
		new: func {
			me.instance = {parents:[PageTac]};
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
	        me.attrProvider = nil;
	        me.attrSince = 0;
	        # Fixed to the display, above the bottom OSBs and clear of the ownship.
	        # Hide the backing and text together; keep both above the map overlays.
	        me.attrGroup = me.group.createChild("group")
	            .set("z-index",zIndex.tad.attribution)
	            .setTranslation(me.max_x*0.5,me.max_y*0.84)
	            .hide();
	        me.attrGroup.createChild("path")
	            .set("z-index",0)
	            .moveTo(-me.max_x*0.45,-84)
	            .horiz(me.max_x*0.9)
	            .vert(168)
	            .horiz(-me.max_x*0.9)
	            .close()
	            .setColorFill(me.device.colorBack)
	            .setStrokeLineWidth(0);
	        me.attrText = me.attrGroup.createChild("text")
	            .set("z-index",1)
	            .setColor(me.device.colorFront)
	            .setFontSize(font.device.osbLabels*0.9, 1.1)
	            .set("line-height",1.3)
	            .setText("")
	            .setAlignment("center-center")
	            .setFont("A10-HUD.ttf");
	    },

	    updateAttr: func {
	        var provider = zoom_provider[zoom_curr];
	        var now = me.input.timeElapsed.getValue();
	        # Credit on selection/page entry, not only at a global eight-minute tick.
	        # Range changes within the same provider do not restart the notice.
	        if (me.attrProvider != provider or now < me.attrSince) {
	            me.attrProvider = provider;
	            me.attrSince = now;
	        }
	        var credit = providers[provider].attribution;
	        var elapsed = now - me.attrSince;
	        me.attrText.setText(credit);
	        me.attrGroup.setVisible(credit != "" and
	            (elapsed < 8 or math.fmod(elapsed, 480) < 4));
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
	        if(providers[providerOptions[providerOption][zoom_curr]]["min"] != nil) {
	            while(zooms[zoom_curr] < providers[providerOptions[providerOption][zoom_curr]]["min"]) {
	                zoom_curr += 1;
	            }
	        }
	        zoom = zooms[zoom_curr];
	        tile_zoom = zoom;
	        if(providers[providerOptions[providerOption][zoom_curr]]["max"] != nil and tile_zoom > providers[providerOptions[providerOption][zoom_curr]]["max"]) {
	            tile_zoom = providers[providerOptions[providerOption][zoom_curr]]["max"];
	        }
	        tile_scale = math.pow(2, zoom - tile_zoom);
	        M2TEX = 1/(meterPerPixel[zoom]*math.cos(getprop('/position/latitude-deg')*D2R));
	        me.setRangeInfo();
	    },

	    toggleMap: func {
	        providerOption += 1;
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
	        me.mapFinal.setScale(tile_scale);
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

	        me.n = math.pow(2, tile_zoom);
	        me.center_tile_float = [
	            me.n * ((me.lon + 180) / 360),
	            (1 - math.ln(math.tan(me.lat * D2R) + 1 / math.cos(me.lat * D2R)) / math.pi) / 2 * me.n
	        ];
	        # center_tile_offset[1]
	        me.center_tile_int = [math.floor(me.center_tile_float[0]), math.floor(me.center_tile_float[1])];

	        me.center_tile_fraction_x = me.center_tile_float[0] - me.center_tile_int[0];
	        me.center_tile_fraction_y = me.center_tile_float[1] - me.center_tile_int[1];
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

	        for(var xxx = 0; xxx < num_tiles[0]; xxx += 1) {
	            for(var yyy = 0; yyy < num_tiles[1]; yyy += 1) {
	                tiles[xxx][yyy].setTranslation(-math.floor((me.center_tile_fraction_x - xxx+me.tile_offset[0]) * tile_size), -math.floor((me.center_tile_fraction_y - yyy+me.tile_offset[1]) * tile_size));
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
	                        z: tile_zoom,
	                        x: xx,
	                        y: me.center_tile_int[1] + y - me.tile_offset[1],
	                        type: type
	                    };

	                    (func {# generator function
	                        var img_path = makePath(pos);
	                        var tile = tiles[x][y];
	                        if( io.stat(img_path) == nil and me.liveMap == 1) { # image not found, save in $FG_HOME
	                            var img_url = makeUrl(pos);
	                            http.save(img_url, img_path)
	                                .done(func(r) {
	                                    tile.set("src", img_path);
	                                    tile.update();
	                                    })
	                              .fail(func (r) {logprint(LOG_INFO, 'Failed to get image ' ~ img_path ~ ' ' ~ r.status ~ ': ' ~ r.reason);
	                                            tile.set("src", "Aircraft/A-10/Nasal/displays/emptyTile.png");
	                                            tile.update();
	                                            });
	                        } elsif (io.stat(img_path) != nil) {# cached image found, reusing
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
			me.attrProvider = nil;
			me.updateAttr();
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
};
