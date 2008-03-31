var UPDATE_PERIOD = 0.1;
var ikts        = props.globals.getNode("velocities/airspeed-kt");
var audio_alt_warn_signal = props.globals.getNode("sim/model/A-10/instrumentation/warnings/audio-alt");


# Flaps ###################
# automatic retraction of the flaps if speed exceed 210 KIAS
# flap will automatically reextended if speed is reduced to 190
# KIAS and flap lever is on MVR or DN.
var speed_toggle_flap = func {
	var kias_speed = getprop("instrumentation/airspeed-indicator/indicated-speed-kt");
	var curr_set = getprop("sim/flaps/current-setting");
	if(kias_speed > 210) {
		setprop("controls/flight/flaps", 0.0);
	} elsif((kias_speed < 190) and (curr_set != nil)) {
		setprop("controls/flight/flaps", getprop("sim/flaps/setting["~curr_set~"]"));
	}
}


# SAS #####################
# Stability Augmentation System.
# - Smooths the elevator input.
# - Damps the elevator output when positive ie: diving. (max output = 0.47)
var pitch_sas_sw  = props.globals.getNode("sim/model/A-10/controls/sas/pitch-sas-switch");
var raw_elev      = props.globals.getNode("controls/flight/elevator");
var sas_elev      = props.globals.getNode("sim/model/A-10/controls/flight/sas-elevator");
var sas_low_aoa_avoid = props.globals.getNode("sim/model/A-10/controls/flight/sas-low-aoa", 1);
var last_sas_elev = 0;
var sas_elev_smooth_factor = 0.1;
var aoa           = props.globals.getNode("orientation/alpha-deg");

var sas = func {
	var p_sas_sw = pitch_sas_sw.getBoolValue();
	var raw_e = raw_elev.getValue();
	var low_aoa_avoid = 0;
	if (p_sas_sw) {
		var filtered_move = (raw_e - last_sas_elev) * sas_elev_smooth_factor;
		var new_sas_elev = last_sas_elev + filtered_move;
		last_sas_elev = new_sas_elev;
		if (new_sas_elev > -0.01) {
			var curr_aoa = aoa.getValue();
			var curr_kias = ikts.getValue();
			if ( curr_aoa < 2 and curr_kias > 180 ) {
				curr_aoa -= 2;
				low_aoa_avoid = curr_aoa * (0.03 - (0.06 * curr_aoa));
				if (low_aoa_avoid < -0.13 ){ low_aoa_avoid = -0.13}
			}
			new_sas_elev = (new_sas_elev * (0.95 - (0.48 * new_sas_elev))) + low_aoa_avoid;
		} 
		sas_elev.setDoubleValue(new_sas_elev);
	} else {
		sas_elev.setDoubleValue(raw_e);
	}
	sas_low_aoa_avoid.setDoubleValue(low_aoa_avoid);
}

# Audio Altitude Warning ##
var audio_alt_vol = props.globals.getNode("sim/model/A-10/instrumentation/warnings/audio-alt-volume");
aircraft.data.add(audio_alt_vol);

var audio_alt_warn_counter = 0;
var audio_alt_warning = func {
	var gear = getprop("gear/gear[0]/position-norm");
	var alt = getprop("position/altitude-agl-ft");
	if ( audio_alt_warn_counter == 0 and gear == 0 and alt < 200 ) {
		audio_alt_warn_signal.setBoolValue(1);
	}
	audio_alt_warn_counter += 1;
	if ( audio_alt_warn_counter == 20 or alt >= 200 ) {
		audio_alt_warn_counter = 0;
		audio_alt_warn_signal.setBoolValue(0);
	}
	setprop("sim/model/A-10/instrumentation/warnings/alt_warn_counter", audio_alt_warn_counter);
}

# Accelerometer ###########
var g_curr 	  	= props.globals.getNode("accelerations/pilot-g");
var g_max	   	= props.globals.getNode("sim/model/A-10/instrumentation/g-meter/g-max");
var g_min	   	= props.globals.getNode("sim/model/A-10/instrumentation/g-meter/g-min");

var g_min_max = func {
	# records g min and max values
	var curr = g_curr.getValue();
	var max = g_max.getValue();
	var min = g_min.getValue();
	if ( curr >= max ) {
		g_max.setDoubleValue(curr);
	} elsif ( curr <= min ) {
		g_min.setDoubleValue(curr);
	}
}

# Cockpit view: translate view along x axis when look far right or far left.
var xAxisViewLowpass = aircraft.lowpass.new(0.15);
xAxisViewLowpass.set(0.0);

