# this is temporary and not using emesary
# This is from F-16
var pylon = 0;
var loop = func {
	if (!getprop("sim/replay/replay-state")) {
		pylon += 1;
		if (pylon == 12) { #A-10 max pylon ID is 11 so when iteration 12 runs reset to 0
			pylon = 0;
		}
		var type = getprop("payload/armament/station/id-"~pylon~"-type") or "";
		var count = getprop("payload/armament/station/id-"~pylon~"-count") or 0;
		var set = getprop("payload/armament/station/id-"~pylon~"-set");
		setprop("sim/multiplay/generic/string[5]", sprintf("%02d--%s++%02d--%s",pylon,type,count,set));
	}
	settimer(loop, 0.25);
}