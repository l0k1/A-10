var eng_ignit_time = [0.0, 0.0];
var ats_valve_timer = [0.0, 0.0];
var ign_selected = [0, 0];

var update_loop = func(engNb=0) {
	# Declare variables
	var eng_serviceable = getprop("controls/engines/engine["~engNb~"]/faults/serviceable");
	var eng_switch_pos = getprop("sim/model/A-10/controls/engines/engine["~engNb~"]/starter-switch-position");
	var eng_throttle_pos = getprop("controls/engines/engine["~engNb~"]/throttle");
	var eng_n1 = getprop("sim/model/A-10/engines/engine["~engNb~"]/n1"); # FAN speed
	var eng_n2 = getprop("sim/model/A-10/engines/engine["~engNb~"]/n2"); # CORE speed
	var eng_n1_yasim = getprop("engines/engine["~engNb~"]/n1");
	var eng_n2_yasim = getprop("engines/engine["~engNb~"]/n2");
	var eng_n1_goal = 0.0;
	var eng_n2_goal = 0.0;
	var eng_ign_ramp = [getprop("systems/electrical/outputs/engine["~engNb~"]/engines-ignitors[0]"), getprop("systems/electrical/outputs/engine["~engNb~"]/engines-ignitors[1]")];
	var ats_valve = getprop("systems/bleed-air/ats-valve["~engNb~"]");
	var other_eng_numb = 1;
	if(engNb == 1) { other_eng_numb = 0; }
	var ats_valve_oth = getprop("systems/bleed-air/ats-valve["~other_eng_numb~"]");
	var eng_collector_tank = getprop("systems/A-10-fuel/collector-tank["~engNb~"]");
	var eng_out_of_fuel = 1;
	var time_now = getprop("sim/time/elapsed-sec");
	# TODO: Protect engine from overtemperature, overpressure and stall
	# TODO: motor @ IDLE for manual start
	# TODO: Ignition effect if n2 > 10 && collector_tank != 0 && !ats_valve
	# Take care of throttle cut OFF position
	if(getprop("controls/engines/engine["~engNb~"]/cutoff")) {
		setprop("controls/engines/engine["~engNb~"]/throttle", 0.0);
		eng_throttle_pos = 0.0;
	} elsif(eng_throttle_pos < 0.03) {
		setprop("controls/engines/engine["~engNb~"]/throttle", 0.03);
		eng_throttle_pos = 0.03;
	}
	setprop("sim/model/A-10/controls/engines/engine["~engNb~"]/throttle", eng_throttle_pos);
	# Hydraulic pressure
	var hydr_press = 0.0;
	if(getprop("controls/engines/engine["~engNb~"]/faults/hydraulic-pump-serviceable") and (getprop("systems/A-10-hydraulics/hyd-res["~engNb~"]") > 40)) { hydr_press = 17.85*eng_n2; }
	setprop("systems/A-10-hydraulics/hyd-psi["~engNb~"]", hydr_press);
	# Engines switch Operator position
	if(eng_switch_pos == 2) {
		# IGNition position. Switch is spring-loaded => back to NORM position
		setprop("sim/model/A-10/controls/engines/engine["~engNb~"]/starter-switch-position", 1);
		# We start a ignition cycle of 30 seconds
		if((eng_ignit_time[engNb] == 0.0) and (eng_throttle_pos >= 0.03)) {
			ign_selected[engNb] = 1;
			eng_ignit_time[engNb] = time_now;
			setprop("controls/engines/engine["~engNb~"]/engines-ignitors[0]", 1);
			setprop("controls/engines/engine["~engNb~"]/engines-ignitors[1]", 1);
			#print("Start engine N"~engNb~" ignition at "~eng_ignit_time[engNb]~".");
		}
	} elsif(eng_switch_pos == 1) {
		# NORM position
		if((getprop("systems/bleed-air/psi") > 50) and (eng_throttle_pos >= 0.03) and (eng_throttle_pos <= 0.06) and (eng_n2 < 56) and (electrical.AC_ESSEN_bus_volts > 23) and !ats_valve and !ats_valve_oth) {
			setprop("systems/bleed-air/ats-valve["~engNb~"]", 1);
			ats_valve = 1;
		}
		# We start a ignition cycle of 30 seconds minimum
		if(ats_valve and (eng_n2 >= 10) and (eng_n2 < 56) and (eng_ignit_time[engNb] == 0.0)) {
			eng_ignit_time[engNb] = time_now;
			setprop("controls/engines/engine["~engNb~"]/engines-ignitors[0]", 1);
			setprop("controls/engines/engine["~engNb~"]/engines-ignitors[1]", 1);
			#print("Start engine N"~engNb~" ignition at "~eng_ignit_time[engNb]~".");
		}
		# ATS valve should close 10 seconds after engine core speed reach 56 % rpm .
		if(ats_valve and (eng_n2 >= 56) and (ats_valve_timer[engNb] == 0.0)) {
			ats_valve_timer[engNb] = time_now;
			#print("Start ATS valve timer of engine N"~engNb~" at "~ats_valve_timer[engNb]~".");
		}
	} else {
		# MOTOR position
		if((getprop("systems/bleed-air/psi") > 50) and (eng_throttle_pos < 0.03) and (electrical.AC_ESSEN_bus_volts > 23) and !ats_valve and !ats_valve_oth) {
			setprop("systems/bleed-air/ats-valve["~engNb~"]", 1);
			ats_valve = 1;
		}
	}
	# Close ATS valve
	if(ats_valve and ((eng_throttle_pos > 0.06) or ((eng_throttle_pos < 0.03) and (eng_switch_pos != 0)) or ((ats_valve_timer[engNb] != 0.0) and (time_now > (ats_valve_timer[engNb] + 10))))) {
		#print("Close ATS valve of engine N"~engNb~" at "~time_now~".");
		#print("=>Engine core: "~eng_n2~" core by YASim: "~eng_n2_yasim~"");
		setprop("systems/bleed-air/ats-valve["~engNb~"]", 0);
		ats_valve_timer[engNb] = 0.0;
		ats_valve = 0;
	}
	# Stop engine ignition
	if((getprop("controls/engines/engine["~engNb~"]/engines-ignitors[0]") or getprop("controls/engines/engine["~engNb~"]/engines-ignitors[1]")) and (((time_now > (eng_ignit_time[engNb] + 30)) and (ign_selected[engNb] or (eng_n2 >= 56))) or (eng_throttle_pos < 0.03))) {
		eng_ignit_time[engNb] = 0.0;
		setprop("controls/engines/engine["~engNb~"]/engines-ignitors[0]", 0);
		setprop("controls/engines/engine["~engNb~"]/engines-ignitors[1]", 0);
		#print("Stop engine N"~engNb~" ignition at "~time_now~".");
		#print("=>Engine core: "~eng_n2~" core by YASim: "~eng_n2_yasim~"");
	}
	# Simulate engine core speed
	if(eng_serviceable) {
		if(!ats_valve and (eng_throttle_pos >= 0.03) and (eng_collector_tank > 0) and !getprop("engines/engine["~engNb~"]/out-of-fuel")) {
			# Engine running
			eng_n1 = eng_n1_yasim;
			eng_n2 = eng_n2_yasim;
			eng_out_of_fuel = 0;
		} elsif(ats_valve and ((ats_valve_timer[engNb] != 0.0) or (eng_ign_ramp[0] > 23) or (eng_ign_ramp[1] > 23)) and (eng_collector_tank > 0)) {
			# NORM startup
			eng_n1_goal = eng_n1_yasim;
			eng_n2_goal = eng_n2_yasim; # should be near 56% rpm
			eng_out_of_fuel = 0;
		} elsif(ats_valve) {
			# MOTOR
			eng_n1_goal = 8;
			eng_n2_goal = 16;
		}
	}
	if(eng_n2 != eng_n2_yasim) {
		# we calculate the core engine speed
		var delta_n1 = eng_n1_goal - eng_n1;
		var gain = 1.72;
		var tm = 0.2;
		var thau = 1.2;
		eng_n1 += (delta_n1*gain*math.exp(-tm/A10.UPDATE_PERIOD))/(1+(thau/A10.UPDATE_PERIOD));
		if(eng_n1 < 0) { eng_n1 = 0; }
		var delta_n2 = eng_n2_goal - eng_n2;
		eng_n2 += (delta_n2*gain*math.exp(-tm/A10.UPDATE_PERIOD))/(1+(thau/A10.UPDATE_PERIOD));
		if(eng_n2 < 0) { eng_n2 = 0; }
	}
	setprop("engines/engine["~engNb~"]/out-of-fuel", eng_out_of_fuel);
	setprop("sim/model/A-10/engines/engine["~engNb~"]/n1", eng_n1);
	setprop("sim/model/A-10/engines/engine["~engNb~"]/n2", eng_n2);
	#setprop("sim/model/A-10/engines/engine["~engNb~"]/egt-degc", (getprop("engines/engine["~engNb~"]/egt-degf")-32)*(5/9));
}

