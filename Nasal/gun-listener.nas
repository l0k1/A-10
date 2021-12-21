# copied from A-10

var TRUE = 1;
var FALSE = 0;

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
	ballistic.getName() != "munition") {

	var typeOrd = ballistic.getNode("name").getValue();
	var typeNode = ballistic.getNode("impact/type");
	if (typeNode != nil and typeNode.getValue() != "terrain") {
	    var lat = ballistic.getNode("impact/latitude-deg").getValue();
	    var lon = ballistic.getNode("impact/longitude-deg").getValue();
	    var elev = ballistic.getNode("impact/elevation-m").getValue();
	    var impactPos = geo.Coord.new().set_latlon(lat, lon, elev);
	    var target = findmultiplayer(impactPos, 80);

	    if (target != nil) {
		if (typeOrd == "Mk3Z") {
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

var hitmessage = func(typeOrd) {
    #print("inside hitmessage");
    var phrase = typeOrd ~ " hit: " ~ hit_callsign ~ ": " ~ hits_count ~ " hits";
    if (getprop("payload/armament/msg") == TRUE) {
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

# Disable external views with damage on
	view.stepView = func(step, force = 0) {
    step = step > 0 ? 1 : -1;
    var n = view.index;
    for (var i = 0; i < size(view.views); i += 1) {
        n += step;
        if (n < 0)
            n = size(view.views) - 1;
        elsif (n >= size(view.views))
            n = 0;
        var e = view.views[n].getNode("enabled");
        var internal = view.views[n].getNode("internal");

        if ((force or e == nil or e.getBoolValue())
            and view.views[n].getNode("name") != nil
            and ((internal != nil and internal.getBoolValue()) or !getprop("/payload/armament/msg")))
            break;
    }
    view.setView(n);

    # And pop up a nice reminder
    var popup=getprop("/sim/view-name-popup");
    if(popup == 1 or popup==nil) gui.popupTip(view.views[n].getNode("name").getValue());
}
		
# setup impact listener
setlistener("/ai/models/model-impact", impact_listener, 0, 0);
