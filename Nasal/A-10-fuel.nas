# Properties under /consumables/fuel/tank[n]:
# + level-gal_us    - Current fuel load.  Can be set by user code.
# + level-lbs       - OUTPUT ONLY property, do not try to set
# + selected        - boolean indicating tank selection.
# + density-ppg     - Fuel density, in lbs/gallon.
# + capacity-gal_us - Tank capacity
#
# Properties under /engines/engine[n]:
# + fuel-consumed-lbs - Output from the FDM, zeroed by this script
# + out-of-fuel       - boolean, set by this code.


var UPDATE_PERIOD = 0.1;

var enabled = nil;
var fuel_freeze = nil;
var ai_enabled = nil;
var engines = nil;
var tanks = nil;
var refuelingN = nil;
var aimodelsN = nil;
var out_of_fuel = nil;
var aar_rcvr = nil;
var aar_lock = nil;
var aar_state = nil;

# initialize property if it doesn't exist, and set node type otherwise
init_prop = func(node, prop, val, type = "double") {
	var n = node.getNode(prop);
	if (n != nil) {
		var v = n.getValue();
		if (v != nil) {
			val = v;
		}
	}
	node = node.getNode(prop, 1);
	if (type == "double") {
		node.setDoubleValue(val);
	} elsif (type == "bool") {
		node.setBoolValue(val);
	} elsif (type == "int") {
		node.setIntValue(val);
	}
}



update_loop = func {
	# check for contact with tanker aircraft
	var tankers = [];
	if (ai_enabled) {
		foreach (a; aimodelsN.getChildren("tanker")) {
			var contact = a.getNode("refuel/contact", 1).getBoolValue();
			var tanker = a.getNode("tanker", 1).getBoolValue();
			var id = a.getNode("id").getValue();
			#print("ai '", id, "'  contact=", contact, "  tanker=", tanker);

			if (tanker and contact) {
				append(tankers, a);
			}
		}

		foreach (m; aimodelsN.getChildren("multiplayer")) {
			var contact = m.getNode("refuel/contact").getBoolValue();
			var tanker = m.getNode("tanker").getBoolValue();
			var id = m.getNode("id").getValue();
			print("mp '", id, "'  contact=", contact, "  tanker=", tanker);

			if (tanker and contact) {
				append(tankers, m);
			}
		}
	}
	# A-10 specific receiver logic
	var refueling = size(tankers) >= 1;
	refuelingN.setBoolValue(refueling);
	if (size(tankers) >= 1) {
		if ((! aar_lock) and (aar_rcvr)) {
			refueling = 1;
			aar_state = 1;
		} else {
			refueling = 0;
		}
	} elsif (aar_state) {
		aar_lock = 1;
		setprop("sim/model/A-10/controls/fuel/aar-lock", aar_lock);
		aar_state = 0;
	}

	if (fuel_freeze) {
		return settimer(update_loop, UPDATE_PERIOD);
	}


	# sum up consumed fuel
	var total = 0;
	foreach (var e; engines) {
		total += e.getNode("fuel-consumed-lbs").getValue();
		e.getNode("fuel-consumed-lbs", 1).setDoubleValue(0);
	}	

	# unlock A-10 aar receiver lock and calculate fuel received
	if (refueling) {
		# assume max flow rate is 6000 lbs/min (for KC135)
		var received = 100 * UPDATE_PERIOD;
		total -= received;
	}


	# make list of selected tanks
	var selected_tanks = [];
	foreach (var t; tanks) {
		var cap = t.getNode("capacity-gal_us", 1).getValue();
		if (cap != nil and cap > 0.01 and t.getNode("selected", 1).getBoolValue()) {
			append(selected_tanks, t);
		}
	}



	if (size(selected_tanks) == 0) {
		out_of_fuel = 1;
		
	} else {
		out_of_fuel = 0;
		if (total >= 0) {
			var fuelPerTank = total / size(selected_tanks);
			foreach (var t; selected_tanks) {
				var ppg = t.getNode("density-ppg").getValue();
				var lbs = t.getNode("level-gal_us").getValue() * ppg;
				lbs -= fuelPerTank;

				if (lbs < 0) {
					lbs = 0;
					# Kill the engines if we're told to, otherwise simply
					# deselect the tank.
					if (t.getNode("kill-when-empty", 1).getBoolValue()) {
						out_of_fuel = 1;
					} else {
						t.getNode("selected", 1).setBoolValue(0);
					}
				}

				var gals = lbs / ppg;
				t.getNode("level-gal_us").setDoubleValue(gals);
				t.getNode("level-lbs").setDoubleValue(lbs);
			}

		} elsif (total < 0) {
			#find the number of tanks which can accept fuel
			var available = 0;

			foreach (var t; selected_tanks) {
				var ppg = t.getNode("density-ppg").getValue();
				var capacity = t.getNode("capacity-gal_us").getValue() * ppg;
				var lbs = t.getNode("level-gal_us").getValue() * ppg;

				if (lbs < capacity) {
					available += 1;
				}
			}

			if (available > 0) {
				var fuelPerTank = total / available;

				# add fuel to each available tank
				foreach (var t; selected_tanks) {
					var ppg = t.getNode("density-ppg").getValue();
					var capacity = t.getNode("capacity-gal_us").getValue() * ppg;
					var lbs = t.getNode("level-gal_us").getValue() * ppg;

					if (capacity - lbs >= fuelPerTank) {
						lbs -= fuelPerTank;
					} elsif (capacity - lbs < fuelPerTank) {
						lbs = capacity;
					}

					t.getNode("level-gal_us").setDoubleValue(lbs / ppg);
					t.getNode("level-lbs").setDoubleValue(lbs);
				}

				# print ("available ", available , " fuelPerTank " , fuelPerTank);
			}
		}
	}


	var gals = 0;
	var lbs = 0;
	var cap = 0;
	foreach (var t; tanks) {
		gals += t.getNode("level-gal_us", 1).getValue();
		lbs += t.getNode("level-lbs", 1).getValue();
		cap += t.getNode("capacity-gal_us", 1).getValue();
	}

	setprop("/consumables/fuel/total-fuel-gals", gals);
	setprop("/consumables/fuel/total-fuel-lbs", lbs);
	setprop("/consumables/fuel/total-fuel-norm", gals / cap);
	
	# prepare values for the A-10's fuel gauge and warning lights 
	left_wing = getprop("consumables/fuel/tank[0]/level-lbs");
	left_main = getprop("consumables/fuel/tank[1]/level-lbs");
	right_main = getprop("consumables/fuel/tank[2]/level-lbs");
	right_wing = getprop("consumables/fuel/tank[3]/level-lbs");
	total_int_left = left_wing + left_main;
	total_int_right = right_wing + right_main;
	setprop("sim/model/A-10/consumables/fuel/int-left-lbs", total_int_left);
	setprop("sim/model/A-10/consumables/fuel/int-right-lbs", total_int_right);
	diff_lbs = abs(right_main - left_main);
	setprop("sim/model/A-10/consumables/fuel/diff-lbs", diff_lbs);
	
	# stop the A-10's engines when off or when out of fuel	
	var start_state = getprop("sim/model/A-10/engines/engine[0]/start-state");
	var n1 = getprop("engines/engine[0]/n1");
	var running = getprop("sim/model/A-10/engines/engine[0]/running");

	if (! running) {
		setprop("engines/engine[0]/out-of-fuel", 1);
	} else {
		setprop("engines/engine[0]/out-of-fuel", out_of_fuel);
		if (start_state >= 1) {
			setprop("sim/model/A-10/engines/engine[0]/n1", n1);
		}
	}
	start_state = getprop("sim/model/A-10/engines/engine[1]/start-state");
	n1 = getprop("engines/engine[1]/n1");
	running = getprop("sim/model/A-10/engines/engine[1]/running");

	if (! running) {
		setprop("engines/engine[1]/out-of-fuel", 1);
	} else {
		setprop("engines/engine[1]/out-of-fuel", out_of_fuel);
		if (start_state >= 1) {
			setprop("sim/model/A-10/engines/engine[1]/n1", n1);
		}
	}
	

	# miscelaneous A-10's props
	setprop("velocities/ground-speed-kt", ground_speed());


	settimer(update_loop, UPDATE_PERIOD);
}



