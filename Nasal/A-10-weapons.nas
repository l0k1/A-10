var a10weapons    = props.globals.getNode("sim/model/A-10/weapons");
var arm_sw        = props.globals.getNode("sim/model/A-10/weapons/master-arm-switch");
var aim9_knob     = props.globals.getNode("sim/model/A-10/weapons/dual-AIM-9/aim9-knob");
var gun_running   = props.globals.getNode("sim/model/A-10/weapons/gun/running[0]");
var gr_switch     = props.globals.getNode("sim/model/A-10/weapons/gun-rate-switch");
var gun_count     = props.globals.getNode("ai/submodels/submodel[1]/count");
var GunReady      = props.globals.getNode("sim/model/A-10/weapons/gun/ready");
var GunHydrDriveL = props.globals.getNode("sim/model/A-10/weapons/gun/hydr-drive/serviceable[0]");
var GunHydrDriveR = props.globals.getNode("sim/model/A-10/weapons/gun/hydr-drive/serviceable[1]");
var HydrPsiL      = props.globals.getNode("systems/A-10-hydraulics/hyd-psi[0]");
var HydrPsiR      = props.globals.getNode("systems/A-10-hydraulics/hyd-psi[1]");
var z_pov         = props.globals.getNode("sim/current-view/z-offset-m");

var lastGunCount = 0;
var z_povhold = 0;

var TRUE = 1;
var FALSE = 0;
#enable/disable messages
setprop("payload/armament/msg",1);

# Init
var initialize = func() {
	setlistener("controls/armament/trigger", func( Trig ) {
		if ( Trig.getBoolValue()) {
			A10weapons.fire_gau8a();
		} else {
			A10weapons.cfire_gau8a(); }
	});
	# gun vibrations effect
	z_povhold = z_pov.getValue();
}

var fire_gau8a = func {
	var gunRun = gun_running.getValue();
	var gready = update_gun_ready();
	if (gready and !gunRun) {
		gun_running.setBoolValue(1);
		gunRun = 1;
		gau8a_vibs(0.002, z_pov.getValue());
	} elsif(!gready) {
		gun_running.setBoolValue(0);
		return;
	}
	if (gunRun) {
		# update gun count and yasim weight
		var realGunCount = gun_count.getValue();
		# init lastGunCount
		if((lastGunCount == 0) and (realGunCount > 0)) { lastGunCount = realGunCount + 1; }
		realGunCount -= (lastGunCount - realGunCount) * 7;
		if(realGunCount < 0) { realGunCount = 0 }
		gun_count.setValue(realGunCount);
		setprop("yasim/weights/ammunition-weight-lbs", (realGunCount*0.9369635));
		# for the next loop
		lastGunCount = realGunCount;
	}
}

var cfire_gau8a = func {
	gun_running.setBoolValue(0);
	update_gun_ready();
}

var gau8a_vibs = func(v, zpov) {
	if (getprop("sim/current-view/view-number") == 0) {
		if (gun_running.getBoolValue()) {
			var newZpos = v+zpov;
			z_pov.setValue(newZpos);
			settimer( func { gau8a_vibs(-v, zpov) }, 0.02);
		} else { z_pov.setValue(z_povhold); }
	}
}

var update_gun_ready = func() {
	var ready = 0;
	# TODO: electrical bus should be DC ARM BUS
	if (gr_switch.getValue() and arm_sw.getValue() == 1 and gun_count.getValue() > 0) {
		var drive_l = GunHydrDriveL.getValue();
		var drive_r = GunHydrDriveR.getValue();
		var psi_l   = HydrPsiL.getValue();
		var psi_r   = HydrPsiR.getValue();
		if (electrical.R_DC_bus_volts >= 24 and ((drive_l == 1 and psi_l > 900) or (drive_r == 1 and psi_r > 900))) {
			ready = 1;
		}
	}
	GunReady.setBoolValue(ready);
	return ready;
}

