autotakeoff = func {
  ato_start();      # Initiation stuff.
  ato_mode();       # Take-off/Climb-out mode handler.
  ato_spddep();     # Speed dependent actions.
  
  # Re-schedule the next call
  if(getprop("/autopilot/locks/auto-take-off") != "Enabled") {
    print("Auto Take-Off disabled");
  } else {
    settimer(autotakeoff, 0.5);
  }
}
#--------------------------------------------------------------------
ato_start = func {
  # This script checks that the ground-roll-heading has been reset
  # (<-999) and that the a/c is on the ground.
  if(getprop("/autopilot/settings/ground-roll-heading-deg") < -999) {
    if(getprop("/position/altitude-agl-ft") < 0.01) {
      hdgdeg = getprop("/orientation/heading-deg");
      setprop("/autopilot/settings/ground-roll-heading-deg", hdgdeg);
      setprop("/autopilot/settings/true-heading-deg", hdgdeg);
      setprop("/autopilot/settings/target-speed-kt", 320);
      setprop("/controls/flight/flaps", 0.64);
      setprop("/autopilot/locks/altitude", "ground-roll");
      setprop("/autopilot/locks/speed", "speed-with-throttle");
      setprop("/autopilot/locks/heading", "wing-leveler");
      setprop("/autopilot/locks/rudder-control", "rudder-hold");
    }
  }
}
#--------------------------------------------------------------------
ato_mode = func {
  # This script sets the auto-takeoff mode and handles the switch
  # to climb-out mode.
  if(getprop("position/altitude-agl-ft") > 50) {
    setprop("/autopilot/locks/altitude", "climb-out");
    setprop("/controls/gear/gear-down", "false");
    setprop("/autopilot/locks/rudder-control", "reset");
    interpolate("/controls/flight/rudder", 0, 10);
  } else {
    if(getprop("/velocities/airspeed-kt") > 100) {
      setprop("/autopilot/locks/altitude", "take-off");
    }
  }
}
#--------------------------------------------------------------------
ato_spddep = func {
  # This script controls speed dependent actions.
  airspeed = getprop("/velocities/airspeed-kt");
  if(airspeed < 150) {
    # Do not do anything until airspeed > 150kt.
  } else {
    if(airspeed < 160) {
      setprop("/controls/flight/flaps", 0.48);
    } else {
      if(airspeed < 165) {
        setprop("/controls/flight/flaps", 0.32);
      } else {
        if(airspeed < 170) {
          setprop("/controls/flight/flaps", 0.16);
        } else {
          if(airspeed < 175) {
            setprop("/controls/flight/flaps", 0.08);
          } else {
            if(airspeed < 180) {
              setprop("/controls/flight/flaps", 0);
            } else {
              # Switch to true-heading-hold, switch to Mach-Hold
              # throttle mode, mach-hold-climb mode and disable
              # Take-Off mode.
              setprop("/autopilot/locks/heading", "true-heading-hold");
              setprop("/autopilot/locks/speed", "mach-with-throttle");
              setprop("/autopilot/locks/altitude", "mach-climb");
              setprop("/autopilot/locks/auto-take-off", "Disabled");
            }
          }
        }
      }
    }
  }
}
#--------------------------------------------------------------------
autoland = func {
  # Re-schedule the next loop if the Landing function is enabled.
  if(getprop("/autopilot/locks/auto-landing") != "Enabled") {
    print("Auto Landing disabled");
  } else {
    settimer(autoland, 0.5);
  }

  # Get the agl, kias, vfps & heading.
  agl = getprop("/position/altitude-agl-ft");
  kias = getprop("/velocities/airspeed-kt");
  vfps = getprop("/velocities/vertical-speed-fps");
  hdgdeg = getprop("/orientation/heading-deg");

  if(getprop("/autopilot/settings/target-speed-kt") > 240) {
    setprop("/autopilot/settings/target-speed-kt", 240);
  }
  if(getprop("/autopilot/locks/heading") != "nav1-hold") {
    setprop("/autopilot/locks/heading", "nav1-hold");
  }

  # Depending on alt...
  # Glide Slope Phase
  if(agl > 60) {
    setprop("/autopilot/locks/altitude", "gs1-hold");
    if(kias < 155) {
      setprop("/autopilot/locks/AoA-lock", "Engaged");
    } else {
      if(kias < 170) {
        setprop("/controls/flight/flaps", 1.0);
      } else {
        if(kias < 180) {
          setprop("/controls/flight/flaps", 0.82);
          setprop("/controls/flight/spoilers", 0);
          setprop("/controls/gear/gear-down", "true");
        } else {
          if(kias < 190) {
            setprop("/controls/flight/flaps", 0.64);
          } else {
            if(kias < 200) {
              setprop("/controls/flight/flaps", 0.48);
            } else {
              if(kias < 210) {
                setprop("/controls/flight/flaps", 0.32);
                setprop("/controls/flight/spoilers", 0.6);
              } else {
                if(kias < 220) {
                  setprop("/controls/flight/flaps", 0.16);
                } else {
                  if(kias < 230) {
                    setprop("/controls/flight/flaps", 0.08);
                  } else {
                    if(vfps < -15) {
                      setprop("/autopilot/settings/target-speed-kt", 150);
                      setprop("/controls/flight/spoilers", 0.8);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  } else {
    # Touch Down Phase
    setprop("/autopilot/locks/AoA-lock", "Off");
    setprop("/autopilot/locks/altitude", "Touch Down");
    setprop("/autopilot/locks/speed", "Off");
    setprop("/autopilot/locks/heading", "wing-leveler");
  }
  if(agl < 0.1) {
    # Disable the AP nav1 heading hold, deploy the spoilers and cut the
    # throttles.
    setprop("/autopilot/locks/heading", "Off");
    setprop("/controls/flight/spoilers", 1);
    setprop("/controls/engines/engine[0]/throttle", 0);
    setprop("/controls/engines/engine[1]/throttle", 0);
  }
  if(agl < 0.01) {
    # Brakes on, Rudder heading hold on & disable IL mode.
    setprop("/controls/gear/brake-left", 0.4);
    setprop("/controls/gear/brake-right", 0.4);
#    setprop("/autopilot/settings/ground-roll-heading-deg", hdgdeg);
#    setprop("/autopilot/locks/rudder-control", "rudder-hold");
    setprop("/autopilot/locks/auto-landing", "Disabled");
    setprop("/autopilot/locks/auto-take-off", "Enabled");
    setprop("/autopilot/locks/altitude", "none");
    setprop("/autopilot/settings/ground-roll-heading-deg", -999.9);
    interpolate("/controls/flight/elevator-trim", 0, 6.0);
  }
}
#--------------------------------------------------------------------
zero_ext_tanks = func {
  # This script is called for the 'clean' configuration A-10 to zero
  # the fuel levels in the external ferry tanks.  It simply calls
  # a child script to actually zero the tanks after a delay of 5
  # seconds.
  settimer(zero_ext_tanks_sub, 5);
}
#--------------------------------------------------------------------
zero_ext_tanks_sub = func {
  # This script is called for the 'clean' configuration A-10 to zero
  # the fuel levels in the external ferry tanks.
  setprop("/consumables/fuel/tank[3]/level-gal_us", 0);
  setprop("/consumables/fuel/tank[4]/level-gal_us", 0);
  setprop("/consumables/fuel/tank[5]/level-gal_us", 0);
  setprop("/consumables/fuel/tank[3]/level-lbs", 0);
  setprop("/consumables/fuel/tank[4]/level-lbs", 0);
  setprop("/consumables/fuel/tank[5]/level-lbs", 0);
  setprop("/consumables/fuel/tank[3]/selected", "false");
  setprop("/consumables/fuel/tank[4]/selected", "false");
  setprop("/consumables/fuel/tank[5]/selected", "false");
}
#--------------------------------------------------------------------
toggle_traj_mkr = func {
  if(getprop("ai/submodels/trajectory-markers") < 1) {
    setprop("ai/submodels/trajectory-markers", 1);
  } else {
    setprop("ai/submodels/trajectory-markers", 0);
  }
}
#--------------------------------------------------------------------
