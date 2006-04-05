autotakeoff = func {

  if(getprop("/autopilot/locks/auto-take-off") == "enabled") {
    ato_start();
  }

}
#--------------------------------------------------------------------
ato_start = func {

  hdgdeg = getprop("/orientation/heading-deg");

  setprop("/controls/flight/flaps", 1.0);
  setprop("/controls/flight/spoilers", 0.0);
  setprop("/controls/gear/brake-left", 0.0);
  setprop("/controls/gear/brake-right", 0.0);
  setprop("/controls/gear/brake-parking", 0.0);

  setprop("/autopilot/settings/ground-roll-heading-deg", hdgdeg);
  setprop("/autopilot/settings/true-heading-deg", hdgdeg);
  setprop("/autopilot/settings/target-climb-rate-fps", 30);
  setprop("/autopilot/settings/target-speed-kt", 320);
  setprop("/autopilot/settings/target-roll-deg", 0);

  setprop("/autopilot/locks/auto-take-off", "engaged");
  setprop("/autopilot/locks/altitude", "pitch-hold");
  setprop("/autopilot/locks/speed", "speed-with-throttle");
  setprop("/autopilot/locks/rudder-control", "rudder-hold");

  setprop("/autopilot/internal/target-aileron-deflection-norm", 0);

  toiptdeg = getprop("/autopilot/settings/take-off-initial-pitch-deg");
  setprop("/autopilot/settings/target-pitch-deg", toiptdeg);

  # Start the main loop.
  ato_mainloop();   # Main loop

}
#--------------------------------------------------------------------
ato_mainloop = func {

  ato_mode();
  ato_spddep();

  # Re-schedule the next loop if the Take-Off function is engaged.
  if(getprop("/autopilot/locks/auto-take-off") == "engaged") {
    settimer(ato_mainloop, 0.2);
  }

}
#--------------------------------------------------------------------
ato_mode = func {

  agl = getprop("/position/altitude-agl-ft");
  if(agl > 50) {
    setprop("/controls/gear/gear-down", "false");
    setprop("/autopilot/locks/rudder-control", "reset");

    interpolate("/controls/flight/rudder", 0, 10);

    if(getprop("/controls/flight/flaps") > 0.99) {
      setprop("/controls/flight/flaps", 0.82);
    }
  }
}