# station selection
# -----------------
# Selects one or several stations. Each has to be loaded with the same type of
# ordnance. Selecting a new station loaded with a different type deselects the
# former ones. Selecting  an allready selected station deselect it.
# Activates the search sound flag for AIM-9s (wich will be played only if the AIM-9
# knob is on the correct position). Ask for deactivation of the search sound flag
# in case of station deselection.
var stations      = props.globals.getNode("sim/model/A-10/weapons/stations");
var stations_list = stations.getChildren("station");
var weights       = props.globals.getNode("sim").getChildren("weight");
var aim9_knob     = a10weapons.getNode("dual-AIM-9/aim9-knob");
var aim9_sound    = a10weapons.getNode("dual-AIM-9/search-sound");
var cdesc = "";

var select_station = func {
	var target_idx = arg[0];
	setprop("controls/armament/station-select", target_idx);
	var desc_node = "sim/model/A-10/weapons/stations/station[" ~ target_idx ~ "]/description";
	#print("sim/model/A-10/weapons/stations/station[" ~ target_idx ~ "]/description");
	cdesc = props.globals.getNode(desc_node).getValue();
	#print("select_station.cdesc: " ~ cdesc);
	var sel_list = props.globals.getNode("sim/model/A-10/weapons/selected-stations");
	foreach (var s; stations_list) {
		idx = s.getIndex();
		var sdesc = s.getNode("description").getValue();
		var ssel = s.getNode("selected");
		var tsnode = "s" ~ idx;
		if ( idx == target_idx ) {
			if (ssel.getBoolValue()) {
				ssel.setBoolValue(0);
				sel_list.removeChildren(tsnode);
				if ( sdesc == "dual-AIM-9" ) {
					deactivate_aim9_sound();
				}
			} else {
				ssel.setBoolValue(1);
				var ts = sel_list.getNode(tsnode, 1);
				ts.setValue(target_idx);
				if ( sdesc == "dual-AIM-9") {
					aim9_sound.setBoolValue(1);
				}
			}
		} elsif ( cdesc != sdesc ) {
			# TODO: code triple and single MK82 mixed release ? 
			ssel.setBoolValue(0);
			sel_list.removeChildren(tsnode);
			if ( sdesc == "dual-AIM-9" ) {
				deactivate_aim9_sound();
			}
		}
	}
}


# station release
# ---------------
# Handles ripples and intervales.
# Handles the availability lights (3 green lights each station).
# LAU-68, with 7 ammos by station turns only one light until the dispenser is empty.
# Releases and substract the released weight from the station weight.
# Ask for deactivation of the search sound flag after the last AIM-9 has been released.
var sl_list = 0;

var release = func {
	var arm_volts = props.globals.getNode("systems/electrical/R-AC-volts").getValue();
	var asw = arm_sw.getValue();
	if ( asw != 1 or arm_volts < 24 )	{ return; }
	sl_list = a10weapons.getNode("selected-stations").getChildren();
	var rip = a10weapons.getNode("rip").getValue();
	var interval = a10weapons.getNode("interval").getValue();
	# FIXME: riple compatible release types should be defined in the foo-set.file 
	if ( cdesc == "LAU-68" or cdesc == "triple-MK-82-LD" or cdesc == "single-MK-82-LD") {
		release_operate(rip, interval);
	} else {
		release_operate(1, interval);
	}
}

