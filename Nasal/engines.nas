


# starter: 3 positions switch
var starter_switch = func {
	var input = arg[0];
	var eng_num = arg[1];
	var position = "sim/model/A-10/controls/engines/engine["~eng_num~"]/starter-switch-position";
	var starter = "sim/model/A-10/controls/engines/engine["~eng_num~"]/starter";
	var running = "sim/model/A-10/engines/engine["~eng_num~ "]/running";
	var motor = "sim/model/A-10/controls/engines/engine["~eng_num~"]/motor";
	if (input == 1) {
		if (getprop(position) == 0) {
			# up to ignition
			setprop(position, 1);
			setprop(starter, 0);
			setprop(running, 0);
			setprop(motor, 0)
		} elsif (getprop(position) == 1) {
			# up to ignition
			setprop(position, 2);
			setprop(starter, 1);
			settimer(func {test_start(eng_num)}, 0.5);
			setprop(motor, 0);
		}
	} elsif (input == -1) {
		if (getprop(position) == 1) {
			# down to motor
			setprop(position, 0);
			setprop(starter, 0);
			setprop(motor, 1)
		} elsif (getprop(position) == 2) {
			# down to norm
			setprop(position, 1);
			setprop(starter, 0);
			setprop(motor, 0);
		}
		test_stop(eng_num);
	}
}

var test_start = func {
	var eng_num = arg[0];
	var speed = 0.03;
	var ignitors_volts = getprop("systems/electrical/outputs/engines-ignitors");
	var left_main = getprop("consumables/fuel/tank[1]/level-lbs");
	var start_state = getprop("sim/model/A-10/engines/engine["~eng_num~"]/start-state");
	var psi = props.globals.getNode("systems/bleed-air/psi").getValue();
	if (( left_main > 10.0 ) and ( ignitors_volts > 23.0 ) and ( psi > 50 )) {
		if ( start_state < 1 ) {
			var new_start_state = start_state + 0.004;
			setprop("sim/model/A-10/engines/engine["~eng_num~"]/start-state", new_start_state );
			# rpm increase during around 60 sec up to 60%
			var rpm = (math.sin( ( start_state * 3 ) + 4.7 )+1) * 27;
			setprop("sim/model/A-10/engines/engine["~eng_num~"]/n1", rpm);
			if (( left_main > 10.0 ) and ( start_state > 0.3 )) {
				setprop("sim/model/A-10/engines/engine["~eng_num~"]/running", 1);
			}
			settimer(func {test_start(eng_num)}, speed);
		} else {
			setprop("sim/model/A-10/engines/engine["~eng_num~"]/running", 1);
		}
	} else {
		setprop("sim/model/A-10/controls/engines/engine["~eng_num~"]/starter-switch-position", 1);
	}
}

var test_stop = func {
	var eng_num = arg[0];
	var rpm_stop = 1;
	var speed = 0.1;
	var start_state = getprop("sim/model/A-10/engines/engine["~eng_num~"]/start-state");
	var rpm = getprop("sim/model/A-10/engines/engine["~eng_num~"]/n1");
	if ( rpm > 0.3 ) {
		var new_rpm = rpm - 0.3;
			setprop("sim/model/A-10/engines/engine["~eng_num~"]/n1", new_rpm);
			setprop("sim/model/A-10/engines/engine["~eng_num~"]/running", 0);
	} else {
		rpm_stop = 0;
	}
	if (rpm_stop) {
		settimer(func {test_stop(eng_num)}, speed);
	} else {
		setprop("sim/model/A-10/engines/engine["~eng_num~"]/start-state", 0 );
	}
}