# Move the 3 positions 'ENG OPER' switch
var eng_oper_switch_move = func(engNb=0, swMov=0) {
	var switch_pos = getprop("sim/model/A-10/controls/engines/engine["~engNb~"]/starter-switch-position");
	if((switch_pos < 2) and (swMov == 1)) {
		switch_pos += 1;
	} elsif((swMov == 0) and (switch_pos > 0)) {
		switch_pos -= 1;
	}
	setprop("sim/model/A-10/controls/engines/engine["~engNb~"]/starter-switch-position", switch_pos);
}

# Move throttle from OFF to IDLE
var throttle_cutoff_mov = func(thrNb=0) {
	if(getprop("controls/engines/engine["~thrNb~"]/cutoff")) {
		setprop("controls/engines/engine["~thrNb~"]/cutoff", 0);
		setprop("controls/engines/engine["~thrNb~"]/throttle", 0.03);
	} elsif(getprop("controls/engines/engine["~thrNb~"]/throttle") < 0.06) {
		setprop("controls/engines/engine["~thrNb~"]/cutoff", 1);
		setprop("controls/engines/engine["~thrNb~"]/throttle", 0.0);
	}
}

# Autostart engine for lazy user
var eng_autostart = func() {
	print("Launch autostart engines sequence.");
	# Engines power generators
	setprop("controls/electric/engine[0]/generator", 1);
	setprop("controls/electric/engine[1]/generator", 1);
	# Move throttle to IDLE position
	setprop("controls/engines/engine[0]/cutoff", 0);
	setprop("controls/engines/engine[0]/throttle", 0.03);
	setprop("controls/engines/engine[1]/cutoff", 0);
	setprop("controls/engines/engine[1]/throttle", 0.03);
	# Feed engines fuel collector tank
	setprop("systems/A-10-fuel/collector-tank[0]", 1.519);
	setprop("systems/A-10-fuel/collector-tank[1]", 1.519);
	# Start the engines for Yasim
	setprop("engines/engine[0]/out-of-fuel", 0);
	setprop("engines/engine[1]/out-of-fuel", 0);
}
