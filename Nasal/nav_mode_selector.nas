# Fairchild A-10 radio and navigation system
# ------------------------------------------
#
# Alexis BORY  < xiii ta g2ms moc >  -- Public Domain

# calls to the "save to disk" function (to keep the preseted frequencies from flight to flight)
# are commented out. See Aircraft/A-10/Nasal/nav_ac_state.nas for how to use it.

# an/arc-186
#-----------


# init
freq_startup = func {
  # nav_ac_state.freq_state_load();
  #if(getprop( "/instrumentation/nav/frequencies/selected-mhz" ) == nil) { return registerTimer(); }
  #for(i=1; i<21; i=i+1) {
    #if(getprop("/instrumentation/nav/presets/preset[" ~ i ~ "]") != 10) {
      #preset_num = getprop("/instrumentation/nav/A-10-nav-selected-preset");
      #setprop( "/instrumentation/nav/frequencies/selected-mhz" , getprop("/instrumentation/nav/presets/preset[" ~ preset_num ~ "]"));
      #return;
    #}
  #}
  default_freq_startup();
}



# default init if no saved presets
default_freq_startup = func {
  selected  = getprop( "/instrumentation/nav/frequencies/selected-mhz" );
  standby  = getprop("/instrumentation/nav/frequencies/standby-mhz");
  setprop("/instrumentation/nav/presets/preset[1]", selected); 
  setprop("/instrumentation/nav/presets/preset[2]", standby); 
  alt_freq_update();
}



# selected-mhz to display
alt_freq_update = func {
  ind_freq  = getprop( "/instrumentation/nav/frequencies/selected-mhz" );
  ind_freq_x10   =  int(ind_freq / 10);
  ind_freq_x1    =  int(ind_freq) - (ind_freq_x10 * 10);
  res   =  ((ind_freq - (int(ind_freq))) * 10);
  ind_freq_x01   =  int(res);
  ind_freq_x0001 =  (int(int(res * 10)/25)) * 25; # rounded to 25
  setprop("/instrumentation/nav/frequencies/alt-selected-mhz-x10", ind_freq_x10);
  setprop("/instrumentation/nav/frequencies/alt-selected-mhz-x1", ind_freq_x1);
  setprop("/instrumentation/nav/frequencies/alt-selected-mhz-x01", ind_freq_x01);
  setprop("/instrumentation/nav/frequencies/alt-selected-mhz-x0001", ind_freq_x0001);
}



# display to selected-mhz
alt_freq_to_freq = func {
  ind_freq_up_x10 = getprop("/instrumentation/nav/frequencies/alt-selected-mhz-x10");
  ind_freq_up_x1 = getprop("/instrumentation/nav/frequencies/alt-selected-mhz-x1");
  ind_freq_up_x01 = getprop("/instrumentation/nav/frequencies/alt-selected-mhz-x01");
  ind_freq_up_x0001 = getprop("/instrumentation/nav/frequencies/alt-selected-mhz-x0001");
  ind_freq_up = (ind_freq_up_x10 * 10) + ind_freq_up_x1 + (ind_freq_up_x01 / 10) + ( ind_freq_up_x0001 / 1000 );
  setprop( "/instrumentation/nav/frequencies/selected-mhz", ind_freq_up);
}


# no comment
change_preset = func {
  new_preset_num  = (getprop("/instrumentation/nav/A-10-nav-selected-preset") + arg[0]);
  if (arg[0] == 1) {
    if ( new_preset_num == 21 ) { new_preset_num = 1;}
  } elsif (arg[0] == -1) {
    if ( new_preset_num == 0 ) { new_preset_num = 20; }
  }
  setprop("/instrumentation/nav/A-10-nav-selected-preset", new_preset_num);
  preset_freq = getprop("/instrumentation/nav/presets/preset[" ~ new_preset_num ~ "]");
  setprop( "/instrumentation/nav/frequencies/selected-mhz", preset_freq);
  alt_freq_update();
}


# load displayed freq into non volatile memory
# load_state is used to the button animation
load_state = props.globals.getNode("/instrumentation/nav/A-10-nav-load-state");

load_freq = func {
  mode = getprop("/instrumentation/nav/A-10-nav-mode");
  selector = getprop("/instrumentation/nav/A-10-nav-selector");
  if ( mode == 1 ) {
    if ( selector == 3 ) {
      to_load_freq = getprop( "/instrumentation/nav/frequencies/selected-mhz" );
      num_preset   = getprop("/instrumentation/nav/A-10-nav-selected-preset");
      setprop("/instrumentation/nav/presets/preset[" ~ num_preset ~ "]", to_load_freq);
      setprop("/instrumentation/nav/load-state", 1);
      load_state.setValue(1);
      #nav_ac_state.freq_state_save();
      settimer(func { load_state.setValue(0) }, 0.5);
	 }
  }
}


registerTimer = func {
    settimer(freq_startup, 30);
}
