var UPDATE_PERIOD = 0.1;
var ikts        = props.globals.getNode("velocities/airspeed-kt");
var aft_ballast = props.globals.getNode("sim/model/A-10/controls/flight/CG-trim-aft", 1);
var fwd_ballast = props.globals.getNode("sim/model/A-10/controls/flight/CG-trim-fwd", 1);

# Flaps ###################
# automatic retraction of the flaps if speed exceed 210 KIAS
# flap will automatically reextended if speed is reduced to 190
# KIAS and flap lever is on MVR or DN.
var speed_toggle_flap = func {
	var kias_speed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
	var curr_set = getprop("sim/flaps/current-setting");
	if(kias_speed > 210) {
		setprop("controls/flight/flaps", 0.0);
	} else {
		if(kias_speed < 190 and curr_set != nil) {
			# var curr_set_flap = getprop("sim/flaps/setting[" ~ curr_set ~ "]");
			setprop("controls/flight/flaps", getprop("sim/flaps/setting[" ~ curr_set ~ "]"));
		}
	}
}

# auto-trim: Move a ballast from one Yasim weight point to another
# depending on the airspeed of the a/c. 
var auto_trim = func {
	var kts = ikts.getValue();
	var new_fwd = 0;
	if (kts > 220) { new_fwd = 11*(kts-220); }
	if (new_fwd > 2500) { new_fwd = 2500 }
	var new_aft = 2500 - new_fwd;
	#print ( new_fwd );	
	aft_ballast.setDoubleValue(new_aft);
	fwd_ballast.setDoubleValue(new_fwd);
}


# Main loop ###############
var cnt = 0;	# elecrical is done each 0.3 sec.
				# hud is done each 0.1 sec.
				# fuel is done each 0.1 sec.
				# flaps is done each 0.6 sec.

var main_loop = func {
	cnt += 1;
	auto_trim();
	A10hud.update_loop();
	A10fuel.update_loop();
	if ((cnt == 3 ) or (cnt == 6 )) {
		electrical.update_electrical();
		pilot_g.update_pilot_g();
		if (cnt == 6 ) {
			speed_toggle_flap();
			cnt = 0;
		}		
	}
	settimer(main_loop, UPDATE_PERIOD);
}



# Trajectory markers ######
var toggle_traj_mkr = func {
	var p = "/ai/submodels/trajectory-markers";
	setprop(p, !getprop(p));
}



# Init ####################
var init = func {
	settimer(A10autopilot.ap_common_aileron_monitor, 0.5);
	settimer(A10autopilot.ap_common_elevator_monitor, 0.5);
	settimer(A10autopilot.altimeter_monitor, 0.5);
	print("Initializing A-10 CCIP range calculator");
	print("Initializing Nasal Fuel System");
	A10fuel.initialize();
	print("Initializing Nasal Electrical System");
	electrical.init_electrical();
	settimer(speed_toggle_flap, 0.5);
	settimer(func {canopy.cockpit_state()}, 3);
	main_loop();
}
setlistener("/sim/signals/fdm-initialized", init);



# Lighting ################
# strobes
var strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("sim/model/A-10/lighting/strobe", [0.05, 1.00], strobe_switch);

# nav lights
var nav_lights_switch = props.globals.getNode("sim/model/A-10/controls/lighting/nav-lights-flash", 1);
aircraft.light.new("sim/model/A-10/lighting/nav-lights", [0.62, 0.62], nav_lights_switch);

# warning lights medium speed
var warn_medium_lights_switch = props.globals.getNode("sim/model/A-10/controls/lighting/warn-medium-lights-switch", 1);
aircraft.light.new("sim/model/A-10/lighting/warn-medium-lights", [0.40, 0.30], warn_medium_lights_switch);


