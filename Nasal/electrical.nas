#A-10 electrical system.
    # A-10 external-battery-switch assumed always on
    # A-10 external pwr assumed never connected

var UPDATE_PERIOD = 0.3;

var battery = nil;
var alternator = nil;

var last_time = 0.0;

var bat_src_volts = 0.0;

var battery_bus_volts   = 0.0;
var L_DC_bus_volts      = 0.0;
var R_DC_bus_volts      = 0.0;
var L_AC_bus_volts      = 0.0;
var R_AC_bus_volts      = 0.0;
var L_conv_volts        = 0.0;
var R_conv_volts        = 0.0;
var AC_ESSEN_bus_volts  = 0.0;
var DC_ESSEN_bus_volts  = 0.0;
ammeter_ave = 0.0;


init_electrical = func {
    print("Initializing Nasal Electrical System");
    battery = BatteryClass.new();
    alternator = AlternatorClass.new();
    setprop("controls/switches/master-avionics", 0);
    setprop("controls/electric/battery-switch", 0);
    setprop("controls/electric/external-power", 0);
    setprop("controls/electric/engine[0]/generator", 0);
    setprop("controls/electric/engine[1]/generator", 0);
    setprop("sim/model/A-10/controls/switches/inverter", 1);
	setprop("systems/electrical/power_source", "none");
    setprop("systems/electrical/L-conv-volts", 0.0);
    setprop("systems/electrical/R-conv-volts", 0.0);
    setprop("systems/electrical/inverter-volts", 0.0);
    setprop("systems/electrical/radar", 24.0);
    # radar only used to allow Air to Air Refueling to work.
    settimer(update_electrical, 0);
}





BatteryClass = {};
BatteryClass.new = func {
    obj = { parents : [BatteryClass],
            ideal_volts : 26.0,
            ideal_amps : 30.0,
            amp_hours : 12.75,
            charge_percent : 1.0,
            charge_amps : 7.0 };
    return obj;
}
BatteryClass.apply_load = func( amps, dt ) {
    amphrs_used = amps * dt / 3600.0;
    percent_used = amphrs_used / me.amp_hours;
    me.charge_percent -= percent_used;
    if ( me.charge_percent < 0.0 ) {
        me.charge_percent = 0.0;
    } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
    }
    return me.amp_hours * me.charge_percent;
}
BatteryClass.get_output_volts = func {
    x = 1.0 - me.charge_percent;
    factor = x / 10;
    return me.ideal_volts - factor;
}
BatteryClass.get_output_amps = func {
    x = 1.0 - me.charge_percent;
    tmp = -(3.0 * x - 1.0);
    factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
    return me.ideal_amps * factor;
}

AlternatorClass = {};
AlternatorClass.new = func {
    obj = { parents : [AlternatorClass],
            ideal_volts : 26.0,
            ideal_amps : 60.0 };
    return obj;
}
AlternatorClass.apply_load = func( amps, dt, src ) {
    rpm = getprop(src);
    # A-10 APU can have 0 rpm
    if (rpm == 0) {
        factor = 0;
    } else {
        factor = math.ln(rpm)/4;
    }
    available_amps = me.ideal_amps * factor;
    return available_amps - amps;
}
AlternatorClass.get_output_volts = func( src ) {
    rpm = getprop(src );
    # A-10 APU can have 0 rpm
    if (rpm == 0) {
        factor = 0;
    } else {
        factor = math.ln(rpm)/4;
    }
    return me.ideal_volts * factor;
}
AlternatorClass.get_output_amps = func(src ){
    rpm = getprop( src );
    # A-10 APU can have 0 rpm
    if (rpm == 0) {
        factor = 0;
    } else {
        factor = math.ln(rpm)/4;
    }
    return me.ideal_amps * factor;
}



update_electrical = func {
    time = getprop("sim/time/elapsed-sec");
    dt = time - last_time;
    last_time = time;
    update_virtual_bus( dt );
    check_bleed_air();
    settimer(update_electrical, UPDATE_PERIOD);
}