var release_operate = func(rip_counter, interval) {
	foreach(sl; sl_list) {
		var slidx = sl.getValue();
		var snode = "sim/model/A-10/weapons/stations/station[" ~ slidx ~ "]";		
		var s = props.globals.getNode(snode);
		var wnode = "sim/weight[" ~ slidx ~ "]";		
		var w = props.globals.getNode(wnode);
		var wght = w.getNode("weight-lb").getValue();
		var awght = s.getNode("ammo-weight-lb").getValue();
		if ( cdesc == "LAU-68" ) { var lau68ready = s.getNode("ready-0"); } 
		var avail = s.getNode("available");
		var a = avail.getValue();
		if ( a != 0 ) {
			if ( cdesc == "dual-AIM-9"  and aim9_knob.getValue() != 2 ) { return; }
			turns = a10weapons.getNode(cdesc).getNode("available").getValue();
			for( i = 0; i <= turns; i = i + 1 ) {
				var it = cdesc ~ "/trigger[" ~ i ~"]";
				var itrigger = s.getNode(it);
				var iready_node = "ready-" ~ i;
				var a = avail.getValue();
				if ( cdesc != "LAU-68" ) { var iready = s.getNode(iready_node); }
				var t = itrigger.getBoolValue();
				if ( !t and a > 0) {
					if ( cdesc == "LAU-68" ) {
						defeatSpamFilter("LAU-68 fired");
					} elsif (cdesc != "dual-AIM-9") {
						defeatSpamFilter("MK-82 released");
					}
					itrigger.setBoolValue(1);
					a -= 1;
					avail.setValue(a);
					rip_counter -= 1;
					wght -= awght;
					w.getNode("weight-lb").setValue(wght);
					if ( cdesc != "LAU-68" ) { iready.setBoolValue(0); }
					if ( a == 0 ) {
						if ( cdesc == "LAU-68" ) {
							lau68ready.setBoolValue(0);
						} elsif ( cdesc == "dual-AIM-9" ) {
							deactivate_aim9_sound();
						}
						s.getNode("error").setBoolValue(1);
					}
					if (rip_counter > 0 ) {
						settimer( func { release_operate(rip_counter, interval); }, interval);
					}
					return;
				}
			}
		}
	}
}


# Searchs if there isn't a remainning AIM-9 on a selected station before
# deactivating the search sound flag.
var deactivate_aim9_sound = func {
	aim9_sound.setBoolValue(0);
	var a = 0;
	foreach (s; stations.getChildren("station")) {
		var ssel = s.getNode("selected").getBoolValue();
		var desc = s.getNode("description").getValue();
		var avail = s.getNode("available");
		if ( ssel and desc == "dual-AIM-9"  ) {
			a += avail.getValue();
		}
		if ( a ) {
			aim9_sound.setBoolValue(1);
		}
	}
}


# link from the Fuel and Payload menu (gui.nas)
# ---------------------------------------------
# Called from the F&W dialog when the user selects a weight option
# and hijacked from gui.nas so we can call our update_stations().
# TODO: make the call of a custom func possible from inside gui.nas
gui.weightChangeHandler = func {
	var tankchanged = gui.setWeightOpts();

	# This is unfortunate.  Changing tanks means that the list of
	# tanks selected and their slider bounds must change, but our GUI
	# isn't dynamic in that way.  The only way to get the changes on
	# screen is to pop it down and recreate it.
	# TODO: position the recreated window where it was before.
	if(tankchanged) {
		update_stations();
		var p = props.Node.new({"dialog-name" : "WeightAndFuel"});
		fgcommand("dialog-close", p);
		gui.showWeightDialog();
	}
}

var update_stations = func {
	var a = nil;
	foreach (w; weights) {
		var idx = w.getIndex();
		var weight = 0;
		var desc = w.getNode("selected").getValue();
		if ( desc == "600 Gallons Fuel Tank" ) {
			desc = "tank-600-gals";
		}
		var type = a10weapons.getNode(desc);
		var snode = "sim/model/A-10/weapons/stations/station[" ~ idx ~ "]";
		var s = props.globals.getNode(snode);
		if ( desc != "none" ) {
			station_load(s, w, type);
		} else {
			station_unload(s, w);
		}
	}
}



# station load
# ------------
# Sets the station properties from the type definition in the current station.
# Prepares the error light or the 3 ready lights, then sets to false the
# necessary number of triggers (useful in the case of the submodels weren't
# already defined).
# Creates a node attached to the station's one and containing the triggers.
var station_load = func(s, w, type) {
	var weight = type.getNode("weight-lb").getValue();
	var ammo_weight = type.getNode("ammo-weight-lb").getValue();
	var desc = type.getNode("description").getValue();
	var avail = type.getNode("available").getValue();
	var readyn = type.getNode("ready-number").getValue();
	w.getNode("weight-lb").setValue(weight);
	s.getNode("ammo-weight-lb", 1).setValue(ammo_weight);
	s.getNode("description").setValue(desc);
	s.getNode("available").setValue(avail);
	if ( readyn == 0 ) {
		# non-armable payload case. (ECM pod, external tank...)
		s.getNode("error").setBoolValue(1);
		return;
	} else {
		s.getNode("error").setBoolValue(0);
	}
	if ( readyn == 1 ) {
		# single ordnance case.
		s.getNode("ready-0").setBoolValue(1);
	} elsif( readyn == 2 ) {
		# double ordnances case
		s.getNode("ready-0").setBoolValue(1);
		s.getNode("ready-1").setBoolValue(1);
	} else {
		# triple ordnances case
		s.getNode("ready-0").setBoolValue(1);
		s.getNode("ready-1").setBoolValue(1);
		s.getNode("ready-2").setBoolValue(1);
	} 
	for( i = 0; i < avail; i = i + 1 ) {
		# TODO: here to add submodels reload
		itrigger_node = desc ~ "/trigger[" ~ i ~ "]";
		t = s.getNode(itrigger_node, 1);
		t.setBoolValue(0);
	}
}


