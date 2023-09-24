
var RWR = {
	# inherits from Radar
	# will check radar/transponder and ground occlusion.
	# will sort according to threat level
	new: func () {
		var rr = {parents: [RWR, Radar]};

		rr.vector_aicontacts = [];
		rr.vector_aicontacts_threats = [];
		#rr.timer          = maketimer(2, rr, func rr.scan());

		rr.RWRRecipient = emesary.Recipient.new("RWRRecipient");
		rr.RWRRecipient.radar = rr;
		rr.RWRRecipient.Receive = func(notification) {
	        if (notification.NotificationType == "OmniNotification") {
	        	#printf("RWR recv: %s", notification.NotificationType);
	            if (me.radar.enabled == 1) {
	    		    me.radar.vector_aicontacts = notification.vector;
	    		    me.radar.scan();
	    	    }
	            return emesary.Transmitter.ReceiptStatus_OK;
	        }
	        return emesary.Transmitter.ReceiptStatus_NotProcessed;
	    };
		emesary.GlobalTransmitter.Register(rr.RWRRecipient);
		#nr.FORNotification = VectorNotification.new("FORNotification");
		#nr.FORNotification.updateV(nr.vector_aicontacts_for);
		#rr.timer.start();
		return rr;
	},
	heatDefense: 0,
	scan: func {
		# sort in threat?
		# run by notification
		# mock up code, ultra simple threat index, is just here cause rwr have special needs:
		# 1) It has almost no range restriction
		# 2) Its omnidirectional
		# 3) It might have to update fast (like 0.25 secs)
		# 4) To build a proper threat index it needs at least these properties read:
		#       model type
		#       class (AIR/SURFACE/MARINE)
		#       lock on myself
		#       missile launch
		#       transponder on/off
		#       bearing and heading
		#       IFF info
		#       ECM
		#       radar on/off
		if (!getprop("instrumentation/rwr/serviceable") or getprop("systems/electrical/outputs/rwr") < 20) {
            setprop("sound/rwr-lck", 0);
            setprop("ai/submodels/submodel[0]/flare-auto-release-cmd", 0);
            return;
        }
        me.vector_aicontacts_threats = [];
		me.fct = 10*2.0;
        me.myCallsign = self.getCallsign();
        me.myCallsign = size(me.myCallsign) < 8 ? me.myCallsign : left(me.myCallsign,7);
        me.act_lck = 0;
        me.autoFlare = 0;
        me.closestThreat = 0;
        me.elapsed = elapsedProp.getValue();
        foreach(me.u ; me.vector_aicontacts) {
        	# [me.ber,me.head,contact.getCoord(),me.tp,me.radar,contact.getDeviationHeading(),contact.getRangeDirect()*M2NM, contact.getCallsign()]
            me.dbEntry = radar_system.getDBEntry(me.u.getModel());
        	me.threatDB = me.u.getThreatStored();
            me.cs = me.threatDB[7];
            me.rn = me.threatDB[6];
            if ((me.u["blue"] != nil and me.u.blue == 1 and !me.threatDB[10]) or me.rn > 150) {
                continue;
            }
            me.bearing = me.threatDB[0];
            me.trAct = me.threatDB[3];
            me.show = 1;
            me.heading = me.threatDB[1];
            me.inv_bearing =  me.bearing+180;#bearing from target to me
            me.deviation = me.inv_bearing - me.heading;# bearing deviation from target to me
            me.dev = math.abs(geo.normdeg180(me.deviation));# my degrees from opponents nose

            if (me.show == 1) {
                if (me.dev < 30 and me.rn < 7 and me.threatDB[8] > 60) {
                    # he is in position to fire heatseeker at me
                    me.heatDefenseNow = me.elapsed + me.rn*1.5;
                    if (me.heatDefenseNow > me.heatDefense) {
                        me.heatDefense = me.heatDefenseNow;
                    }
                }
                me.threat = me.dbEntry.baseThreat(me.dev);
                me.danger = me.dbEntry.killZone;# within this range he is most dangerous
                if (me.threatDB[10]) me.threat += 0.30;# has me locked
                me.threat += ((me.danger-me.rn)/me.danger)>0?((me.danger-me.rn)/me.danger)*0.60:0;# if inside danger zone then add threat, the closer the more.
                me.threat += me.threatDB[9]>0?(me.threatDB[9]/500)*0.10:0;# more closing speed means more threat.
                if (!me.dbEntry.hasAirRadar) me.threat = - 1;
                if (me.threat > me.closestThreat) me.closestThreat = me.threat;
                #printf("A %s threat:%.2f range:%d dev:%d", me.u.get_Callsign(),me.threat,me.u.get_range(),me.deviation);
                if (me.threat > 1) me.threat = 1;
                if (me.threat <= 0) continue;
                #printf("B %s threat:%.2f range:%d dev:%d", me.u.get_Callsign(),me.threat,me.u.get_range(),me.deviation);
                append(me.vector_aicontacts_threats,[me.u,me.threat, me.threatDB[5]]);
            } else {
                #printf("%s ----", me.u.get_Callsign());
            }
        }

        me.launchClose = getprop("payload/armament/MLW-launcher") != "";
        me.incoming = getprop("payload/armament/MAW-active") or me.heatDefense > me.elapsed;
        me.spike = getprop("payload/armament/spike")*(getprop("ai/submodels/submodel[0]/count")>15);
        me.autoFlare = me.spike?math.max(me.closestThreat*0.25,0.05):0;

        if (0 and getprop("jaguar/avionics/ew-mode-knob") == 2)
        	print("wow: ", getprop("/fdm/jsbsim/gear/unit[0]/WOW"),"  spiked: ",me.spike,"  incoming: ",me.incoming, "  launch: ",me.launchClose,"  spikeResult:", me.autoFlare,"  aggresive:",me.launchClose * 0.85 + me.incoming * 0.85,"  total:",me.launchClose * 0.85 + me.incoming * 0.85+me.autoFlare);

        me.autoFlare += me.launchClose * 0.85 + me.incoming * 0.85;

        me.autoFlare *= 0.1 * 2.5 * !getprop("/fdm/jsbsim/gear/unit[0]/WOW");#0.1 being the update rate for flare dropping code.

        setprop("ai/submodels/submodel[0]/flare-auto-release-cmd", me.autoFlare * (getprop("ai/submodels/submodel[0]/count")>0));
        if (me.autoFlare > 0.80 and rand()>0.99 and getprop("ai/submodels/submodel[0]/count") < 1) {
            setprop("ai/submodels/submodel[0]/flare-release-out-snd", 1);
        }
	},
	del: func {
        emesary.GlobalTransmitter.DeRegister(me.RWRRecipient);
    },
};





var datalink_power = props.globals.getNode("instrumentation/datalink/power",0);
enable_tacobject = 1;
props.globals.getNode("sim/multiplay/generic/int[2]",1).setIntValue(1);# A-10 has no radar, so put it on standby
props.globals.getNode("instrumentation/rwr/serviceable",1).setBoolValue(1);

# start generic radar system
var baser = AIToNasal.new();
var omni = OmniRadar.new(1.0, 150, -1);
var terrain = TerrainChecker.new(0.1, 1, 30);# 0.05 or 0.10 is fine here
#var dlnkRadar = DatalinkRadar.new(0.03, 90);# 3 seconds because cannot be too slow for DLINK targets

# start specific radar system
var A10_rwr = RWR.new();

var getCompleteList = func {
	return baser.vector_aicontacts_last;
}

var getRWRList = func {
	return A10_rwr.vector_aicontacts_threats;
}

var rwr_fc = compat_failure_modes.set_unserviceable("instrumentation/rwr");
FailureMgr.add_failure_mode("instrumentation/rwr", "RWR", rwr_fc);
