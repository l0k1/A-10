# Properties under /consumables/fuel/tank[n]:
# + level-gal_us    - Current fuel load.  Updated by the loop code.
# + level-lbs       - Conversion of level-gal_us by density-ppg.
# + selected        - boolean indicating tank selection.
# + density-ppg     - Fuel density, in lbs/gallon.
# + capacity-gal_us - Tank capacity defined by the Yasim model.
#
# Properties under /engines/engine[n]:
# + fuel-consumed-lbs - Output from the FDM, zeroed by this script .
# + fuel-flow-gph     - Instant fuel consumption in gallons per hour, but the ppg of yasim is false, so we have to correct it.
# + out-of-fuel       - boolean, set by this code.

# A-10 fuel system operation logic:
# 2 wing tanks (left and right), 2 fuselage tanks (left main-afterward and right main-forward)
# Up to 3 external tanks (2 wings and 1 fuselage).
# Normally the left wing and left main tanks feeds the left engine and the APU,
# the right wing and right main tanks feeds the right engine. The two feed lines could
# be interconnected by opening the cross feed valve.
# The wing boost pumps will supply the respective engine until the wing tanks are empty,
# at which time the wing boost pumps will automatically shut off. The main boost pumps will
# then supply the respective engine with the remainder of the fuel in the airplane.
#
# In case of a wing tank boost pump failure, the wing tank fuel will gravity feed to its respective
# main tank fuel when its fuel level will be below 600 lbs. Check valves prevent reverse fuel
# flow from the main tank to the wing tank.
#
# In the event of a main tank boost pump failure, the affected engine will suction-feed from the
# affected tank for all power setting up to an altitude of nearly 10,000 feet.
#
# Unequal fuel level between right main and left main tank (imbalance superior 750 lbs) will cause
# center of gravity shift that may exceed allowable limits. In this case, a valve named "tank gate"
# could link the two main tanks.
#
# Fuel from the external tanks is transfered to the main or wing tanks by pressure from
# the bleed air system. Wing tanks can be topped when the fuel level is below 1590 lbs.
# Main tanks can be topped when the fuel level is below 3034 lbs.
# The cycling is repeated until fuel is depleted from the external wing tanks first, and
# external fuselage tank secondly.
#
# For negative G flight, collector tanks will supply the engine with sufficient fuel for
# 10 seconds operation at MAX power.

var fuel_freeze = nil;
var ai_enabled = nil;

