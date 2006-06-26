# Power controls
# --------------

inverter_switch = func {
  input = arg[0];
  if (input == 1) {
    inverter_switch_up();
  } else {
    inverter_switch_down();
  }
}

inverter_switch_up = func {
  if (getprop("controls/switches/inverter") == 0) {
    setprop("controls/switches/inverter", 1);
  } elsif (getprop("controls/switches/inverter") == 1) {
    setprop("controls/switches/inverter", 2);
  }
}
inverter_switch_down = func {
  if (getprop("controls/switches/inverter") == 2) {
    setprop("controls/switches/inverter", 1);
  } elsif (getprop("controls/switches/inverter") == 1) {
    setprop("controls/switches/inverter", 0);
  }
}



# FUEL AND PWR MANGEMENT LOOP
# ---------------------------
# Properties under /consumables/fuel/:
# + left-lbs        - total level of internal left tanks
# + right-lbs       - total level of internal left tanks

UPDATE_PERIOD = 0.05;
ENG_COEFF = 1;
ITT_COEFF = 1;

main_power_loop = func {
  # wait for the props-three to be populated
  if (getprop("engines/engine/out-of-fuel") == nil) { return registerTimer() };

  # used for taxiing sound
  setprop("velocities/ground-speed-kt", ground_speed());
  # apu management
  
  # fuel management
  fuel_totalizer();
  
  AllEngines = props.globals.getNode("engines").getChildren("engine");
  foreach(e; AllEngines) {
    if(e.getNode("engine-num") != nil) {
      engine_num_node = e.getNode("engine-num");
      out_of_fuel_node = e.getNode("out-of-fuel");
      running_node = e.getNode("A-10-alt-running");
      #start state
      
      # stop process
      # we should be able to stop for other reasons than fuel shortage
      stop_it(engine_num_node, out_of_fuel_node, running_node);
      x = e.getNode("prop-thrust", 1).getValue();
      x = x * ENG_COEFF;
      e.getNode("A-10-alt-prop-thrust", 1).setDoubleValue(x);
      y = e.getNode("n2", 1).getValue();
      y = y * ENG_COEFF;
      e.getNode("A-10-alt-n2", 1).setDoubleValue(y);
      z = e.getNode("n1", 1).getValue();
      z = z * ENG_COEFF;
      e.getNode("A-10-alt-n1", 1).setDoubleValue(z);
    }
  }
  registerTimer();
}



stop_it = func {
    # maybe stop_it should gess (thanks to the args) wich kind
    # of stop we should simulate
  if(arg[1].getValue()) {
    setprop("instrumentation/A-10-warnings/master-caution", 1);
    arg[2].setBoolValue(0);
    if ( ENG_COEFF > 0.003 ) {
      ENG_COEFF = ENG_COEFF - 0.005;
    }
  } else {
      ENG_COEFF = 1;
  }
}

fuel_totalizer = func {
  left_wing = getprop("consumables/fuel/tank[0]/level-lbs");
  left_main = getprop("consumables/fuel/tank[1]/level-lbs");
  right_main = getprop("consumables/fuel/tank[2]/level-lbs");
  right_wing = getprop("consumables/fuel/tank[3]/level-lbs");
  total_int_left = left_wing + left_main;
  total_int_right = right_wing + right_main;
  setprop("consumables/fuel/int-left-lbs", total_int_left);
  setprop("consumables/fuel/int-right-lbs", total_int_right);
  diff_lbs = abs(right_main - left_main);
  setprop("consumables/fuel/diff-lbs", diff_lbs);
}

ground_speed = func {
  nfps = getprop("velocities/speed-north-fps");
  efps = getprop("velocities/speed-east-fps");
  vfps =  math.sqrt((nfps * nfps) + (efps * efps));
  # 1 kph = 1 fps / 6080.27 * 3600 
  vkph = vfps * 0.59207897;
  return(vkph);
}



registerTimer = func {
  settimer(main_power_loop, UPDATE_PERIOD);
}

registerTimer();
