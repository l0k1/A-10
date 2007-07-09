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
	# FIXME: we need juice and hyd pressure.
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
# Selects one or several stations. Each has to be loaded with the same type of
# ordnance. Selecting a new station loaded with a different type deselects the
# former ones. Selecting  an allready selected station deselect it.
# Activates the search sound flag for AIM-9s (wich will be played only if the AIM-9
# knob is on the correct position). Ask for deactivation of the search sound flag
# in case of station deselection.
var stations = props.globals.getNode("sim/model/A-10/weapons/stations");
var stations_list = stations.getChildren("station");
var aim9_knob = a10weapons.getNode("dual-AIM-9/aim9-knob");
var aim9_sound = a10weapons.getNode("dual-AIM-9/search-sound");
var cdesc = "";

select_station = func {
	var target_idx = arg[0];
	setprop("controls/armament/station-select", target_idx);
	var desc_node = "sim/model/A-10/weapons/stations/station[" ~ target_idx ~ "]/description";
	cdesc = props.globals.getNode(desc_node).getValue();
	var sel_list = props.globals.getNode("sim/model/A-10/weapons/selected-stations");
	foreach (var s; stations_list) {
		idx = s.getIndex();
		var sdesc = s.getNode("description").getValue();
		var ssel = s.getNode("selected");
		var tsnode = "s" ~ idx;
		if ( idx == target_idx ) {
			if (ssel.getBoolValue()) {
				ssel.setBoolValue(0);
				sel_list.removeChildren(tsnode);
				if ( sdesc == "dual-AIM-9" ) {
					deactivate_aim9_sound();
				}
			} else {
				ssel.setBoolValue(1);
				var ts = sel_list.getNode(tsnode, 1);
				ts.setValue(target_idx);
				if ( sdesc == "dual-AIM-9") {
					aim9_sound.setBoolValue(1);
				}
			}
		} elsif ( cdesc != sdesc ) {
			ssel.setBoolValue(0);
			sel_list.removeChildren(tsnode);
			if ( sdesc == "dual-AIM-9" ) {
				deactivate_aim9_sound();
			}
		}
	}
}


# station release
# ---------------
# Handles ripples and intervales.
# Handles the avaibality lights (3 green lights each station).
# LAU-68, with 7 ammos by station turns only one light until the dispenser is empty.
# Releases and substract the released weight from the station weight.
# Ask for deactivation of the search sound flag after the last AIM-9 has been released.
var sl_list = 0;

release = func {
	var arm_volts = props.globals.getNode("systems/electrical/R-AC-volts").getValue();
	var asw = arm_sw.getValue();
	if ( asw != 1 or arm_volts < 24 )	{ return; }
	sl_list = a10weapons.getNode("selected-stations").getChildren();
	var rip = a10weapons.getNode("rip").getValue();
	var interval = a10weapons.getNode("interval").getValue();
	# FIXME: riple compatible release types should be defined in the foo-set.file 
	if ( cdesc == "LAU-68") {
		var rip_counter = rip;
		release_operate(rip_counter, interval);
	} else {
		release_operate(1, interval);
	}
}

