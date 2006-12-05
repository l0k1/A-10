# starter: 3 positions switch
starter_switch = func {
	input = arg[0];
	position = "sim/model/A-10/controls/engines/engine["~arg[1]~"]/starter-switch-position";
	starter = "sim/model/A-10/controls/engines/engine["~arg[1]~"]/starter";
	running = "sim/model/A-10/engines/engine["~arg[1]~ "]/running";
	motor = "sim/model/A-10/controls/engines/engine["~arg[1]~"]/motor";
	if (input == 1) {
		if (getprop(position) == 0) {
			setprop(position, 1);
			setprop(starter, 0);
			setprop(running, 0);
			setprop(motor, 0)
		} elsif (getprop(position) == 1) {
			setprop(position, 2);
			setprop(starter, 1);
			setprop(running,1);
			setprop(motor, 0);
		}
	} elsif (input == -1) {
		if (getprop(position) == 1) {
			setprop(position, 0);
			setprop(starter, 0);
			setprop(running, 0);
			setprop(motor, 1)
		} elsif (getprop(position) == 2) {
			setprop(position, 1);
			setprop(starter, 0);
			setprop(running, 0);
			setprop(motor, 0);
		}
	}
}