update_virtual_bus = func( dt ) {
    eng_outof         = getprop("engines/engine[0]/out-of-fuel");
    eng_outof1        = getprop("engines/engine[1]/out-of-fuel");
    master_bat        = getprop("controls/electric/battery-switch");
    master_apu        = getprop("controls/electric/APU-generator[0]");
    master_alt        = getprop("controls/electric/engine[0]/generator");
    master_alt1       = getprop("controls/electric/engine[1]/generator");
    master_inv        = getprop("sim/model/A-10/controls/switches/inverter");
    external_volts    = 0.0;
    battery_volts     = battery.get_output_volts();
    if (master_alt and !eng_outof) {
        L_gen_volts = alternator.get_output_volts("sim/model/A-10/engines/engine[0]/n1");
    } else { L_gen_volts = 0.0;}
    if (master_alt1 and !eng_outof1) {
        R_gen_volts = alternator.get_output_volts("sim/model/A-10/engines/engine[1]/n1");
    } else { R_gen_volts = 0.0; }
    if ( master_apu ) {
        APU_gen_volts = alternator.get_output_volts("sim/model/A-10/systems/apu/rpm");
    } else { APU_gen_volts = 0.0; }
    INV_volts    = getprop("systems/electrical/inverter-volts");
    L_AC_bus_volts = 0.0;
    R_AC_bus_volts = 0.0;
    load = 0.0;
    
  # determine power source
    power_source = nil;
    if ( master_bat == 1 ) { bat_src_volts = battery_volts; }
    if (APU_gen_volts >= 23) {
        R_conv_volts = APU_gen_volts;
        if ((L_gen_volts < 23) and (R_gen_volts < 23)) {
            L_AC_bus_volts = APU_gen_volts;
            R_AC_bus_volts = APU_gen_volts;
            AC_ESSEN_bus_volts = APU_gen_volts;
            L_conv_volts = APU_gen_volts;
            power_source = "apu";
        }
        if ((L_gen_volts < 23) and (R_gen_volts >= 23)) {
            L_AC_bus_volts = R_gen_volts;
            R_AC_bus_volts = R_gen_volts;
            AC_ESSEN_bus_volts = R_gen_volts;
            L_conv_volts = R_gen_volts;
        }
        if ((L_gen_volts >= 23) and (R_gen_volts < 23)) {
            L_AC_bus_volts = L_gen_volts;
            R_AC_bus_volts = L_gen_volts;
            AC_ESSEN_bus_volts = L_gen_volts;
            L_conv_volts = L_gen_volts;
        }
        if ((L_gen_volts >= 23) and (R_gen_volts >= 23)) {
            L_AC_bus_volts = L_gen_volts;
            R_AC_bus_volts = R_gen_volts;
            AC_ESSEN_bus_volts = L_gen_volts;
            L_conv_volts = L_gen_volts;
        }
    }
    if (APU_gen_volts < 23) {
        if ((L_gen_volts < 23) and (R_gen_volts < 23)) {
            L_AC_bus_volts = 0.0;
            R_AC_bus_volts = 0.0;
            AC_ESSEN_bus_volts = INV_volts;
            L_conv_volts = 0.0;
            R_conv_volts = 0.0;
        }
        if ((L_gen_volts < 23) and (R_gen_volts >= 23)) {
            L_AC_bus_volts = R_gen_volts;
            R_AC_bus_volts = R_gen_volts;
            AC_ESSEN_bus_volts = R_gen_volts;
            L_conv_volts = R_gen_volts;
            R_conv_volts = R_gen_volts;
        }
        if ((L_gen_volts >= 23) and (R_gen_volts < 23)) {
            L_AC_bus_volts = L_gen_volts;
            R_AC_bus_volts = L_gen_volts;
            AC_ESSEN_bus_volts = L_gen_volts;
            L_conv_volts = L_gen_volts;
            R_conv_volts = L_gen_volts;
        }
        if ((L_gen_volts >= 23) and (R_gen_volts >= 23)) {
            L_AC_bus_volts = L_gen_volts;
            R_AC_bus_volts = R_gen_volts;
            AC_ESSEN_bus_volts = L_gen_volts;
            L_conv_volts = L_gen_volts;
            R_conv_volts = L_gen_volts;
        }
    }

    if ((L_conv_volts >= 23) and (R_conv_volts >= 23)) {
        DC_ESSEN_bus_volts      = L_conv_volts;
        AUX_DC_ESSEN_bus_volts  = L_conv_volts;
        battery_bus_volts       = L_conv_volts;
        L_DC_bus_volts          = L_conv_volts;
        R_DC_bus_volts          = R_conv_volts;
        bat_src_volts           = L_conv_volts;
        power_source = "none";
    }
    if ((L_conv_volts < 23) and (R_conv_volts >= 23)) {
        DC_ESSEN_bus_volts      = R_conv_volts;
        AUX_DC_ESSEN_bus_volts  = R_conv_volts;
        battery_bus_volts       = R_conv_volts;
        L_DC_bus_volts          = R_conv_volts;
        R_DC_bus_volts          = R_conv_volts;
        bat_src_volts           = R_conv_volts;
        power_source = "none";
    }
    if ((L_conv_volts >= 23) and (R_conv_volts < 23)) {
        DC_ESSEN_bus_volts      = L_conv_volts;
        AUX_DC_ESSEN_bus_volts  = L_conv_volts;
        battery_bus_volts       = L_conv_volts;
        L_DC_bus_volts          = L_conv_volts;
        R_DC_bus_volts          = L_conv_volts;
        bat_src_volts           = L_conv_volts;
        power_source = "none";
    }
    if ((L_conv_volts < 23) and (R_conv_volts < 23)) {
        DC_ESSEN_bus_volts      = bat_src_volts;
        AUX_DC_ESSEN_bus_volts  = bat_src_volts;
        battery_bus_volts       = bat_src_volts;
        L_DC_bus_volts          = 0.0;
        R_DC_bus_volts          = 0.0;
        power_source = "battery";
    }
    if (( master_bat == 0 ) and (L_conv_volts < 23) and (L_conv_volts < 23)) {
        DC_ESSEN_bus_volts      = 0.0;
        AUX_DC_ESSEN_bus_volts  = 0.0;
    }
    # Inverter
    if (( master_inv == 2 ) and (L_gen_volts < 20) and (R_gen_volts < 20)) {
        INV_volts = bat_src_volts;
        power_source = "battery"; 		# Does not mean that the battery is
                                        # connected to any bus.
    } elsif ( master_inv == 1 ) {
        INV_volts = 0.0;
    } elsif ( master_inv == 0 ) {
        INV_volts = bat_src_volts;
        power_source = "battery";
    }




    load += BATT_bus();
    load += DC_ESSEN_bus();
    load += AUX_DC_ESSEN_bus();
    load += L_DC_bus();
    load += R_DC_bus();
    load += L_AC_bus();
    load += R_AC_bus();
    load += AC_ESSEN_bus();
    ammeter = 0.0;
    if ( bat_src_volts > 1.0 ) {
        # normal load
        load += 15.0;
        # ammeter gauge
        #if ( power_source == "battery" ) {
        #    ammeter = -load;
        #} else {
        #    ammeter = battery.charge_amps;
        #}
    }
    # charge/discharge the battery
    if ( power_source == "battery" ) {
        battery.apply_load( load, dt );
        setprop( "systems/electrical/power_source", power_source );
    } elsif ( bat_src_volts > battery_volts ) {
        battery.apply_load( -battery.charge_amps, dt );
    }
    # filter ammeter needle pos
    #ammeter_ave = 0.8 * ammeter_ave + 0.2 * ammeter;
    # outputs
    setprop("systems/electrical/amps", ammeter_ave);
    setprop("systems/electrical/volts", bat_src_volts);
    #setprop("systems/electrical/ac_amps", AC_bus_amps);
    setprop("systems/electrical/inverter-volts", INV_volts);
    setprop("systems/electrical/APU-gen-volts", APU_gen_volts);
    setprop("systems/electrical/L-AC-volts", L_AC_bus_volts);
    setprop("systems/electrical/R-AC-volts", R_AC_bus_volts);
    setprop("systems/electrical/L-conv-volts", L_conv_volts);
    setprop("systems/electrical/R-conv-volts", R_conv_volts);
    return load;
}




