# animation of the canopy switch and the canopy move
# arg[0]: 1 and -1 = mouse click up/down aeras, 2 = keyb "C" toggle like.

canopy_switch = func {
	input = arg[0];
	if ( ! getprop("sim/model/A-10/controls/canopy-lock") ) {
		setprop("sim/model/A-10/controls/canopy-lock", 1);
		if (input == 2 ) {
			if ( getprop("canopy/position-norm") < 1 ) {
				input = 1;
			} elsif ( getprop("canopy/position-norm") >= 1 ) {
				input = -1;
			}
		}
		if (input == 1 ) {
			setprop("controls/canopy-switch", 3);
			do_open();
		}
		elsif (input == -1) {
			setprop("controls/canopy-switch", 1);
			do_close();
		}
	}
}

do_open = func {
	if ( getprop("canopy/position-norm") < 1 ) {
		continue_move( 0.015 );
	} else {
		setprop("sim/model/A-10/controls/canopy-lock", 0);
	}
}

do_close = func {
		if ( getprop("canopy/position-norm") > 0 ) {
		continue_move( -0.015 );
	} else {
		setprop("sim/model/A-10/controls/canopy-lock", 0);
	}
}

continue_move = func {
	position = getprop("canopy/position-norm");
	new_position = position + arg[0];
	setprop("canopy/position-norm", new_position);
	if ( arg[0] > 0 ) {
		settimer( do_open, 0.05);
	} elsif ( arg[0] < 0 ) {
		settimer( do_close, 0.05);
	}
}
