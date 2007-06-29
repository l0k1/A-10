var a10weapons = props.globals.getNode("sim/model/A-10/weapons");
var arm_sw = props.globals.getNode("sim/model/A-10/weapons/master-arm-switch");
var gr_switch = props.globals.getNode("sim/model/A-10/weapons/gun-rate-switch");
var gun_count = props.globals.getNode("ai/submodels/submodel[1]/count");
var aim9_knob = props.globals.getNode("sim/model/A-10/weapons/dual-AIM-9/aim9-knob");
var gun_ready = props.globals.getNode("sim/model/A-10/weapons/gun/gun-ready");



# gun: trigger and vibration visual effect
# ----------------------------------------
var gau8a_submodel = props.globals.getNode("ai/submodels/submodel[1]");
var remaining_rounds = gau8a_submodel.getNode("count");
var gun_running = props.globals.getNode("ai/submodels/GAU-8A");
var z_pov = props.globals.getNode("/sim/current-view/z-offset-m");
var z_povhold = props.globals.getNode("/sim/current-view/z-offset-m-hold", 1);
var current_v = props.globals.getNode("/sim/current-view/view-number");

z_povhold.setDoubleValue(z_pov.getValue());
controls.trigger = func(b) { b ? fire_gau8a() : cfire_gau8a() }

fire_gau8a = func {
	# FIXME: we need some juice and hyd pressure.
	var gready = gun_ready.getValue();
	var count = remaining_rounds.getValue();
	if ( gready and count > 0 ) {
		gun_running.setBoolValue(1);
		count = remaining_rounds.getValue() * 2;
		setprop("yasim/weights/ammunition-weight-lbs", count);
	}
	var zpov = z_pov.getValue();
	gau8a_vibs(0.002, zpov);
}

gau8a_vibs = func(v, zpov) {
	var grunning = gun_running.getBoolValue();
	var currv = current_v.getValue();
	if ( currv == 0 ) {
		var nv = v + zpov;
		z_pov.setValue( nv );
		if ( grunning ) {
			settimer( func { gau8a_vibs(-v, zpov) }, 0.02);
		} else {
			var zph = z_povhold.getValue();
			z_pov.setValue( zph );
		}
	} else {
		settimer( func { gau8a_vibs(-v, zpov) }, 0.1);
	}
}

cfire_gau8a = func {
	gun_running.setBoolValue(0);
	if ( remaining_rounds.getValue() == 0 ) {
		gun_ready.setValue(0);
	}
}


# station selection
# -----------------
# FIXME: severals station could be selected at the same time, povided they are loaded
# with the same weapon type. For now, use only one at a time.
var stations = props.globals.getNode("sim/model/A-10/weapons/stations");
var stations_list = stations.getChildren("station");


select_station = func {
	var target_idx = arg[0];
	setprop("controls/armament/station-select", target_idx);
	foreach (var station; stations_list) {
		idx = station.getIndex();
		if ( idx == target_idx ) {
			if (station.getNode("selected").getValue() == 1) {
				station.getNode("selected").setBoolValue(0);
			} else {
				station.getNode("selected").setBoolValue(1);
			}
		} else {
			station.getNode("selected").setBoolValue(0);
			station.getNode("ready-0").setBoolValue(0);
			station.getNode("ready-1").setBoolValue(0);
			station.getNode("ready-2").setBoolValue(0);
			station.getNode("error").setBoolValue(0);
		}
	}
}


# station release
# ---------------
var dual_aim9 = a10weapons.getNode("dual-AIM-9");
var aim9_knob = dual_aim9.getNode("aim9-knob");
var rlock =  a10weapons.getNode("release_lock");

setlistener("controls/gear/brake-left", func {
	setprop("sim/model/A-10/weapons/release-switch", cmdarg().getBoolValue());
	release();
	settimer( release_unlock, 2);
});