release_operate = func(rip_counter, interval) {
	foreach(sl; sl_list) {
		var slidx = sl.getValue();
		var s_node = "sim/model/A-10/weapons/stations/station[" ~ slidx ~ "]";		
		var s = props.globals.getNode(s_node);
		var wght = s.getNode("weight-lb").getValue();
		var awght = s.getNode("ammo-weight-lb").getValue();
		if ( cdesc == "LAU-68" ) { var lau68ready = s.getNode("ready-0"); } 
		var avail = s.getNode("available");
		var a = avail.getValue();
		if ( a != 0 ) {
			if ( cdesc == "dual-AIM-9"  and aim9_knob.getValue() != 2 ) { return; }
			turns = a10weapons.getNode(cdesc).getNode("available").getValue();
			for( i = 0; i <= turns; i = i + 1 ) {
				var it = cdesc ~ "/trigger[" ~ i ~"]";
				var itrigger = s.getNode(it);
				var iready_node = "ready-" ~ i;
				var a = avail.getValue();
				if ( cdesc != "LAU-68" ) { var iready = s.getNode(iready_node); }
				var t = itrigger.getBoolValue();
				if ( !t and a > 0) {
					itrigger.setBoolValue(1);
					a -= 1;
					avail.setValue(a);
					rip_counter -= 1;
					wght -= awght;
					s.getNode("weight-lb").setValue(wght);
					if ( cdesc != "LAU-68" ) { iready.setBoolValue(0); }
					if ( a == 0 ) {
						if ( cdesc == "LAU-68" ) {
							lau68ready.setBoolValue(0);
						} elsif ( cdesc == "dual-AIM-9" ) {
							deactivate_aim9_sound();
						}
						s.getNode("error").setBoolValue(1);
					}
					if (rip_counter > 0 ) {
						settimer( func { release_operate(rip_counter, interval); }, interval);
					}
					return;
				}
			}
		}
	}
}


# Searchs if there isn't a remainning AIM-9 on a selected station before
# deactivating the search sound flag.
deactivate_aim9_sound = func {
	aim9_sound.setBoolValue(0);
	var a = 0;
	foreach (s; stations.getChildren("station")) {
		var ssel = s.getNode("selected").getBoolValue();
		var desc = s.getNode("description").getValue();
		var avail = s.getNode("available");
		if ( ssel and desc == "dual-AIM-9"  ) {
			a += avail.getValue();
		}
		if ( a ) {
			aim9_sound.setBoolValue(1);
		}
	}
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


# station load
# ------------
# Sets the station properties from the type definition in the current station.
# Prepares the error light or the 3 ready lights, then sets to false the
# necessary number of triggers (useful in the case of the submodels weren't
# already defined). Each type of submodel has its own node inside each station
# node containing the triggers.
station_load = func(s, type) {
	var weight = type.getNode("weight-lb").getValue();
	var ammo_weight = type.getNode("ammo-weight-lb").getValue();
	var desc = type.getNode("description").getValue();
	var avail = type.getNode("available").getValue();
	var readyn = type.getNode("ready-number").getValue();
	s.getNode("weight-lb").setValue(weight);
	s.getNode("ammo-weight-lb").setValue(ammo_weight);
	s.getNode("description").setValue(desc);
	s.getNode("available").setValue(avail);
	if ( readyn == 0 ) {
		# non-armable payload case. (ECM pod, external tank...)
		s.getNode("error").setBoolValue(1);
		return;
	} else {
		s.getNode("error").setBoolValue(0);
	}
	if ( readyn == 1 ) {
		# single ordnance case.
		s.getNode("ready-0").setBoolValue(1);
	} elsif( readyn == 2 ) {
		# double ordnance case
		s.getNode("ready-0").setBoolValue(1);
		s.getNode("ready-1").setBoolValue(1);
	} else {
		# triple ordnance case
		s.getNode("ready-0").setBoolValue(1);
		s.getNode("ready-1").setBoolValue(1);
		s.getNode("ready-2").setBoolValue(1);
	} 
	for( i = 0; i < avail; i = i + 1 ) {
		# FIXME: here to add submodels reload
		itrigger_node = desc ~ "/trigger[" ~ i ~ "]";
		t = s.getNode(itrigger_node, 1);
		t.setBoolValue(0);
	}
}


# station unload
# --------------
station_unload = func(s) {
	s.getNode("weight-lb").setValue(0);
	s.getNode("ammo-weight-lb").setValue(0);
	desc = s.getNode("description").getValue();
	s.getNode("description").setValue("none");
	s.getNode("available").setValue(0);
	s.getNode("ready-0").setBoolValue(0);
	s.getNode("ready-1").setBoolValue(0);
	s.getNode("ready-2").setBoolValue(0);
	s.getNode("error").setBoolValue(1);
}


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