var update_loop = func {
	# declare variables
	# feed lines pressure after cross feed and fire valves, should be between 5 and 7 psi. Array represent pressures of left engine, right engine and APU.
	var feed_line_pressure = [0.0, 0.0, 0.0];
	# feed lines pressure before the cross feed valve. Array represent pressures of left wing/main tanks and right wing/main tanks.
	var feed_line_pressure_bf = [0.0, 0.0];
	#var apu_feed_line_pressure = 0.0;
	var fuel_flow_gph = 0;
	var density_ppg = getprop("consumables/fuel/tank[0]/density-ppg");
	var gal_total = 0;
	var gal_level = 0;
	var lbs_total = 0;
	var lbs_level = 0;
	var cap_total = 0;
	# fuel_flow_rate is equivalent of a flow of 20000pph
	var fuel_flow_rate = 0.896057*A10.UPDATE_PERIOD;
	var aa_refuel_flow = 0.0;
	var tk_gate_trans = 0; # in gallons!
	var left_wing_tank = getprop("consumables/fuel/tank[0]/level-lbs");
	var left_main_tank = getprop("consumables/fuel/tank[1]/level-lbs");
	var right_main_tank = getprop("consumables/fuel/tank[2]/level-lbs");
	var right_wing_tank = getprop("consumables/fuel/tank[3]/level-lbs");
	var fuel_dsp_sel = getprop("sim/model/A-10/controls/fuel/fuel-dsp-sel");
	var collector_tank = [getprop("systems/A-10-fuel/collector-tank[0]"), getprop("systems/A-10-fuel/collector-tank[1]")];
	var collector_tank_diff = [0.0, 0.0]; # in gallons!
	var apu_collector_tank = getprop("systems/A-10-fuel/apu-collector-tank");
	var apu_collector_tank_diff = 0.0;
	var int_tanks_filled = 0;
	var ext_tanks_filled = 0;
	
	if(fuel_freeze) {
		return;
	}
	
	# determine left and right feed-lines pressures.
	if(getprop("accelerations/pilot-g") > 0) {
		if(getprop("systems/A-10-fuel/tank[1]/boost-pump[1]")) { # DC pump left main tank
			feed_line_pressure_bf[0] = electrical.DC_ESSEN_bus_volts / 4.6;
		} elsif(getprop("systems/A-10-fuel/tank[0]/boost-pump[0]") or getprop("systems/A-10-fuel/tank[1]/boost-pump[0]")) { # left wing or main tank
			feed_line_pressure_bf[0] = electrical.L_AC_bus_volts / 4.6;
		}
		if(getprop("systems/A-10-fuel/tank[2]/boost-pump[0]") or getprop("systems/A-10-fuel/tank[3]/boost-pump[0]")) { # right wing or main tank
			feed_line_pressure_bf[1] = electrical.R_AC_bus_volts / 4.6;
		}
		# engine suction feed, up to an altitude of 10,000ft for all power, on a standard day (pressure at sea-level = 29.92).
		feed_line_pressure[0] = (getprop("sim/model/A-10/engines/engine[0]/n2")*getprop("environment/pressure-inhg")*0.0010215)+3.7823;
		feed_line_pressure[1] = (getprop("sim/model/A-10/engines/engine[1]/n2")*getprop("environment/pressure-inhg")*0.0010215)+3.7823;
	}
	# Equalize the feed-lines pressures if cross feed valve is open
	if(getprop("controls/fuel/tank[0]/to_engine") == -1) {
		if(feed_line_pressure_bf[0] > 5) {
			feed_line_pressure[0] = feed_line_pressure_bf[0];
			feed_line_pressure[1] = feed_line_pressure_bf[0];
		} elsif(feed_line_pressure_bf[1] > 5) {
			feed_line_pressure[0] = feed_line_pressure_bf[1];
			feed_line_pressure[1] = feed_line_pressure_bf[1];
		} else {
			if(feed_line_pressure[0] > feed_line_pressure[1]) {
				feed_line_pressure_bf[0] = feed_line_pressure[0];
				feed_line_pressure_bf[1] = feed_line_pressure[0];
			} else {
				feed_line_pressure_bf[0] = feed_line_pressure[1];
				feed_line_pressure_bf[1] = feed_line_pressure[1];
			}
			if(left_main_tank < 10) { feed_line_pressure_bf[0] = 0.0; }
			if(right_main_tank < 10) { feed_line_pressure_bf[1] = 0.0; }
			if((feed_line_pressure_bf[0] == 0) and (feed_line_pressure_bf[1] == 0)) {
				feed_line_pressure[0] = 0.0;
				feed_line_pressure[1] = 0.0;
			}
		}
	} else {
		if(feed_line_pressure_bf[0] > 5) {
			feed_line_pressure[0] = feed_line_pressure_bf[0];
		} else {
			if(left_main_tank < 10) { feed_line_pressure[0] = 0.0; }
			feed_line_pressure_bf[0] = feed_line_pressure[0];
		}
		if(feed_line_pressure_bf[1] > 5) {
			feed_line_pressure[1] = feed_line_pressure_bf[1];
		} else {
			if(right_main_tank < 10) { feed_line_pressure[1] = 0.0; }
			feed_line_pressure_bf[1] = feed_line_pressure[1];
		}
	}
	feed_line_pressure[2] = feed_line_pressure[0];
	if(!getprop("systems/A-10-fuel/fire-apu-eng-valve")) { feed_line_pressure[2] = 0.0; }
	if(!getprop("systems/A-10-fuel/fire-eng-valve[0]")) { feed_line_pressure[0] = 0.0; }
	if(!getprop("systems/A-10-fuel/fire-eng-valve[1]")) { feed_line_pressure[1] = 0.0; }
	setprop("systems/A-10-fuel/feed-line-press[0]", feed_line_pressure[0]);
	setprop("systems/A-10-fuel/feed-line-press[1]", feed_line_pressure[1]);
	if(feed_line_pressure[2] > 5) {
		apu_collector_tank_diff = 0.217 - apu_collector_tank;
		if(apu_collector_tank_diff > 0) { apu_collector_tank += apu_collector_tank_diff; }
		else { apu_collector_tank_diff = 0.0; }
	}
	# substract fuel consumed by the APU
	apu_collector_tank -= getprop("sim/model/A-10/systems/apu/fuel-consumed-lbs")/density_ppg;
	setprop("sim/model/A-10/systems/apu/fuel-consumed-lbs", 0);
	if(apu_collector_tank <= 0.0) {
		apu_collector_tank = 0.0;
		setprop("sim/model/A-10/systems/apu/out-of-fuel", 1);
	} else { setprop("sim/model/A-10/systems/apu/out-of-fuel", 0); }
	setprop("systems/A-10-fuel/apu-collector-tank", apu_collector_tank);
	# updates some engines values
	for(var i=0; i<2; i+=1) {
		# update fuel-flow-pph (lbs per hour) for engine gauges purpose.
		fuel_flow_gph = getprop("engines/engine["~i~"]/fuel-flow-gph");
		fuel_flow_gph = fuel_flow_gph * (6.72 / density_ppg); # we correct the value due to the Yasim fuel density bug
		if((getprop("sim/model/A-10/controls/engines/engine["~i~"]/throttle") >= 0.03) and (getprop("sim/model/A-10/engines/engine["~i~"]/n2") >= 10)) {
			# feed fuel collectors. Tank collector capacity => 1.519 gallons => enough fuel for about 10 sec @ max throttle (3500pph)
			if(feed_line_pressure[i] > 5) {
				collector_tank_diff[i] = 1.519 - collector_tank[i];
				if(collector_tank_diff[i] > 0) { collector_tank[i] += collector_tank_diff[i]; }
				else { collector_tank_diff[i] = 0.0; }
			}
			# substract the fuel consumed from the fuel collector since the last loop and RaZ it.
			collector_tank[i] -= getprop("engines/engine["~i~"]/fuel-consumed-lbs")/density_ppg;
			setprop("engines/engine["~i~"]/fuel-consumed-lbs", 0);
		} else { fuel_flow_gph = 0.0; }
		# should be fuel_flow_gph * density_ppg, but mathematically it is equivalent
		setprop("engines/engine["~i~"]/fuel-flow-pph", (fuel_flow_gph * 6.72));
		# Trick: if engine is MOTORised, substract fuel-consumed-lbs is not sufficient. It will require 30 seconds to empty the collector tank.
		if(getprop("systems/bleed-air/ats-valve["~i~"]") and (getprop("sim/model/A-10/engines/engine["~i~"]/n2") < 56) and (getprop("sim/model/A-10/engines/engine["~i~"]/n2") >= 10)) { collector_tank[i] -= 0.0506*A10.UPDATE_PERIOD; }
		if(collector_tank[i] <= 0.0) { collector_tank[i] = 0.0; }
	}
	setprop("systems/A-10-fuel/collector-tank[0]", collector_tank[0]);
	setprop("systems/A-10-fuel/collector-tank[1]", collector_tank[1]);
	# add fuel consumed by the APU
	collector_tank_diff[0] = collector_tank_diff[0] + apu_collector_tank_diff;
	# Divide equally the fuel consumed if cross feed valve is open.
	if(getprop("controls/fuel/tank[0]/to_engine") == -1) {
		if((feed_line_pressure_bf[0] > 5) and (feed_line_pressure_bf[1] > 5)) {
			collector_tank_diff[0] = (collector_tank_diff[0]+collector_tank_diff[1])/2;
			collector_tank_diff[1] = collector_tank_diff[0];
		} elsif((feed_line_pressure_bf[0] > 5) and (feed_line_pressure_bf[1] < 5)) {
			collector_tank_diff[0] += collector_tank_diff[1];
		} else { collector_tank_diff[1] += collector_tank_diff[0]; }
	}
	# count number of internal tanks ready to be refueled
	for(var k=0; k<4; k+=1) {
		if(getprop("systems/A-10-fuel/tank["~k~"]/fill-valve")) { int_tanks_filled +=1; }
	}
	# count number of external tanks ready to be refueled
	for(var m=4; m<7; m+=1) {
		if(getprop("systems/A-10-fuel/tank["~m~"]/fill-valve")) { ext_tanks_filled +=1; }
	}
	# air-air refueling
	if(ai_enabled and getprop("systems/refuel/door-lock") and ((getprop("systems/refuel/state") == 1) or (getprop("systems/refuel/state") == 2))) {
		if((int_tanks_filled > 0) or (ext_tanks_filled > 0)) {
			var tankerAINodeSibling = props.globals.getNode("ai/models", 1).getChildren("tanker");
			var tankerMPNodeSibling = props.globals.getNode("ai/models", 1).getChildren("multiplayer");
			if(tankerAINodeSibling != nil) { aa_refuel_flow = aar_fuel_flow(tankerAINodeSibling); }
			elsif(tankerMPNodeSibling != nil) { aa_refuel_flow = aar_fuel_flow(tankerMPNodeSibling); }
		}
		if((getprop("systems/refuel/state") == 1) and (aa_refuel_flow > 0)) {
			setprop("systems/refuel/state", 2);
		} elsif((getprop("systems/refuel/state") == 2) and (aa_refuel_flow == 0)) {
			setprop("systems/refuel/state", 3);
		}
	}
	# update tanks fuel level
	for(var j=0; j<7; j+=1) {
		gal_level = getprop("consumables/fuel/tank["~j~"]/level-gal_us");
		if(j==0) {
			if(getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]") and (feed_line_pressure_bf[0] > 5)) { gal_level -= collector_tank_diff[0]; }
			if(getprop("controls/fuel/tank["~j~"]/to_tank") == 1) { gal_level -= fuel_flow_rate; }
		} elsif(j==1) {
			# in case of main tank boost pump failure, engine could self feed if feed line pressure is enough (=> collector_tank_diff > 0).
			if((feed_line_pressure_bf[0] > 5) and (getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]") or getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[1]") or ((collector_tank_diff[0] > 0) and !getprop("systems/A-10-fuel/tank[0]/boost-pump[0]")))) { gal_level -= collector_tank_diff[0]; }
			if(getprop("controls/fuel/tank[0]/to_tank") == 1) { gal_level += fuel_flow_rate; }
			if((getprop("controls/fuel/tank["~j~"]/to_tank") == 2) and (getprop("controls/fuel/tank[2]/to_tank") == 1)) {
				# fuel flow between the 2 main tanks is proportionnal to the pitch of the airplane
				var pitch_rad = (getprop("orientation/pitch-deg")*math.pi)/180;
				# also proportionnal to the acceleration on the x axis
				var accel_fps = ((getprop("accelerations/pilot/x-accel-fps_sec")+0.5)*math.pi)/180;
				# and also proportionnal the difference level between this 2 tanks.
				var tk_fuel_diff = (gal_level*(1-math.sin(pitch_rad))*(1-math.sin(accel_fps))) - (getprop("consumables/fuel/tank[2]/level-gal_us")*(1+math.sin(pitch_rad))*(1+math.sin(accel_fps)));
				tk_gate_trans = fuel_flow_rate*(1-(math.abs(tk_fuel_diff)/1300));
				if(tk_fuel_diff < 0) { tk_gate_trans = tk_gate_trans * -1; }
				if(((tk_gate_trans > 0) and (gal_level < tk_gate_trans)) or ((tk_gate_trans < 0) and (getprop("consumables/fuel/tank[2]/level-gal_us") < tk_gate_trans))) { tk_gate_trans = 0; }
				gal_level -= tk_gate_trans;
			}
		} elsif(j==2) {
			if((feed_line_pressure_bf[1] > 5) and (getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]") or ((collector_tank_diff[1] > 0) and !getprop("systems/A-10-fuel/tank[3]/boost-pump[0]")))) { gal_level -= collector_tank_diff[1]; }
			if(getprop("controls/fuel/tank[3]/to_tank") == 2) { gal_level += fuel_flow_rate; }
			if((getprop("controls/fuel/tank["~j~"]/to_tank") == 1) and (getprop("controls/fuel/tank[1]/to_tank") == 2)) {
				gal_level += tk_gate_trans;
			}
		} elsif(j==3) {
			if(getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]") and (feed_line_pressure_bf[1] > 5)) { gal_level = gal_level - collector_tank_diff[1]; }
			if(getprop("controls/fuel/tank["~j~"]/to_tank") == 2) { gal_level -= fuel_flow_rate; }
		} elsif(j==4) {
			# external tanks to internal tanks refuel
			if(getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]") and getprop("systems/A-10-fuel/tank[6]/boost-pump[0]")) { gal_level -= fuel_flow_rate/2; }
			elsif(getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]")) { gal_level -= fuel_flow_rate; }
		} elsif(j==5) {
			if(getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]")) { gal_level -= fuel_flow_rate; }
		} elsif(j==6) {
			if(getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]") and getprop("systems/A-10-fuel/tank[4]/boost-pump[0]")) { gal_level -= fuel_flow_rate/2; }
			elsif(getprop("systems/A-10-fuel/tank["~j~"]/boost-pump[0]")) { gal_level -= fuel_flow_rate; }
		}
		# external tanks fuel flow to internal tanks refuel
		if((j < 4) and getprop("systems/A-10-fuel/tank["~j~"]/fill-valve") and (getprop("systems/A-10-fuel/tank[4]/boost-pump[0]") or getprop("systems/A-10-fuel/tank[5]/boost-pump[0]") or getprop("systems/A-10-fuel/tank[6]/boost-pump[0]"))) {
			gal_level += fuel_flow_rate/int_tanks_filled;
		}
		# air-air refuel
		if(getprop("systems/A-10-fuel/tank["~j~"]/fill-valve") and (aa_refuel_flow > 0)) { gal_level += aa_refuel_flow / (int_tanks_filled + ext_tanks_filled); }
		# tank could not have a negative level!
		if(gal_level < 0) { gal_level = 0; }
		setprop("consumables/fuel/tank["~j~"]/level-gal_us", gal_level);
		lbs_level = gal_level * density_ppg;
		setprop("consumables/fuel/tank["~j~"]/level-lbs", lbs_level);
		gal_total += gal_level;
		lbs_total += lbs_level;
		cap_total += getprop("consumables/fuel/tank["~j~"]/capacity-gal_us");
	}
	setprop("consumables/fuel/total-fuel-gals", gal_total);
	setprop("consumables/fuel/total-fuel-lbs", lbs_total);
	setprop("consumables/fuel/total-fuel-norm", gal_total / cap_total);
	
	# prepare values for the A-10's fuel quantity gauge and warning lights
	setprop("sim/model/A-10/consumables/fuel/diff-lbs", math.abs(right_main_tank - left_main_tank));
	if(getprop("systems/electrical/outputs/fuel-gauge-sel") < 23) {
		setprop("sim/model/A-10/consumables/fuel/fuel-dsp-left", 0);
		setprop("sim/model/A-10/consumables/fuel/fuel-dsp-right", 0);
		setprop("sim/model/A-10/consumables/fuel/fuel-dsp-drum", 0);
	} else {
		if(getprop("sim/model/A-10/controls/fuel/fuel-test-ind")) {
			setprop("sim/model/A-10/consumables/fuel/fuel-dsp-left", 3000);
			setprop("sim/model/A-10/consumables/fuel/fuel-dsp-right", 3000);
			setprop("sim/model/A-10/consumables/fuel/fuel-dsp-drum", 6000);
		} else {
			setprop("sim/model/A-10/consumables/fuel/fuel-dsp-drum", lbs_total);
			if(fuel_dsp_sel == -1) {
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-left", (left_wing_tank + left_main_tank));
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-right", (right_wing_tank + right_main_tank));
			} elsif(fuel_dsp_sel == 0) {
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-left", left_main_tank);
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-right", right_main_tank);
			} elsif(fuel_dsp_sel == 1) {
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-left", left_wing_tank);
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-right", right_wing_tank);
			} elsif(fuel_dsp_sel == 2) {
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-left", getprop("consumables/fuel/tank[4]/level-lbs"));
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-right", getprop("consumables/fuel/tank[6]/level-lbs"));
			} elsif(fuel_dsp_sel == 3) {
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-left", getprop("consumables/fuel/tank[5]/level-lbs"));
				setprop("sim/model/A-10/consumables/fuel/fuel-dsp-right", 0);
			}
		}
	}
}