release = func {
	sel_s = getprop("controls/armament/station-select");
	avail = props.globals.getNode("sim/model/A-10/weapons/stations/station[" ~ sel_s ~ "]/available");
	var arm_volts = props.globals.getNode("systems/electrical/R-AC-volts").getValue();
	var asw = arm_sw.getValue();
	if ( asw == 1 and arm_volts > 24 )	{
		# release aim-9 if station #11 is selected 
		if (( sel_s == 10 ) and ( aim9_knob.getValue() == 2 )) {
			aim9s = props.globals.getNode("sim/model/A-10/weapons/dual-AIM-9", 1).getChildren("aim9");
			foreach (var aim9; aim9s) {
				rlk = rlock.getValue();
				var a = avail.getValue();
				trigger = aim9.getNode("trigger", 1).getBoolValue();
				if ( ! trigger and rlk == 0  and a > 0 ) {
					aim9.getNode("trigger", 1).setBoolValue(1);
					rlock.setValue(1);
					avail.setValue( a - 1 );
				}
			}
		}
	}
}

release_unlock = func {
	# FIXME: a mod-up binding for unlock would be better...
	rlock.setBoolValue(0);
}


# station load
# ------------
station_load = func(s, type) {
	var weight = type.getNode("weight-lb").getValue();
	var desc = type.getNode("description").getValue();
	var avail = type.getNode("available").getValue();
	s.getNode("weight-lb").setValue(weight);
	s.getNode("description").setValue(desc);
	s.getNode("available").setValue(avail);
}
# station unload
# ---------------
station_unload = func(s) {
	# FIXME: we should update the lights on armament panel.
	s.getNode("weight-lb").setValue(0);
	s.getNode("description").setValue("none");
	s.getNode("available").setValue(0);
}


# config dialog
# -------------
var config_dialog = nil;
var stations_change = props.globals.getNode("sim/model/A-10/weapons/stations-change-flag");

setlistener( stations_change, func { update_stations(); });

var update_stations = func {
	var a = nil;
	foreach (s; stations.getChildren("station")) {
		var idx = s.getIndex();
		var weight = 0;
		var desc = s.getNode("description").getValue();
		var type = a10weapons.getNode(desc);
		if ( desc != "none" ) {
			station_load(s, type);
		} else {
			station_unload(s);
		}
	}
}

setlistener("/sim/signals/fdm-initialized", func {
	config_dialog = gui.Dialog.new("/sim/gui/dialogs/A-10/config/dialog",
		"Aircraft/A-10/Dialogs/config.xml");
});


# Armament panel switches
# -----------------------

master_arm_switch = func {
	var input = arg[0];
	var asw = arm_sw.getValue();
	var gcount = gun_count.getValue();
	if ( input == 1 ) {
		if ( asw == -1 ) {
			arm_sw.setValue(0);
		} elsif ( asw == 0 ) {
			arm_sw.setValue(1);
			if ( gr_switch.getValue() == 1 and gcount > 0 ) {
				gun_ready.setValue(1);
			}
		}
	} else {
		if ( asw == 1 ) {
			arm_sw.setValue(0);
			gun_ready.setValue(0);
		} elsif ( asw == 0 ) {
			arm_sw.setValue(-1);
		}
	}
}

gun_rate_switch = func {
	var input = arg[0];
	var grsw = gr_switch.getValue();
	var asw = arm_sw.getValue();
	var gcount = gun_count.getValue();
	if (input == 1) {
		if ( grsw == 0 ) {
			gr_switch.setValue(1);
			if ( asw == 1 and gcount > 0 ) {
				gun_ready.setValue(1);
			}
		}
	} elsif ( grsw == 1 ) {
		gr_switch.setValue(0);
		gun_ready.setValue(0);
	}
}

aim9_knob_switch = func {
	var input = arg[0];
	var a_knob = aim9_knob.getValue();
	if ( input == 1 ) {
		if ( a_knob == 0 ) {
			aim9_knob.setValue(1);
		} elsif ( a_knob == 1 ) {
			aim9_knob.setValue(2);
		}
	} else {
		if ( a_knob == 2 ) {
			aim9_knob.setValue(1);
		} elsif ( a_knob == 1 ) {
			aim9_knob.setValue(0);
		}
	}
}