# station unload
# --------------
var station_unload = func(s, w) {
	w.getNode("weight-lb").setValue(0);
	s.getNode("ammo-weight-lb").setValue(0);
	#desc = s.getNode("description").getValue();
	s.getNode("description").setValue("none");
	s.getNode("available").setValue(0);
	s.getNode("ready-0").setBoolValue(0);
	s.getNode("ready-1").setBoolValue(0);
	s.getNode("ready-2").setBoolValue(0);
	s.getNode("error").setBoolValue(1);
}


# Armament panel switches
# -----------------------

var master_arm_switch = func(swPos=0) {
	# 3 positions MASTER ARM switch
	var mastArmSw = arm_sw.getValue();
	if((mastArmSw < 1) and (swPos == 1)) {
		mastArmSw += 1;
	} elsif((mastArmSw > -1) and (swPos == -1)) {
		mastArmSw -= 1;
	}
	arm_sw.setIntValue(mastArmSw);
	update_gun_ready();
}

var gun_rate_switch = func() {
	# Toggle gun rate switch and update GUN READY light
	var gunRateSw = gr_switch.getValue();
	if(gunRateSw == 0) {
		gr_switch.setBoolValue(1);
	} else {
		gr_switch.setBoolValue(0);
	}
	update_gun_ready();
}

var aim9_knob_switch = func {
	var input = arg[0];
	var a_knob = aim9_knob.getValue();
	if ( input == 1 ) {
		if ( a_knob == 0 ) {
			aim9_knob.setValue(1);
		} elsif ( a_knob == 1 ) {
			aim9_knob.setValue(2);
		}
	} else {
		if ( a_knob == 2 ) {
			aim9_knob.setValue(1);
		} elsif ( a_knob == 1 ) {
			aim9_knob.setValue(0);
		}
	}
}



# reloads ammos for GAU-8
# -----------------------
# Thanks to Bombable/Brent Hugh, 2011-09

reload_guns = func {
	var gau8_ammo_count="/ai/submodels/submodel[1]/count";  
	var a10_ammo_weight="/yasim/weights/ammunition-weight-lbs";
	groundspeed=getprop("velocities/groundspeed-kt");
	engine_rpm=getprop("engines/engine/rpm");

	#only allow it if on ground and stopped.
	if (  groundspeed < 5  ) {
		setprop ( gau8_ammo_count, 1174); #ammo loaded
		var bweight=1174*0.9369635; #.9369635 = weight of one round in lbs
		setprop(a10_ammo_weight, bweight);
		gui.popupTip ("GAU-8 reloaded--1174 rounds.", 5);
	} else {
	gui.popupTip ("You must be on the ground and at a dead stop to re-load ammo.",5);
	}
}

############ Cannon impact messages #####################

var hits_count = 0;
var hit_timer  = nil;
var hit_callsign = "";

var Mp = props.globals.getNode("ai/models");
var valid_mp_types = {
  multiplayer: 1, tanker: 1, aircraft: 1, ship: 1, groundvehicle: 1,
};

