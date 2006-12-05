# Fairchild A-10 radio and navigation system
# Alexis BORY  < xiii at g2ms dot com >  -- Public Domain


# an/arc-186
#------------------------------------------------------------------------------

# the "save to disk" function parts (to keep the preseted frequencies from flight to flight)
# are commented out. See Aircraft/A-10/Nasal/nav_ac_state.nas for how to use it.

# init, mainly useful when saving preseted freqs...
freq_startup = func {
  # nav_ac_state.freq_state_load();
  #if(getprop( "instrumentation/nav[2]/frequencies/selected-mhz" ) == nil) { return registerTimer(); }
  #for(i=1; i<21; i=i+1) {
    #if(getprop("sim/model/A-10/instrumentation/nav[2]/presets/preset[" ~ i ~ "]") != 10) {
      #preset_num = getprop("sim/model/A-10/instrumentation/nav[2]/selected-preset");
      #setprop( "sim/model/A-10/instrumentation/nav[2]/frequencies/selected-mhz" , getprop("sim/model/A-10/instrumentation/nav[2]/presets/preset[" ~ preset_num ~ "]"));
      #return;
    #}
  #}
  default_freq_startup();
  nav0_freq_update();
}

# main init
default_freq_startup = func {
  if ( ! getprop( "instrumentation/nav[2]/frequencies/selected-mhz" )) {
    setprop("instrumentation/nav[2]/frequencies/selected-mhz", 0);
  }
  selected  = getprop( "instrumentation/nav[2]/frequencies/selected-mhz" );
  if ( ! getprop( "instrumentation/nav[2]/frequencies/standby-mhz" )) {
    setprop("instrumentation/nav[2]/frequencies/standby-mhz", 0);
  }
  standby  = getprop( "instrumentation/nav[2]/frequencies/standby-mhz" );
  setprop("sim/model/A-10/instrumentation/nav[2]/presets/preset[1]", selected); 
  setprop("sim/model/A-10/instrumentation/nav[2]/presets/preset[2]", standby); 
  alt_freq_update();
}

# nav[2]: display selected-mhz on the radio set
alt_freq_update = func {
  ind_freq  = getprop( "instrumentation/nav[2]/frequencies/selected-mhz" );
  ind_freq_x10   =  int(ind_freq / 10);
  ind_freq_x1    =  int(ind_freq) - (ind_freq_x10 * 10);
  res   =  ((ind_freq - (int(ind_freq))) * 10);
  ind_freq_x01   =  int(res);
  ind_freq_x0001 =  (int(int(res * 10)/25)) * 25; # rounded to 25
  setprop("sim/model/A-10/instrumentation/nav[2]/frequencies/alt-selected-mhz-x10", ind_freq_x10);
  setprop("sim/model/A-10/instrumentation/nav[2]/frequencies/alt-selected-mhz-x1", ind_freq_x1);
  setprop("sim/model/A-10/instrumentation/nav[2]/frequencies/alt-selected-mhz-x01", ind_freq_x01);
  setprop("sim/model/A-10/instrumentation/nav[2]/frequencies/alt-selected-mhz-x0001", ind_freq_x0001);
}

# nav[0] (ILS): update selected-mhz with translated decimals
nav0_freq_update = func {
  test = getprop("instrumentation/nav[0]/frequencies/selected-mhz");
  if (! test) {
    setprop("sim/model/A-10/instrumentation/nav[0]/frequencies/freq-whole", 0);
  } else {
    setprop("sim/model/A-10/instrumentation/nav[0]/frequencies/freq-whole", test * 100);
  }
}

# nav[2]: update selected-mhz property from the dialed freq
alt_freq_to_freq = func {
  if ( ! getprop( "instrumentation/nav[2]/frequencies/selected-mhz" )) {
    setprop("instrumentation/nav[2]/frequencies/selected-mhz", 0);
  }
  ind_freq_up_x10 = getprop("sim/model/A-10/instrumentation/nav[2]/frequencies/alt-selected-mhz-x10");
  ind_freq_up_x1 = getprop("sim/model/A-10/instrumentation/nav[2]/frequencies/alt-selected-mhz-x1");
  ind_freq_up_x01 = getprop("sim/model/A-10/instrumentation/nav[2]/frequencies/alt-selected-mhz-x01");
  ind_freq_up_x0001 = getprop("sim/model/A-10/instrumentation/nav[2]/frequencies/alt-selected-mhz-x0001");
  ind_freq_up = (ind_freq_up_x10 * 10) + ind_freq_up_x1 + (ind_freq_up_x01 / 10) + ( ind_freq_up_x0001 / 1000 );
  setprop( "instrumentation/nav[2]/frequencies/selected-mhz", ind_freq_up);
}

