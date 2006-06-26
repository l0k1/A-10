# controls:
# - controls/APU/off-start-switch
# - apu's start/stop animation
# - systems/apu/start-state
# - system/apu/rpm
# - system/apu/tmp

off_start_switch = func {
  input = arg[0];
  if (input == 1) {
    setprop("controls/APU/off-start-switch", 1);
    settimer( test_start, 0.5);
  }
  elsif (input == -1) { test_stop() }
}

test_start = func {
  setprop("controls/APU/off-start-switch", 1);
  volts = getprop("systems/electrical/outputs/apu-starter[0]");
  # we need electric power
  # we need fuel: L main (aft) tank plus DC pump
  # we shouldn't be allready running
  if ( volts > 23.0 ) {
    left_main = getprop("consumables/fuel/tank[1]/level-lbs");
    start_state = getprop("systems/apu/start-state");
    if (( left_main > 10.0 ) and ( start_state < 1 )) {
      transient_start_seq(0.05, start_state);
      # rpm increase during around 60 sec up to 100%
      rpm = (math.sin( ( start_state * 3 ) + 4.7 )+1) * 48;
      setprop( "systems/apu/rpm", rpm );
      temp = getprop("systems/apu/temp");
      # temp stabilize after 30 sec around 600°C
      if (start_state < 0.52 ) {
        new_temp = (((atan((start_state*85.5)-9)+(math.sin(start_state*9)*0.39))/4.2)+0.35) * 950;
        setprop("systems/apu/temp", new_temp);
      }
    }
  }
}

test_stop = func {
  rpm_stop = 1;
  temp_stop = 1;
  setprop("controls/APU/off-start-switch", 0);
  start_state = getprop("systems/apu/start-state");
  temp = getprop("systems/apu/temp");
  rpm = getprop( "systems/apu/rpm");
  if ( rpm > 0.3 ) {
    new_rpm = rpm - 0.3;
    setprop( "systems/apu/rpm", new_rpm );
  } else {
    rpm_stop = 0;
  }
  if ( temp > 10 ) {
    new_temp = temp - 0.5;
    #print("temp = ", temp);
    setprop("systems/apu/temp", new_temp);
  } else {
    temp_stop = 0;
  }
  if (temp_stop or rpm_stop) {
    transient_stop_seq(0.04);
  } else {
    setprop( "systems/apu/start-state", 0 );
  }
}

transient_start_seq = func {
  speed = arg[0];
  start_state = arg[1];
  new_start_state = start_state + 0.004;
  setprop( "systems/apu/start-state", new_start_state );
  settimer( test_start, speed);
}

transient_stop_seq = func {
  speed = arg[0];
  settimer( test_stop, speed);
}

atan = func {
  return math.atan2(arg[0], 1);
}
