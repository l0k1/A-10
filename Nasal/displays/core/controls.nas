# Defines DisplayControls, the general-purpose A-10 display control mixin used by DisplayDevice.
# It owns OSB creation, labels, press feedback, reset behavior, and control listeners.
# This is shared display infrastructure, not code for any individual page.

var DisplayControls = {
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
								.set("font", DISPLAY_FONT_FILE);
		}
		me.controls.master.setControlText = func (text, positive = 1, outline = 0, vertical = 0, showFill = nil, padding = nil) {
			if (showFill == nil) showFill = DISPLAY_CONTROL_LABEL_FILL_DEFAULT;

			# store for later SWAP option
			me.contentText = text;
			me.contentPositive = positive;
			me.contentOutline = outline;
			me.contentShowFill = showFill;
			me.contentPadding = padding;

			if (me["lettersAux"] != nil) {
				foreach (var aux; me.lettersAux) {
					if (aux != nil) aux.del();
				}
				me.lettersAux = nil;
			}

			if (text == nil or text == "") {
				me.letters.setVisible(0);
				me.letters.setDrawMode(canvas.Text.TEXT);
				me.outline.setVisible(0);
				me.fill.setVisible(0);
				return;
			}

			me.useWordColumns = 0;
			me.renderText = text;
			me.letters.setVisible(1);
			me.letters.setDrawMode(canvas.Text.TEXT);
			me.boxTextColor = positive ? me.device.colorFront : me.device.colorBack;
			me.boxFillColor = positive ? me.device.colorBack : me.device.colorFront;
			me.textPadding = margin.device.outline;
			me.labelX = (me["labelPos"] != nil) ? me.labelPos[0] : 0;
			me.labelY = (me["labelPos"] != nil) ? me.labelPos[1] : 0;
			me.labelAlignment = (me["labelAlign"] != nil) ? me.labelAlign : "center-center";
			me.glyphWidth = 0.7 * font.device.osbLabels;
			me.glyphHeight = 0.9 * font.device.osbLabels;
			me.bounds = nil;

			var includeBounds = func(bounds, nextBounds) {
				if (bounds == nil) return nextBounds;
				return [
					math.min(bounds[0], nextBounds[0]),
					math.min(bounds[1], nextBounds[1]),
					math.max(bounds[2], nextBounds[2]),
					math.max(bounds[3], nextBounds[3])
				];
			};

			var textBounds = func(node) {
				node.update();
				var bounds = node.getTransformedBounds();
				return [bounds[0], bounds[1], bounds[2], bounds[3]];
			};

			var redrawBox = func(path, bounds, pad, color, fill = nil) {
				path.reset();
				path.setTranslation(0, 0);
				path.rect(
					bounds[0] - pad,
					bounds[1] - pad,
					bounds[2] - bounds[0] + pad * 2,
					bounds[3] - bounds[1] + pad * 2
				);
				path.setColor(color);
				path.setStrokeLineWidth(lineWidth.device.outline);
				if (fill != nil) path.setColorFill(fill);
			};

			if (vertical) {
				me.words = [];
				foreach (var rawLine; split("\n", text)) {
					foreach (var candidate; split(" ", rawLine)) {
						if (size(candidate) > 0) append(me.words, candidate);
					}
				}

				if (size(me.words) > 1) {
					me.useWordColumns = 1;
					me.maxWordLen = 0;
					foreach (var word; me.words) {
						me.maxWordLen = math.max(me.maxWordLen, size(word));
					}

					me.letters.setVisible(0);
					me.lettersAux = [];
					me.colStep = 0.7 * font.device.osbLabels;
					me.centerShift = (size(me.words) - 1) * 0.5;

					for (var col = 0; col < size(me.words); col += 1) {
						var wordIndex = col;
						if (find("right-", me.labelAlignment) == 0) wordIndex = size(me.words) - 1 - col;
						var word = me.words[wordIndex];

						var wordText = "";
						for (var i = 0; i < size(word); i += 1) {
							var ch = substr(word, i, 1);
							wordText ~= ch;
							if (i < size(word) - 1) wordText ~= "\n";
						}

						var colAlign = "center-center";
						var colX = me.labelX + (col - me.centerShift) * me.colStep;
						var colY = me.labelY;
						var yCenterOffset = (me.maxWordLen - size(word)) * 0.5 * me.glyphHeight;
						if (find("left-", me.labelAlignment) == 0) {
							colAlign = "left-center";
							colX = me.labelX + col * me.colStep;
						} elsif (find("right-", me.labelAlignment) == 0) {
							colAlign = "right-center";
							colX = me.labelX - col * me.colStep;
						} elsif (find("-top", me.labelAlignment) != -1) {
							colAlign = "center-top";
							colY = me.labelY + yCenterOffset;
						} elsif (find("-bottom", me.labelAlignment) != -1) {
							colAlign = "center-bottom";
							colY = me.labelY - yCenterOffset;
						}

						var wordNode = me.device.controlGrp.createChild("text")
							.set("z-index", zIndex.deviceObs.text)
							.setAlignment(colAlign)
							.setTranslation(colX, colY)
							.setFontSize(font.device.osbLabels, 1.0)
							.setDrawMode(canvas.Text.TEXT)
							.setText(wordText)
							.setColor(me.boxTextColor);
						append(me.lettersAux, wordNode);
						me.bounds = includeBounds(me.bounds, textBounds(wordNode));
					}

					me.lettersCount = math.max(1, size(me.words));
					me.linebreak = math.max(1, me.maxWordLen);
				} else {
					var source = size(me.words) == 1 ? me.words[0] : text;
					me.renderText = "";
					for (var i = 0; i < size(source); i += 1) {
						var ch = substr(source, i, 1);
						me.renderText ~= ch;
						if (i < size(source) - 1 and ch != "\n") me.renderText ~= "\n";
					}
				}
			}

			if (!me.useWordColumns) {
				me.letters.setText(me.renderText);
				me.letters.setColor(me.boxTextColor);
				me.letters.setDrawMode(canvas.Text.TEXT);
				me.split = split("\n", me.renderText);
				me.linebreak = math.max(1, size(me.split));
				me.lettersCount = 1;
				foreach (var line; me.split) {
					me.lettersCount = math.max(me.lettersCount, size(line));
				}
				me.bounds = textBounds(me.letters);
			}

			if (outline or showFill) {
				redrawBox(me.outline, me.bounds, me.textPadding, me.boxTextColor);
				redrawBox(me.fill, me.bounds, me.textPadding, me.boxFillColor, me.boxFillColor);
			}

			me.outline.setVisible(outline);
			me.fill.setVisible(showFill);
		};
		append(me.listeners, setlistener(property, me[prefix],0,0));
	},

	resetControls: func {
		me.tempKeys = keys(me.controls);
		foreach(var key; me.tempKeys) {
			if (me.controls[key]["parents"]!= nil) me.controls[key].setControlText("");
		}
	},

	addControlText: func (prefix, controlName, pos, posIndex, alignmentH=0, alignmentV=0) {
		me.tempX = me.controlPositions[prefix][posIndex][0]+pos[0];
		me.tempY = me.controlPositions[prefix][posIndex][1]+pos[1];

		me.alignment  = alignmentH==0?"center-":(alignmentH==-1?"left-":"right-");
		me.alignment ~= alignmentV==0?"center":(alignmentV==-1?"top":"bottom");
		me.letterWidth  = 0.7 * font.device.osbLabels;
		me.letterHeight = 0.9 * font.device.osbLabels;
		me.myCenter = [me.tempX, me.tempY];

		# Canvas font metrics on top/bottom anchors sit slightly low/high vs the
		# outline box, so apply a small visual centering bias per edge.
		me.textYOffset = 0;
		if (alignmentV == 1) me.textYOffset = -0.12 * me.letterHeight;
		elsif (alignmentV == -1) me.textYOffset = 0.08 * me.letterHeight;
		me.textY = me.tempY + me.textYOffset;

		me.controls[controlName].labelPos = [me.tempX, me.textY];
		me.controls[controlName].labelAlign = me.alignment;
		me.controls[controlName].letters = me.controlGrp.createChild("text")
				.set("z-index", zIndex.deviceObs.text)
				.setAlignment(me.alignment)
				.setTranslation(me.tempX, me.textY)
				.setFontSize(font.device.osbLabels, 1.0)
				.setText(right(controlName,4))
				.setColor(me.colorFront);
		me.controls[controlName].outline = me.controlGrp.createChild("path")
				.moveTo(me.tempX-me.letterWidth*2*alignmentH-me.letterWidth*2-me.myCenter[0]-margin.device.outline, me.textY-me.letterHeight*0.85-margin.device.outline-me.myCenter[1])
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
				.moveTo(me.tempX-me.letterWidth*2*alignmentH-me.letterWidth*2-me.myCenter[0], me.textY-me.letterHeight*0.5-margin.device.fillHeight-me.myCenter[1])
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

    addControlFeedback: func {
		me.feedbackRadius = margin.device.feedbackRadius;
    	me.cntlFeedback = me.controlGrp.createChild("path")
	            .moveTo(-me.feedbackRadius,0)
	            .arcSmallCW(me.feedbackRadius,me.feedbackRadius, 0,  me.feedbackRadius*2, 0)
	            .arcSmallCW(me.feedbackRadius,me.feedbackRadius, 0, -me.feedbackRadius*2, 0)
	            .close()
	            .setStrokeLineWidth(lineWidth.device.feedback)
	            .set("z-index",zIndex.deviceObs.feedback)
	            .setColor(colorDot2[0],colorDot2[1],colorDot2[2],0.15)
	            .setColorFill(colorDot2[0],colorDot2[1],colorDot2[2],0.3)
	            .hide();
    },
};
