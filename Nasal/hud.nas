var hud_mode_knob_pos = props.globals.getNode("sim/model/A-10/controls/hud/mode-selector");



var speed_east_fps  = props.globals.getNode("/velocities/speed-east-fps");
var speed_north_fps = props.globals.getNode("/velocities/speed-north-fps");
var speed_down_fps  = props.globals.getNode("/velocities/speed-down-fps");
var agl_ft          = props.globals.getNode("/position/altitude-agl-ft");
var pitch  		    = props.globals.getNode("/orientation/pitch-deg");
var ccip_deviation_m  		= props.globals.getNode("sim/model/A-10/instrumentation/hud/ccip_dev_m", 1);

lbs_to_slugs    = 0.031080950172;   # conversion factor.
var D2R         = math.pi / 180;

var UPDATE_PERIOD = 0.2;


# main loop ####################
update_loop = func {
	var mode = hud_mode_knob_pos.getValue();
	if ( mode == 3 ) {
		var se_fps = speed_east_fps.getValue();
		var sn_fps = speed_north_fps.getValue();
		var sd_fps = speed_down_fps.getValue();
		var agl    = agl_ft.getValue();
		var p    = pitch.getValue();

		s_fps = 0; # total velocity, fps.
		a = 0; # angle between total velocity and horizontal velocity.

		var gs_fps = math.sqrt( (se_fps * se_fps) + ( sn_fps * sn_fps ) );
		s_fps  = math.sqrt( (gs_fps * gs_fps) + ( sd_fps * sd_fps ) );
		var sina_vct = sd_fps / s_fps;
		var cosa_vct = gs_fps / s_fps;

		var a = ( 180 / math.pi  * ( math.atan2( gs_fps, sd_fps )) ) - 90; # used to check calculations against pitch
		var sina = math.sin( a * D2R );
		var cosa = math.cos( a * D2R );
		
		if ( agl > 0 ) {
			range_ft = ( s_fps * cosa * lbs_to_slugs ) * ( ( s_fps * sina ) + math.sqrt(( s_fps * s_fps * sina * sina ) + ( 2 * agl / lbs_to_slugs )));
		} else {
			range_ft = 0;
		}

		var impact_pitch_deg =  180 / math.pi  * ( math.atan2( agl, range_ft ));
		var ccip_dev_deg = impact_pitch_deg + p;
		var ccip_dev_m = math.sin( ccip_dev_deg * D2R ) * 0.95 * math.cos( ccip_dev_deg * D2R );
		ccip_deviation_m.setDoubleValue(ccip_dev_m);

		#print("     agl: " ~ agl ~ "ft");
		#print("vertical vel deg: " ~ a ~ "deg");
		#print("pitch: " ~ p ~ "deg");
		#print("     speed: " ~ s_fps ~ "ft");
		#print("     range: " ~ range_ft ~ "ft");
		#print(" imp-pitch: " ~ impact_pitch_deg ~ "deg");
		#print(" ccip-dev: " ~ ccip_dev_deg ~ "deg");
		#print(" ccip-dev: " ~ ccip_dev_m ~ "m");
		#print(" ");
	}
	settimer(update_loop, UPDATE_PERIOD);

}


# init #################
init = func {
	print("Initializing A-10 CCIP range calculator");
	update_loop();
}

setlistener("/sim/signals/fdm-initialized", init);



# controls #################
hud_mode_knob_move = func(v) {
	var p = hud_mode_knob_pos.getValue();
	if (v == 1 ) {
		if ( p < 6 ) {
			p += 1;
		}
	} elsif ( p > 0 ) {
		p -= 1;
	}
	hud_mode_knob_pos.setValue( p );
}
