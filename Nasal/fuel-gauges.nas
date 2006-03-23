# Properties under /consumables/fuel/:
# + left-lbs        - total level of internal left tanks
# + right-lbs       - total level of internal left tanks

UPDATE_PERIOD = 0.5;

spec_xiii = func {
  setprop("/environment/test", 0 );
}

internal_fuel_by_side_totalizer = func {

  left_wing = getprop("/consumables/fuel/tank[0]/level-lbs");
  left_main = getprop("/consumables/fuel/tank[1]/level-lbs");
  right_main = getprop("/consumables/fuel/tank[2]/level-lbs");
  right_wing = getprop("/consumables/fuel/tank[3]/level-lbs");
  if (getprop("/consumables/fuel/tank[0]/level-lbs") == nil) { return registerTimer(); }
  if (getprop("/consumables/fuel/tank[1]/level-lbs") == nil) { return registerTimer(); }
  if (getprop("/consumables/fuel/tank[2]/level-lbs") == nil) { return registerTimer(); }
  if (getprop("/consumables/fuel/tank[3]/level-lbs") == nil) { return registerTimer(); }
  total_internal_left = left_wing + left_main;
  total_internal_right = right_wing + right_main;
  setprop("/consumables/fuel/left-lbs", total_internal_left);
  setprop("/consumables/fuel/right-lbs", total_internal_right);
  registerTimer();
}


registerTimer = func {
    settimer(internal_fuel_by_side_totalizer, UPDATE_PERIOD);
}

registerTimer();
