var a10weapons = props.globals.getNode("sim/model/A-10/weapons");

# switches ---------------------------------------------------------------------
master_arm_switch = func {
	input = arg[0];
	if (input == 1) {
		if (getprop("sim/model/A-10/weapons/master-arm-switch") == -1) {
			setprop("sim/model/A-10/weapons/master-arm-switch", 0);
		} elsif (getprop("sim/model/A-10/weapons/master-arm-switch") == 0) {
			setprop("sim/model/A-10/weapons/master-arm-switch", 1);
			if (getprop("sim/model/A-10/weapons/gun-rate-switch") == 1) {
				if (getprop("ai/submodels/submodel[1]/count") > 0) {
					setprop("sim/model/A-10/weapons/gun/gun-ready", 1);
				}
			}
		}
	} else {
		if (getprop("sim/model/A-10/weapons/master-arm-switch") == 1) {
			setprop("sim/model/A-10/weapons/master-arm-switch", 0);
			setprop("sim/model/A-10/weapons/gun/gun-ready", 0);
		} elsif (getprop("sim/model/A-10/weapons/master-arm-switch") == 0) {
			setprop("sim/model/A-10/weapons/master-arm-switch", -1);
		}
	}
}

gun_rate_switch = func {
	input = arg[0];
	if (input == 1) {
		if (getprop("sim/model/A-10/weapons/gun-rate-switch") == 0) {
			setprop("sim/model/A-10/weapons/gun-rate-switch", 1);
			if (getprop("sim/model/A-10/weapons/master-arm-switch") == 1){
				if (getprop("ai/submodels/submodel[1]/count") > 0) {
					setprop("sim/model/A-10/weapons/gun/gun-ready", 1);
				}
			}
		}
	} elsif (getprop("sim/model/A-10/weapons/gun-rate-switch") == 1) {
		setprop("sim/model/A-10/weapons/gun-rate-switch", 0);
		setprop("sim/model/A-10/weapons/gun/gun-ready", 0);
	}
}

aim9_knob = func {
	input = arg[0];
	if (input == 1) {
		if (getprop("sim/model/A-10/weapons/aim9s/aim9-knob") == 0) {
			setprop("sim/model/A-10/weapons/aim9s/aim9-knob", 1);
		} elsif (getprop("sim/model/A-10/weapons/aim9s/aim9-knob") == 1) {
			setprop("sim/model/A-10/weapons/aim9s/aim9-knob", 2);
		}
	} else {
		if (getprop("sim/model/A-10/weapons/aim9s/aim9-knob") == 2) {
			setprop("sim/model/A-10/weapons/aim9s/aim9-knob", 1);
		} elsif (getprop("sim/model/A-10/weapons/aim9s/aim9-knob") == 1) {
			setprop("sim/model/A-10/weapons/aim9s/aim9-knob", 0);
		}
	}
}


# gun
# ---
#  trigger and vibration visual effect
var gun_ready = a10weapons.getNode("gun/gun-ready");
var gau8a_submodel = props.globals.getNode("ai/submodels/submodel[1]");
var remaining_rounds = gau8a_submodel.getNode("count");
var gun_running = props.globals.getNode("ai/submodels/GAU-8A");
var z_pov = props.globals.getNode("/sim/current-view/z-offset-m");
var z_povhold = props.globals.getNode("/sim/current-view/z-offset-m-hold", 1);
var current_v = props.globals.getNode("/sim/current-view/view-number");

z_povhold.setDoubleValue(z_pov.getValue());
controls.trigger = func(b) { b ? fire_gau8a() : cfire_gau8a() }

fire_gau8a = func {
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



# release ----------------------------------------------------------------------

setlistener("controls/gear/brake-left", func {
	setprop("sim/model/A-10/weapons/release-switch", cmdarg().getBoolValue());
	release();
	settimer( release_unlock, 2);
});

# for a begining, just release aim-9 if station #11 is selected 
release = func {
	if ((getprop("sim/model/A-10/weapons/master-arm-switch") == 1)
	and (getprop("systems/electrical/R-AC-volts")) > 24 )	{
		selected_station = getprop("controls/armament/station-select");
		if ((selected_station == 10)
		and (getprop("sim/model/A-10/weapons/aim9s/aim9-knob") == 2)) {
			aim9s = props.globals.getNode("sim/model/A-10/weapons/aim9s", 1).getChildren("aim9");
			foreach (var aim9; aim9s) {
				trigger = aim9.getNode("trigger", 1).getBoolValue();
				if (( ! trigger )
				and (getprop("sim/model/A-10/weapons/release_lock") == 0)) {
					aim9.getNode("trigger", 1).setBoolValue(1);
					setprop("sim/model/A-10/weapons/release_lock", 1);
					if (aim9.getIndex() == 1) {
						setprop("sim/model/A-10/weapons/aim9s/aim9-available", 0);
					}
				}
			}
		}
	}
}

release_unlock = func {
	setprop("sim/model/A-10/weapons/release_lock", 0);
}

# station selection ------------------------------------------------------------

# several station could be selected at the same time, for now use only one 
select_station = func {
	target_idx = arg[0];
	setprop("controls/armament/station-select", target_idx);
	stations = props.globals.getNode("sim/model/A-10/weapons/stations", 1).getChildren("station");
	foreach (var station; stations) {
		idx = station.getIndex();
		if ( idx == target_idx ) {
			if (station.getNode("selected", 1).getValue() == 1) {
				station.getNode("selected", 1).setBoolValue(0);
			} else {
				station.getNode("selected", 1).setBoolValue(1);
			}
		} else {
			station.getNode("selected", 1).setBoolValue(0);
		}
	}
}



# config dialog ----------------------------------------------------------------
var config_dialog = nil;

setlistener("sim/model/A-10/weapons/ecm/an-alq-131", func {
	if (getprop("sim/model/A-10/weapons/ecm/an-alq-131")) {
		setprop("sim/model/A-10/weapons/stations/station[0]/weight-lb", 535);
	} else {
		setprop("sim/model/A-10/weapons/stations/station[0]/weight-lb", 0);	
	}
});

setlistener("sim/model/A-10/weapons/aim9s/dual", func {
	if (getprop("sim/model/A-10/weapons/aim9s/dual")) {
		setprop("sim/model/A-10/weapons/stations/station[10]/weight-lb", 612);
		setprop("sim/model/A-10/weapons/aim9s/aim9-available", 1);
		# recharger...
	} else {
		setprop("sim/model/A-10/weapons/stations/station[10]/weight-lb", 0);
		setprop("sim/model/A-10/weapons/aim9s/aim9-available", 0);		
	}
});






setlistener("/sim/signals/fdm-initialized", func {
	config_dialog = gui.Dialog.new("/sim/gui/dialogs/A-10/config/dialog",
		"Aircraft/A-10/Dialogs/config.xml");
});
