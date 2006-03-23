# used to the animation of the landing gear handle


setlistener( "/controls/gear/gear-down", func {ldg_hdl_main();} );

ldg_hdl_main = func {
  if ( getprop("/controls/gear/gear-down") == 1 ) {
    if ( getprop("/controls/gear/A-10-landing-gear-hdl-anim") > -1 ) {
        ldg_hdl_anim(-1); # move it down
    }
  } else {
    if ( getprop("/controls/gear/A-10-landing-gear-hdl-anim") < 0 ) {
      ldg_hdl_anim(1); # move it up
    }
  }
}


ldg_hdl_anim = func {
  ldg_hdl_anim_anim = getprop("/controls/gear/A-10-landing-gear-hdl-anim");
  incr = arg[0]/10;
  ldg_hdl_anim_anim = ldg_hdl_anim_anim + incr;

  # stop anim when handle up 
  if (( arg[0] = 1 ) and ( ldg_hdl_anim_anim >= 0 )){
    setprop("/controls/gear/A-10-landing-gear-hdl-anim", 0);

  # stop anim when handle down
  } elsif  (( arg[0] = -1 ) and ( ldg_hdl_anim_anim <= -1 )){
    setprop("/controls/gear/A-10-landing-gear-hdl-anim", -1);

  # continue anim
  } else {
    setprop("/controls/gear/A-10-landing-gear-hdl-anim", ldg_hdl_anim_anim);
    settimer( ldg_hdl_main, 0.05 );
  }
}