# nav[2]: what to do when selecting an other presset on the radio set
change_preset = func {
  if ( ! getprop( "sim/model/A-10/instrumentation/nav[2]/selected-preset" )) {
    setprop( "sim/model/A-10/instrumentation/nav[2]/selected-preset", 1)
  }
  new_preset_num  = (getprop("sim/model/A-10/instrumentation/nav[2]/selected-preset") + arg[0]);
  if (arg[0] == 1) {
    if ( new_preset_num == 21 ) { new_preset_num = 1;}
  } elsif (arg[0] == -1) {
    if ( new_preset_num == 0 ) { new_preset_num = 20; }
  }
  setprop("sim/model/A-10/instrumentation/nav[2]/selected-preset", new_preset_num);
  preset_freq = getprop("sim/model/A-10/instrumentation/instrumentation/nav[2]/presets/preset[" ~ new_preset_num ~ "]");
  setprop( "sim/model/A-10/instrumentation/nav[2]/frequencies/selected-mhz", preset_freq);
  alt_freq_update();
}


# nav[2]: load displayed freq into 'non volatile memory'
# load_state is used for the load button animation
load_state = props.globals.getNode("sim/model/A-10/instrumentation/nav[2]/load-state");

load_freq = func {
  mode = getprop("sim/model/A-10/instrumentation/nav[2]/mode");
  selector = getprop("sim/model/A-10/instrumentation/nav[2]/selector");
  if ( mode == 1 ) {
    if ( selector == 3 ) {
      to_load_freq = getprop( "instrumentation/nav[2]/frequencies/selected-mhz" );
      num_preset   = getprop("sim/model/A-10/instrumentation/nav[2]/selected-preset");
      setprop("sim/model/A-10/instrumentation/nav[2]/presets/preset[" ~ num_preset ~ "]", to_load_freq);
      setprop("sim/model/A-10/instrumentation/nav[2]/load-state", 1);
      load_state.setValue(1);
      #nav_ac_state.freq_state_save();
      settimer(func { load_state.setValue(0) }, 0.5);
    }
  }
}

# used only at startup to wait for FGFS to read the saved presset.
registerTimer = func {
    settimer(freq_startup, 30);
}

# NAVIGATION INSTRUMENTATION
# --------------------------

# nav[1]: TACAN
var nav1_back = 0.0;
setlistener( "instrumentation/tacan/switch-position", func {nav1_freq_update();} );

nav1_freq_update = func {
  if ( getprop("instrumentation/tacan/switch-position") == 1 ) {
    tacan_freq = getprop( "instrumentation/tacan/frequencies/selected-mhz" );
    nav1_freq = getprop( "instrumentation/nav[1]/frequencies/selected-mhz" );
    nav1_back = nav1_freq;
    setprop("instrumentation/nav[1]/frequencies/selected-mhz", tacan_freq);
  } else {
    setprop("instrumentation/nav[1]/frequencies/selected-mhz", nav1_back);
  }
}

tacan_XYtoggle = func {
  xy_sign = getprop( "instrumentation/tacan/frequencies/selected-channel[4]" );
  if ( xy_sign == "X" ) {
    setprop( "instrumentation/tacan/frequencies/selected-channel[4]", "Y" );
  } else {
    setprop( "instrumentation/tacan/frequencies/selected-channel[4]", "X" );
  }
}

tacan_tenth_adjust = func {
  tenths = getprop( "instrumentation/tacan/frequencies/selected-channel[2]" );
  hundreds = getprop( "instrumentation/tacan/frequencies/selected-channel[1]" );
  value = (10 * tenths) + (100 * hundreds);
  adjust = arg[0];
  new_value = value + adjust;
  new_hundreds = int(new_value/100);
  new_tenths = (new_value - (new_hundreds*100))/10;
  setprop( "instrumentation/tacan/frequencies/selected-channel[1]", new_hundreds );
  setprop( "instrumentation/tacan/frequencies/selected-channel[2]", new_tenths );
}

test_button = func {
  print("button ", arg[0]);
}
