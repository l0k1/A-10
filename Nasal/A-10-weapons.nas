

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


# gun trigger ------------------------------------------------------------------
# todo: only one key binding plus selection of station target or gun.

controls.trigger = func(b) { b ? fire_gau8a() : cfire_gau8a() }

fire_gau8a = func {
	if (getprop("sim/model/A-10/weapons/gun/gun-ready")
	and (getprop("ai/submodels/submodel[1]/count") > 0)) {
		setprop("ai/submodels/GAU-8A", 1);
		ammo_cnt = getprop("ai/submodels/submodel[1]/count");
		ammo_wgt = ammo_cnt * 2;
		setprop("yasim/weights/ammunition-weight-lbs", ammo_wgt);
	}
}

cfire_gau8a = func {
	setprop("ai/submodels/GAU-8A", 0);
	if (getprop("ai/submodels/submodel[1]/count") == 0) {
		setprop("sim/model/A-10/weapons/gun/gun-ready", 0);
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