var initialize = func {
	# kill $FG_ROOT/Nasal/fuel.nas loop
	fuel.update = func {}
	# declare variables
	var enginesNodeSibling = props.globals.getNode("engines", 1).getChildren("engine");
	var tanksNodeSibling = props.globals.getNode("consumables/fuel", 1).getChildren("tank");

	# pre-select the external ferry tanks.
	setprop("consumables/fuel/tank[4]/selected", 1);
	setprop("consumables/fuel/tank[5]/selected", 1);
	setprop("consumables/fuel/tank[6]/selected", 1);
	
	# We start with engine shutoff.
	foreach (var e; enginesNodeSibling) {
		e.getNode("out-of-fuel", 1).setBoolValue(1);
	}
	# Correction of the yasim fuel density bug : JP-4 kerosene density at 60°F .
	foreach (var t; tanksNodeSibling) {
		t.getNode("density-ppg", 1).setDoubleValue(6.4);
		#aircraft.data.add(t.getNode("level-gal_us", 1)); # BUG: data saved but not restored
	}

	setlistener("sim/freeze/fuel", func(n) { fuel_freeze = n.getBoolValue() }, 1);
	setlistener("sim/ai/enabled", func(n) { ai_enabled = n.getBoolValue() }, 1);
}


# Controls ################
var aar_receiver_lever = func(rec_pos=0) {
	if(rec_pos == 0) {
		setprop("systems/refuel/receiver-lever", 0);
		setprop("systems/refuel/door-lock", 0);
		setprop("systems/refuel/state", 0);
	} else {
		setprop("systems/refuel/receiver-lever", 1);
		# TODO: implement opening of the slipway-door by aerodynamic effect in case of right hydraulic system failure
		# TODO: temporise the overture even with enough hyd pressure.
		if((getprop("systems/A-10-hydraulics/hyd-psi[1]") > 900) and (electrical.L_DC_bus_volts > 20) and getprop("systems/refuel/serviceable")) {
			setprop("systems/refuel/door-lock", 1);
			setprop("systems/refuel/state", 1);
		}
	}
}