var pilot_view_limiter = {
	init : func {
		me.hdgN = props.globals.getNode("/sim/current-view/heading-offset-deg", 1);
		me.xViewAxisN = props.globals.getNode("/sim/current-view/x-offset-m", 1);
		me.currViewNumbN = props.globals.getNode("sim/current-view/view-number", 1);
	},
	update : func {
		var hdg = view.normdeg(me.hdgN.getValue());
		var xAxisVal = me.xViewAxisN.getValue();
		var currViewNumb = me.currViewNumbN.getValue();
		var updateHdg = 0;
		var updateXaxis = 0;
		# set a min/max heading view degree.
		var headingMax = getprop("sim/view["~currViewNumb~"]/config/heading-normdeg-max");
		var headingMin = getprop("sim/view["~currViewNumb~"]/config/heading-normdeg-min");
		if((headingMax != nil) and (hdg > headingMax)) {
			hdg = headingMax;
			updateHdg = 1;
		} elsif((headingMin != nil) and (hdg < headingMin)) {
			hdg = headingMin;
			updateHdg = 1;
		}
		if(updateHdg)
			me.hdgN.setDoubleValue(hdg);
		# translate view on X axis to look far right or far left.
		var xAxisTranslate = getprop("sim/view["~currViewNumb~"]/config/x-trans-m");
		var xAxisHeadingMax = getprop("sim/view["~currViewNumb~"]/config/x-trans-heading-normdeg-max");
		var xAxisHeadingMin = getprop("sim/view["~currViewNumb~"]/config/x-trans-heading-normdeg-min");
		if((xAxisTranslate != nil) and (xAxisHeadingMax != nil) and (xAxisHeadingMin != nil)) {
			if((hdg <= xAxisHeadingMin) and (xAxisVal != xAxisTranslate)) {
				updateXaxis = 1;
				xAxisVal = xAxisTranslate;
			} elsif((hdg >= xAxisHeadingMax) and (xAxisVal != (xAxisTranslate * -1))) {
				updateXaxis = 1;
				xAxisVal = xAxisTranslate * -1;
			} elsif((hdg > xAxisHeadingMin) and (hdg < xAxisHeadingMax) and (xAxisVal != 0.0)) {
				updateXaxis = 1;
				xAxisVal = 0.0;
			}
		}
		if(updateXaxis) {
			xAxisVal = xAxisViewLowpass.filter(xAxisVal);
			if((xAxisVal > -0.05) and (xAxisVal < 0.05)) { xAxisVal = 0.0; }
			me.xViewAxisN.setDoubleValue(xAxisVal);
		}
		return 0;
	},
};

view.panViewDir = func(step) {
	if(getprop("/sim/freeze/master"))
		var prop = "/sim/current-view/heading-offset-deg";
	else
		var prop = "/sim/current-view/goal-heading-offset-deg";
	var viewVal = getprop(prop);
	var delta = step * view.VIEW_PAN_RATE * getprop("/sim/time/delta-realtime-sec");
	var viewValSlew = viewVal + delta;
	viewValSlew = view.normdeg(viewValSlew);
	var currViewNumb = getprop("sim/current-view/view-number");
	var headingMax = getprop("sim/view["~currViewNumb~"]/config/heading-normdeg-max");
	var headingMin = getprop("sim/view["~currViewNumb~"]/config/heading-normdeg-min");
	if((headingMax != nil) and (viewValSlew > headingMax))
		viewValSlew = headingMax;
	elsif((headingMin != nil) and (viewValSlew < headingMin))
		viewValSlew = headingMin;
	setprop(prop, viewValSlew);
}

# Main loop ###############
var cnt = 0;	# elecrical is done each 0.3 sec.
				# hud is done each 0.1 sec.
				# fuel is done each 0.1 sec.
				# flaps is done each 0.6 sec.

var main_loop = func {
	cnt += 1;
	sas();
	A10hud.update_loop();
	apu.update_loop();
	A10fuel.update_loop();
	A10engines.update_loop(0);
	A10engines.update_loop(1);
	nav_scripts.nav2_homing_devs();
	nav_scripts.tacan_offset_apply();
	nav_scripts.compas_card_dev_indicator();
	pilot_g.update_pilot_g();
	g_min_max();
	if ((cnt == 3 ) or (cnt == 6 )) {
		audio_alt_warning();
		electrical.update_electrical();
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
	view.manager.register("Cockpit View", pilot_view_limiter);
	settimer(A10autopilot.ap_common_aileron_monitor, 0.5);
	settimer(A10autopilot.ap_common_elevator_monitor, 0.5);
	settimer(A10autopilot.altimeter_monitor, 0.5);
	print("Initializing A-10 CCIP range calculator");
	print("Initializing Nasal Fuel System");
	A10fuel.initialize();
	print("Initializing Nasal Electrical System");
	electrical.init_electrical();
	print("Initializing weapons system.");
	A10weapons.initialize();
	nav_scripts.freq_startup();
	settimer(func {canopy.cockpit_state()}, 3);
	aircraft.data.save();
	settimer(main_loop, 0.5);
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


