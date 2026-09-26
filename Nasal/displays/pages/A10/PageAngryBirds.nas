var PageAngryBirds = {
		name: "PageAngryBirds",
		isNew: 1,
		supportSOI: 0,
		needGroup: 1,
		showFrame: 0,
		new: func {
			var page = {parents:[PageAngryBirds]};
			page.group = nil;
			return page;
		},
		circle: func (parent, x, y, radius, color) {
			return parent.createChild("path")
				.moveTo(-radius, 0)
				.arcSmallCW(radius, radius, 0, radius*2, 0)
				.arcSmallCW(radius, radius, 0, -radius*2, 0)
				.close()
				.setColorFill(color)
				.setStrokeLineWidth(2)
				.setColor([0.12, 0.12, 0.12])
				.setTranslation(x, y);
		},
		label: func (parent, x, y, size, value, color) {
			return parent.createChild("text")
				.setAlignment("center-center")
				.setTranslation(x, y)
				.setFontSize(size)
				.setColor(color)
				.setText(value);
		},
		setup: func {
			# Use the supplied loading image unchanged for the two-second splash.
			me.splash = me.group.createChild("group");
			me.splash.createChild("image")
				.setFile("Aircraft/A-10/Nasal/displays/angry-birds-loading.png")
				.setTranslation(0, 170)
				.setSize(1024, 683);
			me.game = me.group.createChild("group");
			me.game.createChild("path")
				.moveTo(0, 0).lineTo(1024, 0).lineTo(1024, 1024)
				.lineTo(0, 1024).close()
				.setColorFill([0.30, 0.72, 0.88]);
			me.game.createChild("path")
				.moveTo(0, 865).lineTo(1024, 865).lineTo(1024, 1024)
				.lineTo(0, 1024).close()
				.setColorFill([0.37, 0.68, 0.22]);
			me.title = me.label(me.game, 512, 90, 32, "ANGRY BIRDS: A-10 EDITION", [1, 1, 1]);
			me.status = me.label(me.game, 512, 170, 27, "AIM, SET PULL, THEN FIRE", [1, 1, 1]);
			me.scoreText = me.label(me.game, 512, 820, 28, "PIGS: 0/3", [1, 1, 1]);
			# The launch point moves back from the rail as the sling is pulled.
			me.game.createChild("path")
				.moveTo(180, 225).lineTo(180, 805)
				.setStrokeLineWidth(7).setColor([0.36, 0.21, 0.11]);
			me.slingBand = me.game.createChild("path")
				.setStrokeLineWidth(5).setColor([0.42, 0.22, 0.10]);
			me.trajectory = me.game.createChild("group");
			me.trajectoryDots = [];
			for (var i = 0; i < 24; i += 1) {
				append(me.trajectoryDots,
					me.circle(me.trajectory, 0, 0, 4, [1, 1, 1]));
			}
			me.bird = me.game.createChild("group");
			me.circle(me.bird, 0, 0, 59, [0.91, 0.09, 0.08]);
			me.circle(me.bird, 20, -14, 15, [1, 1, 1]);
			me.circle(me.bird, 25, -12, 6, [0.04, 0.04, 0.04]);
			me.bird.createChild("path")
				.moveTo(42, 4).lineTo(88, 20).lineTo(41, 37).close()
				.setColorFill([1, 0.70, 0.05]);
			me.pigs = [];
			me.pigY = [300, 515, 730];
			for (var i = 0; i < 3; i += 1) {
				var pig = me.game.createChild("group").setTranslation(790, me.pigY[i]);
				me.circle(pig, 0, 0, 65, [0.40, 0.85, 0.17]);
				me.circle(pig, -22, -16, 12, [1, 1, 1]);
				me.circle(pig, 22, -16, 12, [1, 1, 1]);
				me.circle(pig, -20, -16, 5, [0, 0, 0]);
				me.circle(pig, 24, -16, 5, [0, 0, 0]);
				me.circle(pig, 0, 18, 27, [0.52, 0.92, 0.29]);
				append(me.pigs, pig);
			}
		},
		refreshAim: func {
			me.launchX = 180 - 15*me.pull;
			me.bird.setTranslation(me.launchX, me.birdY);
			me.slingBand.reset()
				.moveTo(180, me.birdY-22)
				.lineTo(me.launchX, me.birdY)
				.lineTo(180, me.birdY+22);
			var vx = 10 + 4*me.pull;
			var vy = -(5 + 2*me.pull);
			for (var i = 0; i < size(me.trajectoryDots); i += 1) {
				var t = (i+1)*2;
				var x = me.launchX + vx*t;
				var y = me.birdY + vy*t + 0.55*t*(t-1)/2;
				me.trajectoryDots[i].setTranslation(x, y);
				me.trajectoryDots[i].setVisible(x < 960 and y > 210 and y < 850);
			}
			if (me.ready) me.device.controls["OSB23"].setControlText(me.pull ~ "/5");
		},
		resetGame: func {
			me.birdY = 515;
			me.pull = 3;
			me.shotX = 0;
			me.shotY = me.birdY;
			me.firing = 0;
			me.score = 0;
			foreach (var pig; me.pigs) pig.show();
			me.slingBand.show();
			me.trajectory.show();
			me.refreshAim();
			me.status.setText("AIM, SET PULL, THEN FIRE");
			me.scoreText.setText("PIGS: 0/3");
		},
		enter: func {
			if (me.isNew) {
				me.setup();
				me.isNew = 0;
			}
			me.device.resetControls();
			me.device.soiLine.hide();
			me.splash.show();
			me.game.hide();
			me.ready = 0;
			me.resetGame();
			me.startTime = systime();
			me.timer = maketimer(0.05, me, me.tick);
			me.timer.start();
		},
		tick: func {
			if (!me.ready) {
				if (systime() - me.startTime < 2) return;
				me.ready = 1;
				me.splash.hide();
				me.game.show();
				# Text created before the hidden game group is shown can miss its first
				# Canvas redraw. Refresh it on the visible frame.
				me.title.setText("ANGRY BIRDS: A-10 EDITION");
				me.status.setText("AIM, SET PULL, THEN FIRE");
				me.scoreText.setText("PIGS: 0/3");
				me.device.controls["OSB3"].setControlText("UP");
				me.device.controls["OSB5"].setControlText("DOWN");
				me.device.controls["OSB10"].setControlText("FIRE");
				me.device.controls["OSB22"].setControlText("LESS");
				me.device.controls["OSB23"].setControlText(me.pull ~ "/5");
				me.device.controls["OSB24"].setControlText("MORE");
				me.device.controls["OSB26"].setControlText("EXIT");
				me.game.update();
				me.device.controlGrp.update();
				me.refreshUntil = systime() + 0.5;
				return;
			}
			if (systime() < me.refreshUntil) {
				me.game.update();
				me.device.controlGrp.update();
			}
			if (!me.firing) return;
			me.shotX += me.shotVx;
			me.shotY += me.shotVy;
			me.shotVy += 0.55;
			me.bird.setTranslation(me.shotX, me.shotY);
			for (var i = 0; i < 3; i += 1) {
				var dx = me.shotX - 790;
				var dy = me.shotY - me.pigY[i];
				if (me.pigs[i].getVisible() and dx*dx + dy*dy < 90*90) {
					me.pigs[i].hide();
					me.score += 1;
					me.hitThisShot = 1;
					me.scoreText.setText("PIGS: " ~ me.score ~ "/3");
					me.status.setText(me.score == 3 ? "ALL PIGS DOWN!" : "DIRECT HIT!");
					break;
				}
			}
			if (me.hitThisShot or me.shotX >= 1024 or me.shotY >= 865) {
				me.firing = 0;
				me.slingBand.show();
				me.trajectory.show();
				me.refreshAim();
				if (!me.hitThisShot) me.status.setText("MISS! CHANGE AIM OR PULL");
			}
		},
		controlAction: func (controlName) {
			if (!me.ready) return;
			if (controlName == "OSB26") {
				me.device.system.selectPage("PageSADLBase");
			} elsif (controlName == "OSB3" and !me.firing) {
				me.birdY = math.max(250, me.birdY - 35);
				me.refreshAim();
			} elsif (controlName == "OSB5" and !me.firing) {
				me.birdY = math.min(780, me.birdY + 35);
				me.refreshAim();
			} elsif (controlName == "OSB22" and !me.firing) {
				me.pull = math.max(1, me.pull - 1);
				me.refreshAim();
			} elsif (controlName == "OSB24" and !me.firing) {
				me.pull = math.min(5, me.pull + 1);
				me.refreshAim();
			} elsif (controlName == "OSB10" and !me.firing) {
				if (me.score == 3) me.resetGame();
				me.firing = 1;
				me.hitThisShot = 0;
				me.shotX = me.launchX;
				me.shotY = me.birdY;
				me.shotVx = 10 + 4*me.pull;
				me.shotVy = -(5 + 2*me.pull);
				me.slingBand.hide();
				me.trajectory.hide();
				me.status.setText("FIRING!");
			}
		},
		update: func (noti = nil) {},
		exit: func {
			me.timer.stop();
			me.device.soiLine.show();
		},
		links: {},
		layers: [],
};