# reset the air-air refuel system from DISCONNECT state to
# READY state without the need of the RCVR button OR put the
# system to a LATCHED state to a DISCONNECT state.
# Match a button of your joystick to this nasal function.
var aar_reset_button = func {
	if(getprop("systems/refuel/state") == 3) { setprop("systems/refuel/state", 1); }
	elsif(getprop("systems/refuel/state") == 2) { setprop("systems/refuel/state", 3); }
}

# check if the plane is connected to an AI(or Multi-Player) tanker.
# return refuel flow in gallons.
var aar_fuel_flow = func(tankerNodeSibling) {
	var refuel_flow = 0;
	foreach(var t; tankerNodeSibling) {
		if(t.getNode("refuel/contact", 1).getBoolValue() and t.getNode("tanker", 1).getBoolValue()) {
			# equivalent of about 6000lbs/min in gallons.
			refuel_flow = 15.625*A10.UPDATE_PERIOD;
		}
	}
	return refuel_flow;
}

var fuel_sel_knob_move = func(arg0) {
	var knob_pos = getprop("sim/model/A-10/controls/fuel/fuel-dsp-sel");
	if(arg0 == 1 and knob_pos < 3) {
		knob_pos = knob_pos + 1;
	} elsif(arg0 == -1 and knob_pos > -1) {
		knob_pos = knob_pos - 1;
	}
	setprop("sim/model/A-10/controls/fuel/fuel-dsp-sel", knob_pos);
}
