# used to the animation of the canopy switch and the canopy move

canopy_switch = func {
  input = arg[0];
  if (input == 1) { do_open() }
  elsif (input == -1) { do_close() }
  elsif (input == 0) { do_stop() }
}

do_open = func {
  setprop("controls/canopy/A-10-canopy-switch", 3);
  if ( getprop("canopy/position-norm") < 1 ) {
  continue_move( 0.015 );
  }
}

do_close = func {
  setprop("controls/canopy/A-10-canopy-switch", 1); 
  if ( getprop("canopy/position-norm") > 0 ) {
  continue_move( -0.015 );
  }
}

do_stop = func {
  setprop("controls/canopy/A-10-canopy-switch", 2); 
}


continue_move = func {
  position = getprop("canopy/position-norm");
  new_position = position + arg[0];
  setprop("canopy/position-norm", new_position);
  if ( arg[0] > 0 ) {
    settimer( do_open, 0.05);
  }
}