BATT_bus = func() {
    load = 0.0;
    if ( getprop("controls/switches/cabin-lights") ) {
        setprop("systems/electrical/outputs/cabin-lights", battery_bus_volts);
    } else {
        setprop("systems/electrical/outputs/cabin-lights", 0.0);
    }
    if ( getprop("sim/model/A-10/controls/APU/off-start-switch") and (getprop("sim/model/A-10/systems/apu/start-state") < 1 )) {
        setprop("systems/electrical/outputs/apu-starter", battery_bus_volts);
    } else {
        setprop("systems/electrical/outputs/apu-starter", 0.0);
    }
    return load;
}

DC_ESSEN_bus = func() {
    load = 0.0;
    setprop("systems/electrical/outputs/nav[0]", DC_ESSEN_bus_volts);
    setprop("systems/electrical/outputs/com[0]", DC_ESSEN_bus_volts);
    setprop("systems/electrical/outputs/nav[1]", DC_ESSEN_bus_volts);
    setprop("systems/electrical/outputs/com[1]", DC_ESSEN_bus_volts);
    setprop("systems/electrical/outputs/nav[2]", DC_ESSEN_bus_volts);
    setprop("systems/electrical/outputs/ldg-warning-system", DC_ESSEN_bus_volts);
    setprop("systems/electrical/outputs/apu-start-system", DC_ESSEN_bus_volts);
    setprop("systems/electrical/outputs/caution-panel", DC_ESSEN_bus_volts);
    return load;
}

AUX_DC_ESSEN_bus = func() {
    load = 0.0;
    setprop("systems/electrical/outputs/engines-ignitors", AC_ESSEN_bus_volts);
    return load;
}

L_DC_bus = func() {
    load = 0.0;
    return load;
}

R_DC_bus = func() {
    load = 0.0;
    setprop("systems/electrical/outputs/uhf-adf", R_DC_bus_volts);
    setprop("systems/electrical/outputs/vhf-comm", R_DC_bus_volts);
    setprop("systems/electrical/outputs/vhf-fm", R_DC_bus_volts);
    setprop("systems/electrical/outputs/ils", R_DC_bus_volts);
    return load;
}