#--------------------------------------------------------------------
ato_spddep = func {

  # This script controls speed dependent actions.
  airspeed = getprop("/velocities/airspeed-kt");
  grrtkt = getprop("/autopilot/settings/ground-roll-rotate-speed-kts");
  if(airspeed < grrtkt) {
    # Do nothing until airspeed > groud roll rotation kts
  } else {
    if(airspeed < 180) {
      tofptdeg = getprop("/autopilot/settings/take-off-final-pitch-deg");
      setprop("/autopilot/settings/target-pitch-deg", tofptdeg);
      setprop("/autopilot/locks/heading", "wing-leveler");
    } else {
      if(airspeed < 190) {
        setprop("/controls/flight/flaps", 0.64);
      } else {
        if(airspeed < 200) {
          setprop("/controls/flight/flaps", 0.48);
        } else {
          if(airspeed < 220) {
            setprop("/controls/flight/flaps", 0.32);
          } else {
            if(airspeed < 240) {
              setprop("/controls/flight/flaps", 0.16);
            } else {
              if(airspeed < 250) {
                setprop("/controls/flight/flaps", 0.0);
              } else {
                setprop("/autopilot/locks/heading", "true-heading-hold");
                setprop("/autopilot/locks/speed", "mach-with-throttle");
                setprop("/autopilot/locks/altitude", "mach-climb");
                setprop("/autopilot/locks/auto-take-off", "disabled");
              }
            }
          }
        }
      }
    }
  }

}
#--------------------------------------------------------------------
autoland = func {

  if(getprop("/autopilot/locks/auto-landing") == "enabled") {
    atl_start();
  }

}
#--------------------------------------------------------------------
atl_start = func {

  setprop("/autopilot/locks/auto-landing", "engaged");

  setprop("/autopilot/settings/target-climb-rate-fps", 0);
  setprop("/autopilot/locks/altitude", "vfps-hold");

  crspdkt = getprop("/autopilot/settings/auto-landing-circuit-speed-kt");
  setprop("/autopilot/settings/target-speed-kt", crspdkt);
  setprop("/autopilot/locks/speed", "speed-with-throttle");

  setprop("/autopilot/locks/heading", "nav1-hold");
  
  # Start the main loop
  atl_mainloop();

}
#--------------------------------------------------------------------
atl_mainloop = func {

  altaglft = getprop("/position/altitude-agl-ft");
  tdnaltft = getprop("/autopilot/settings/auto-landing-touchdown-alt-ft");

  if(altaglft > tdnaltft) {
    atl_glideslope();
  } else {
    atl_touchdown();
  }
  
  if(getprop("/autopilot/locks/auto-landing") == "engaged") {
    settimer(atl_mainloop, 0.5);
  }

}
#--------------------------------------------------------------------
atl_glideslope = func {
  
  gs1vfps = getprop("/instrumentation/nav[0]/gs-rate-of-climb");
  setprop("/autopilot/settings/target-climb-rate-fps", gs1vfps);
  
  if(gs1vfps < 0) {
    apaoadeg = getprop("/autopilot/settings/approach-aoa-deg");
    setprop("/autopilot/settings/target-aoa-deg", apaoadeg);
    setprop("/autopilot/locks/aoa", "aoa-with-speed");

    kias = getprop("/velocities/airspeed-kt");
    if(kias < 170) {
      setprop("/controls/flight/flaps", 1.0);
      setprop("/controls/gear/gear-down", "true");
    } else {
      if(kias < 180) {
        setprop("/controls/flight/flaps", 0.9);
      } else {
        if(kias < 190) {
          setprop("/controls/flight/flaps", 0.8);
        } else {
          if(kias < 200) {
            setprop("/controls/flight/spoilers", 0.5);
            setprop("/controls/flight/flaps", 0.6);
          } else {
            if(kias < 210) {
              setprop("/controls/flight/spoilers", 0.6);
              setprop("/controls/flight/flaps", 0.4);
            } else {
              if(kias < 220) {
                setprop("/controls/flight/spoilers", 0.8);
                setprop("/controls/flight/flaps", 0.2);
              } else {
                setprop("/controls/flight/spoilers", 1.0);
              }
            }
          }
        }
      }
    }
  }

}
#--------------------------------------------------------------------
atl_touchdown = func {

  # Get the agl, kias, vfps & heading.
  agl = getprop("/position/altitude-agl-ft");
  kias = getprop("/velocities/airspeed-kt");
  vfps = getprop("/velocities/vertical-speed-fps");

  setprop("/autopilot/locks/aoa", "off");
  setprop("/autopilot/locks/heading", "");

  if(agl < 0.1) {
    setprop("/controls/gear/brake-left", 0.4);
    setprop("/controls/gear/brake-right", 0.4);
    setprop("/autopilot/locks/auto-landing", "disabled");
    setprop("/autopilot/locks/auto-take-off", "enabled");
    setprop("/autopilot/locks/altitude", "none");
    setprop("/autopilot/settings/ground-roll-heading-deg", -999.9);
    interpolate("/controls/flight/elevator-trim", 0, 6.0);
  }
  if(agl < 1) {
    setprop("/autopilot/settings/target-climb-rate-fps", -2);
    setprop("/autopilot/locks/speed", "none");
    setprop("/controls/engines/engine[0]/throttle", 0);
    setprop("/controls/engines/engine[1]/throttle", 0);
    setprop("/controls/flight/spoilers", 1);
  } else {
    if(agl < -3) {
      setprop("/autopilot/settings/target-climb-rate-fps", -3);
    } else {
      if(agl < 4) {
        if(vfps < -4) {
          setprop("/autopilot/settings/target-climb-rate-fps", -4);
        }
      } else {
        if(agl < 8) {
          if(vfps < -5) {
            setprop("/autopilot/settings/target-climb-rate-fps", -5);
          }
        } else {
          if(agl < 16) {
            if(vfps < -6) {
              setprop("/autopilot/settings/target-climb-rate-fps", -6);
            }
          } else {
            if(agl < 32) {
              if(vfps < -8) {
                setprop("/autopilot/settings/target-climb-rate-fps", -8);
              }
            } else {
              if(vfps < -10) {
                setprop("/autopilot/settings/target-climb-rate-fps", -10);
              }
            }
          }
        }
      }
    }
  }

}
#--------------------------------------------------------------------
ap_common_aileron_monitor = func {
  curr_hh_state = getprop("/autopilot/locks/heading");

  if(curr_hh_state == "wing-leveler") {
    setprop("/autopilot/locks/common-aileron-control", "engaged");
    setprop("/autopilot/settings/target-roll-deg", 0);
    setprop("/autopilot/locks/ca-roll-hold", "engaged");
    setprop("/autopilot/locks/ca-true-heading-hold", "off");
    setprop("/autopilot/locks/ca-dg-heading-hold", "off");
    setprop("/autopilot/locks/ca-nav1-hold", "off");
    setprop("/autopilot/locks/ca-nav1-fa-hold", "off");
  } else {
    if(curr_hh_state == "roll-hold") {
      setprop("/autopilot/locks/common-aileron-control", "engaged");
      setprop("/autopilot/locks/ca-roll-hold", "engaged");
      setprop("/autopilot/locks/ca-true-heading-hold", "off");
      setprop("/autopilot/locks/ca-dg-heading-hold", "off");
      setprop("/autopilot/locks/ca-nav1-hold", "off");
      setprop("/autopilot/locks/ca-nav1-fa-hold", "off");
    } else {
      if(curr_hh_state == "true-heading-hold") {
        setprop("/autopilot/locks/common-aileron-control", "engaged");
        setprop("/autopilot/locks/ca-roll-hold", "engaged");
        setprop("/autopilot/locks/ca-true-heading-hold", "engaged");
        setprop("/autopilot/locks/ca-dg-heading-hold", "off");
        setprop("/autopilot/locks/ca-nav1-hold", "off");
        setprop("/autopilot/locks/ca-nav1-fa-hold", "off");
      } else {
        if(curr_hh_state == "dg-heading-hold") {
          setprop("/autopilot/locks/common-aileron-control", "engaged");
          setprop("/autopilot/locks/ca-roll-hold", "engaged");
          setprop("/autopilot/locks/ca-true-heading-hold", "off");
          setprop("/autopilot/locks/ca-dg-heading-hold", "engaged");
          setprop("/autopilot/locks/ca-nav1-hold", "off");
          setprop("/autopilot/locks/ca-nav1-fa-hold", "off");
        } else {
          if(curr_hh_state == "nav1-hold") {
            setprop("/autopilot/locks/common-aileron-control", "engaged");
            setprop("/autopilot/locks/ca-roll-hold", "engaged");
            setprop("/autopilot/locks/ca-true-heading-hold", "off");
            setprop("/autopilot/locks/ca-dg-heading-hold", "off");
            setprop("/autopilot/locks/ca-nav1-hold", "engaged");
            setprop("/autopilot/locks/ca-nav1-fa-hold", "off");
          } else {
            if(curr_hh_state == "nav1-hold-fa") {
              setprop("/autopilot/locks/common-aileron-control", "engaged");
              setprop("/autopilot/locks/ca-roll-hold", "engaged");
              setprop("/autopilot/locks/ca-true-heading-hold", "off");
              setprop("/autopilot/locks/ca-dg-heading-hold", "off");
              setprop("/autopilot/locks/ca-nav1-hold", "off");
              setprop("/autopilot/locks/ca-nav1-fa-hold", "engaged");
            } else {
              if(curr_hh_state == "testing") {
                setprop("/autopilot/locks/common-aileron-control", "engaged");
                setprop("/autopilot/locks/ca-roll-hold", "off");
                setprop("/autopilot/locks/ca-true-heading-hold", "off");
                setprop("/autopilot/locks/ca-dg-heading-hold", "off");
                setprop("/autopilot/locks/ca-nav1-hold", "off");
                setprop("/autopilot/locks/ca-nav1-fa-hold", "off");
              } else {
                setprop("/autopilot/locks/common-aileron-control", "off");
                setprop("/autopilot/locks/ca-roll-hold", "off");
                setprop("/autopilot/locks/ca-true-heading-hold", "off");
                setprop("/autopilot/locks/ca-dg-heading-hold", "off");
                setprop("/autopilot/locks/ca-nav1-hold", "off");
                setprop("/autopilot/locks/ca-nav1-fa-hold", "off");
              }
            }
          }
        }
      }
    }
  } 
  settimer(ap_common_aileron_monitor, 0.5);
}
#--------------------------------------------------------------------
ap_common_elevator_monitor = func {
  curr_ah_state = getprop("/autopilot/locks/altitude");

  if(curr_ah_state == "altitude-hold") {
    setprop("/autopilot/locks/common-elevator-control", "engaged");
    setprop("/autopilot/locks/ce-altitude-hold", "engaged");
    setprop("/autopilot/locks/ce-aoa-hold", "off");
    setprop("/autopilot/locks/ce-mach-climb-hold", "off");
    setprop("/autopilot/locks/ce-pitch-hold", "off");
    setprop("/autopilot/locks/ce-terrain-follow-hold", "off");
    setprop("/autopilot/locks/ce-vfps-hold", "engaged");
  } else {
    if(curr_ah_state == "terrain-follow") {
      setprop("/autopilot/locks/common-elevator-control", "engaged");
      setprop("/autopilot/locks/ce-altitude-hold", "off");
      setprop("/autopilot/locks/ce-aoa-hold", "off");
      setprop("/autopilot/locks/ce-mach-climb-hold", "off");
      setprop("/autopilot/locks/ce-pitch-hold", "off");
      setprop("/autopilot/locks/ce-terrain-follow-hold", "engaged");
      setprop("/autopilot/locks/ce-vfps-hold", "engaged");
    } else {
      if(curr_ah_state == "mach-climb") {
        setprop("/autopilot/locks/common-elevator-control", "engaged");
        setprop("/autopilot/locks/ce-altitude-hold", "off");
        setprop("/autopilot/locks/ce-aoa-hold", "off");
        setprop("/autopilot/locks/ce-mach-climb-hold", "engaged");
        setprop("/autopilot/locks/ce-pitch-hold", "off");
        setprop("/autopilot/locks/ce-terrain-follow-hold", "off");
        setprop("/autopilot/locks/ce-vfps-hold", "engaged");
      } else {
        if(curr_ah_state == "vfps-hold") {
          setprop("/autopilot/locks/common-elevator-control", "engaged");
          setprop("/autopilot/locks/ce-altitude-hold", "off");
          setprop("/autopilot/locks/ce-aoa-hold", "off");
          setprop("/autopilot/locks/ce-mach-climb-hold", "off");
          setprop("/autopilot/locks/ce-pitch-hold", "off");
          setprop("/autopilot/locks/ce-terrain-follow-hold", "off");
          setprop("/autopilot/locks/ce-vfps-hold", "engaged");
        } else {
          if(curr_ah_state == "pitch-hold") {
            setprop("/autopilot/locks/common-elevator-control", "engaged");
            setprop("/autopilot/locks/ce-altitude-hold", "off");
            setprop("/autopilot/locks/ce-aoa-hold", "off");
            setprop("/autopilot/locks/ce-mach-climb-hold", "off");
            setprop("/autopilot/locks/ce-pitch-hold", "engaged");
            setprop("/autopilot/locks/ce-terrain-follow-hold", "off");
            setprop("/autopilot/locks/ce-vfps-hold", "off");
          } else {
            if(curr_ah_state == "testing") {
              setprop("/autopilot/locks/common-elevator-control", "engaged");
              setprop("/autopilot/locks/ce-altitude-hold", "off");
              setprop("/autopilot/locks/ce-aoa-hold", "off");
              setprop("/autopilot/locks/ce-mach-climb-hold", "off");
              setprop("/autopilot/locks/ce-pitch-hold", "off");
              setprop("/autopilot/locks/ce-terrain-follow-hold", "off");
              setprop("/autopilot/locks/ce-vfps-hold", "off");
            } else {
              setprop("/autopilot/locks/common-elevator-control", "off");
              setprop("/autopilot/locks/ce-altitude-hold", "off");
              setprop("/autopilot/locks/ce-aoa-hold", "off");
              setprop("/autopilot/locks/ce-mach-climb-hold", "off");
              setprop("/autopilot/locks/ce-pitch-hold", "off");
              setprop("/autopilot/locks/ce-terrain-follow-hold", "off");
              setprop("/autopilot/locks/ce-vfps-hold", "off");
            }
          }
        }
      }
    }
  } 
  settimer(ap_common_elevator_monitor, 0.5);
}
#--------------------------------------------------------------------
zero_ext_tanks = func {
  # This script is called for the 'clean' configuration A-10 to zero
  # the fuel levels in the external ferry tanks.  It simply calls
  # a child script to actually zero the tanks after a delay of 5
  # seconds.
  settimer(zero_ext_tanks_sub, 5);
  start_up();
}
#--------------------------------------------------------------------
zero_ext_tanks_sub = func {
  # This script is called for the 'clean' configuration A-10 to zero
  # the fuel levels in the external ferry tanks.
  setprop("/consumables/fuel/tank[4]/level-gal_us", 0);
  setprop("/consumables/fuel/tank[5]/level-gal_us", 0);
  setprop("/consumables/fuel/tank[6]/level-gal_us", 0);
  setprop("/consumables/fuel/tank[4]/level-lbs", 0);
  setprop("/consumables/fuel/tank[5]/level-lbs", 0);
  setprop("/consumables/fuel/tank[6]/level-lbs", 0);
  setprop("/consumables/fuel/tank[4]/selected", "false");
  setprop("/consumables/fuel/tank[5]/selected", "false");
  setprop("/consumables/fuel/tank[6]/selected", "false");
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
fire_gau8a = func {
  setprop("ai/submodels/GAU-8A", 1);
  ammo_cnt = getprop("ai/submodels/submodel[1]/count");
  ammo_wgt = ammo_cnt * 2;
  setprop("yasim/weights/ammunition-weight-lbs", ammo_wgt);
}
#--------------------------------------------------------------------
cfire_gau8a = func {
  setprop("ai/submodels/GAU-8A", 0);
}
#--------------------------------------------------------------------
initialise_drop_view_pos = func {
  eyelatdeg = getprop("/position/latitude-deg");
  eyelondeg = getprop("/position/longitude-deg");
  eyealtft = getprop("/position/altitude-ft") + 20;
  setprop("/sim/view[6]/latitude-deg", eyelatdeg);
  setprop("/sim/view[6]/longitude-deg", eyelondeg);
  setprop("/sim/view[6]/altitude-ft", eyealtft);
}
#--------------------------------------------------------------------
update_drop_view_pos = func {
  eyelatdeg = getprop("/position/latitude-deg");
  eyelondeg = getprop("/position/longitude-deg");
  eyealtft = getprop("/position/altitude-ft") + 20;
  interpolate("/sim/view[6]/latitude-deg", eyelatdeg, 5);
  interpolate("/sim/view[6]/longitude-deg", eyelondeg, 5);
  interpolate("/sim/view[6]/altitude-ft", eyealtft, 5);
}
#--------------------------------------------------------------------
altimeter_monitor = func {
  ind_alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
  alt_ftx5 = int(ind_alt / 10000);
  ind_alt = ind_alt - (alt_ftx5 * 10000);
  alt_ftx4 = int(ind_alt / 1000);
  ind_alt = ind_alt - (alt_ftx4 * 1000);
  alt_ftx3 = int(ind_alt / 100);
  ind_alt = ind_alt - (alt_ftx3 * 100);
  alt_ftx2 = int(ind_alt / 10);

  setprop("/instrumentation/altimeter/indicated-altitude-ft-x2", alt_ftx2);
  setprop("/instrumentation/altimeter/indicated-altitude-ft-x3", alt_ftx3);
  setprop("/instrumentation/altimeter/indicated-altitude-ft-x4", alt_ftx4);
  setprop("/instrumentation/altimeter/indicated-altitude-ft-x5", alt_ftx5);

  settimer(altimeter_monitor, 0.2);
  
}
#--------------------------------------------------------------------
start_up = func {
  settimer(initialise_drop_view_pos, 5);
  settimer(ap_common_aileron_monitor, 0.5);
  settimer(ap_common_elevator_monitor, 0.5);
  settimer(altimeter_monitor, 0.5);
}
#--------------------------------------------------------------------
