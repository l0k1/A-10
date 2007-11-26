# used to the animation of the landing gear handle


setlistener( "controls/gear/gear-down", func {ldg_hdl_main();} );

var ld_hdl = props.globals.getNode("sim/model/A-10/controls/gear/ld-gear-handle-anim", 1);

ldg_hdl_main = func {
	pos = ld_hdl.getValue();
	if ( getprop("controls/gear/gear-down") == 1 ) {
		if ( pos > -1 ) {
			ldg_hdl_anim(-1, pos);
		}
	} else {
		if ( pos < 0 ) {
		  ldg_hdl_anim(1, pos);
		}
	}
}


var ldg_hdl_anim = func {
	var incr = arg[0]/10;
	var pos = arg[1] + incr;
	if (( arg[0] = 1 ) and ( pos >= 0 )){    
		ld_hdl.setDoubleValue(0);
	} elsif  (( arg[0] = -1 ) and ( pos <= -1 )) {
		ld_hdl.setDoubleValue(-1);
	} else {
		ld_hdl.setDoubleValue(pos);
		settimer( ldg_hdl_main, 0.05 );
	}
}