# Find a MP aircraft close to a given point (code from the Mirage 2000)
var findmultiplayer = func(targetCoord, dist) {
    if(targetCoord == nil) return nil;

    var raw_list = Mp.getChildren();
    var SelectedMP = nil;
    foreach(var c ; raw_list)
    {    
	var is_valid = c.getNode("valid");
	if(is_valid == nil or !is_valid.getBoolValue()) continue;
	
	var type = c.getName();
	
	var position = c.getNode("position");
	var name = c.getValue("callsign");
	if(name == nil or name == "") {
	    # fallback, for some AI objects
	    var name = c.getValue("name");
	}
	if(position == nil or name == nil or name == "" or !contains(valid_mp_types, type)) continue;

	var lat = position.getValue("latitude-deg");
	var lon = position.getValue("longitude-deg");
	var elev = position.getValue("altitude-ft") * FT2M;

	if(lat == nil or lon == nil or elev == nil) continue;

	MpCoord = geo.Coord.new().set_latlon(lat, lon, elev);
	var tempoDist = MpCoord.direct_distance_to(targetCoord);
	if(dist > tempoDist) {
	    dist = tempoDist;
	    SelectedMP = name;
	}
    }
    return SelectedMP;
}

var impact_listener = func {
    var ballistic_name = props.globals.getNode("/ai/models/model-impact").getValue();
    var ballistic = props.globals.getNode(ballistic_name, 0);
    if (ballistic != nil and
	ballistic.getName() != "munition" and
	getprop("payload/armament/msg")) {

	var typeOrd = ballistic.getNode("name").getValue();
	var typeNode = ballistic.getNode("impact/type");
	if (typeNode != nil and typeNode.getValue() != "terrain") {
	    var lat = ballistic.getNode("impact/latitude-deg").getValue();
	    var lon = ballistic.getNode("impact/longitude-deg").getValue();
	    var elev = ballistic.getNode("impact/elevation-m").getValue();
	    var impactPos = geo.Coord.new().set_latlon(lat, lon, elev);
	    var target = findmultiplayer(impactPos, 80);

	    if (target != nil) {
		if (find("MK-82", typeOrd) == -1) {
		    if (find("WP-", typeOrd) != -1 ) {
			typeOrd = "Hydra-70";
		    } elsif (find("GAU-8/A", typeOrd) != -1) {
			typeOrd = "GAU-8/A";
		    }
		    if(target == hit_callsign) {
		        # Previous impacts on same target
		        hits_count += 1;
		    }
		    else {
		        if (hit_timer != nil) {
		    	# Previous impacts on different target, flush them first
		    	hit_timer.stop();
		    	hitmessage(typeOrd);
		        }
		        hits_count = 1;
		        hit_callsign = target;
		        hit_timer = maketimer(1, func {hitmessage(typeOrd);});
		        hit_timer.singleShot = 1;
		        hit_timer.start();
		    }
		}
	    }
	}	    
    }
}

var hitmessage = func(typeOrd) {
    #print("inside hitmessage");
    var phrase = typeOrd ~ " hit: " ~ hit_callsign ~ ": " ~ hits_count ~ " hits";
    if (getprop("payload/armament/msg") == TRUE) {
	#armament.defeatSpamFilter(phrase);
	var msg = notifications.ArmamentNotification.new("mhit", 4, -1*(damage.shells[typeOrd][0]+1));
	msg.RelativeAltitude = 0;
	msg.Bearing = 0;
	msg.Distance = hits_count;
	msg.RemoteCallsign = hit_callsign;
	notifications.hitBridgedTransmitter.NotifyAll(msg);
	damage.damageLog.push("You hit "~hit_callsign~" with "~typeOrd~", "~hits_count~" times.");
    } else {
	setprop("/sim/messages/atc", phrase);
    }
    hit_callsign = "";
    hit_timer = nil;
    hits_count = 0;
}

# setup impact listener
setlistener("/ai/models/model-impact", impact_listener, 0, 0);

var spams = 0;

var defeatSpamFilter = func (str) {
  spams += 1;
  if (spams == 15) {
    spams = 1;
  }
  str = str~":";
  for (var i = 1; i <= spams; i+=1) {
    str = str~".";
  }
  
  if (getprop("payload/armament/msg")) {
	setprop("/sim/multiplay/chat", str);
  } else {
	setprop("/sim/messages/atc", str);
  }
  
  return str;
}


setlistener("/ai/models/model-impact", impact_listener, 0, 0);