initialize = func {
	fuel.update = func {}	# kill $FG_ROOT/Nasal/fuel.nas' loop
	print ("Initializing Nasal Fuel System");
	refuelingN = props.globals.getNode("/systems/refuel/contact", 1);
	refuelingN.setBoolValue(0);
	aar_rcvr = getprop("sim/model/A-10/controls/fuel/receiver-lever");
	aar_lock = getprop("sim/model/A-10/controls/fuel/aar-lock");
	aar_state = 0;
	aimodelsN = props.globals.getNode("ai/models", 1);
	engines = props.globals.getNode("engines", 1).getChildren("engine");
	tanks = props.globals.getNode("consumables/fuel", 1).getChildren("tank");

	foreach (var e; engines) {
		e.getNode("fuel-consumed-lbs", 1).setDoubleValue(0);
		e.getNode("out-of-fuel", 1).setBoolValue(0);
	}

	foreach (var t; tanks) {
		init_prop(t, "level-gal_us", 0);
		init_prop(t, "level-lbs", 0);
		init_prop(t, "capacity-gal_us", 0.01); # Not zero (div/zero issue)
		init_prop(t, "density-ppg", 6.0);      # gasoline
		init_prop(t, "selected", 1, "bool");
	}

	setlistener("sim/freeze/fuel", func { fuel_freeze = cmdarg().getBoolValue() }, 1);
	setlistener("sim/ai/enabled", func { ai_enabled = cmdarg().getBoolValue() }, 1);

	update_loop();
}

ground_speed = func {
	nfps = getprop("velocities/speed-north-fps");
	efps = getprop("velocities/speed-east-fps");
	vfps =  math.sqrt((nfps * nfps) + (efps * efps));
	# 1 kph = 1 fps / 6080.27 * 3600 
	vkph = vfps * 0.59207897;
	return(vkph);
}

aar_receiver_lever = func {
	input = arg[0];
	aar_rcvr = getprop("sim/model/A-10/controls/fuel/receiver-lever");
	if (input == 1) {
		aar_rcvr = 1;
		setprop("sim/model/A-10/controls/fuel/receiver-lever", aar_rcvr);
	} elsif (input == -1) {
		aar_rcvr = 0;
		setprop("sim/model/A-10/controls/fuel/receiver-lever", aar_rcvr);
		aar_lock = 0;
		setprop("sim/model/A-10/controls/fuel/aar-lock", aar_lock);
	}
}


setlistener("/sim/signals/fdm-initialized", initialize);