L_AC_bus = func() {
    load = 0.0;
    return load;
}

R_AC_bus = func() {
    load = 0.0;
    setprop("systems/electrical/outputs/tacan", R_AC_bus_volts);
    setprop("systems/electrical/outputs/hsi", R_AC_bus_volts);
    setprop("systems/electrical/outputs/adi", R_AC_bus_volts);
    setprop("systems/electrical/outputs/cadc", R_AC_bus_volts);
    setprop("systems/electrical/outputs/nav-mode", R_AC_bus_volts);
    setprop("systems/electrical/outputs/aoa-indexer", R_AC_bus_volts);
    var hud_mode = getprop("sim/model/A-10/controls/hud/mode-selector");
    if (hud_mode > 0) {
        setprop("systems/electrical/outputs/hud", R_AC_bus_volts);
    } else {
        setprop("systems/electrical/outputs/hud", 0);
    }
    setprop("instrumentation/attitude-indicator/spin", R_AC_bus_volts/30);
    setprop("systems/electrical/outputs/DG", R_AC_bus_volts);
    return load;
}

AC_ESSEN_bus = func() {
    load = 0.0;
    return load;
}

setlistener("/sim/signals/fdm-initialized", init_electrical);


# bleed air system
# ----------------
var check_bleed_air= func {
		# max ECS incomming pressure : 65 psi ( from Environment Control System valve)
		# nin rpm from a running TF34 engine to start the other one : 85 %rpm
		# All numbers below guessed from above
		# min pressure for TF34 engine start : 50 psi
		# nominal APU : 70 psi @ 100 %rpm
		# nominal TF34 : 60 psi @ 90 %rpm
		var bair_sys = props.globals.getNode("systems/bleed-air");
		var psi = bair_sys.getNode("psi", 1);
		var e0_n1 = props.globals.getNode("sim/model/A-10/engines/engine[0]/n1").getValue();
		var e1_n1 = props.globals.getNode("sim/model/A-10/engines/engine[1]/n1").getValue();
		var apu_rpm = props.globals.getNode("sim/model/A-10/systems/apu/rpm").getValue();
		if ( e0_n1 == nil ) { e0_n1 = 0 }
		if ( e1_n1 == nil ) { e1_n1 = 0 }
		if ( apu_rpm == nil ) { apu_rpm = 0 }
		var p0 = e0_n1 * 0.67;
		var p1 = e1_n1 * 0.67;
		var p2 = apu_rpm * 0.7;
		var bleed_air = p0;
		if ( p1 > bleed_air ) { bleed_air = p1; }
		if ( p2 > bleed_air ) { bleed_air = p2; }
		psi.setValue(bleed_air);
}


# other electrical power controls
# -------------------------------
inverter_switch = func {
    var inv_pos = props.globals.getNode("sim/model/A-10/controls/switches/inverter", 1);
    var pos = inv_pos.getValue();
    var input = arg[0];
    if ( input == 1 ) {
        if ( pos == 0 ) {
            inv_pos.setIntValue(1);
        } elsif ( pos == 1 ) {
            inv_pos.setIntValue(2);
        }
    } else {
        if ( pos == 2 ) {
            inv_pos.setIntValue(1);
        } elsif ( pos == 1 ) {
            inv_pos.setIntValue(0);
        }
    }
}




# lighting controls
# -----------------

nav_lights_switcher = func {
    flash = props.globals.getNode("sim/model/A-10/controls/lighting/nav-lights-flash", 1);
    s_pos = props.globals.getNode("sim/model/A-10/controls/lighting/nav-lights-switch", 1);
    pos = s_pos.getValue();
    input = arg[0];
    if ( input == 1 ) {
        if ( pos == 0 ) {
            s_pos.setIntValue(1);
        } elsif ( pos == 1 ) {
            s_pos.setIntValue(2);
            s_pos.setBoolValue(1);
        }
    } else {
        if ( pos == 2 ) {
            s_pos.setIntValue(1);
            flash.setBoolValue(0);
        } elsif ( pos == 1 ) {
            s_pos.setIntValue(0);
        }
    }
}



land_lights_switcher = func {
    s_pos = props.globals.getNode("sim/model/A-10/controls/lighting/land-lights-switch", 1);
    pos = s_pos.getValue();
    input = arg[0];
    if ( input == 1 ) {
        if ( pos == 0 ) {
            s_pos.setIntValue(1);
        } elsif ( pos == 1 ) {
            s_pos.setIntValue(2);
        }
    } else {
        if ( pos == 2 ) {
            s_pos.setIntValue(1);
        } elsif ( pos == 1 ) {
            s_pos.setIntValue(0);
        }
    }
}
