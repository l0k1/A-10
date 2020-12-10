# hooking damage into FailureMgr

var install_failures = func {
    var set_value = func(path, value) {
	var default = getprop(path);
	return {
	    parents: [FailurMgr.FailureActuator],
	      set_failure_level: func(level) setprop(path, level > 0 ? value : default),
	      get_failure_level: func { getprop(path) == default ? 0 : 1 }
        }
    }

    var failure_root = "/sim/failure-manager";

    prop = "/controls/engines/engine[0]/faults/hydraulic-pump";
    var actuator_hyd_pump_0 = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "Left Hyd Pump", actuator_hyd_pump_0);

    
    prop = "/controls/engines/engine[1]/faults/hydraulic-pump";
    var actuator_hyd_pump_1 = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "Right Hyd Pump", actuator_hyd_pump_1);

    prop = "/controls/engines/engine[0]/faults";
    var actuator_engine_0 = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "Left Engine", actuator_engine_0);
    
    prop = "/controls/engines/engine[1]/faults";
    var actuator_engine_1 = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "Right Engine", actuator_engine_1);
    
    prop = "controls/APU";
    var actuator_APU = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "APU", actuator_APU);
    
    prop = "/controls/APU/generator";
    var actuator_APU_gen = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "APU GEN", actuator_APU_gen);

    prop = "/controls/fuel/tank[0]/boost-pump";
    var actuator_boost_pump_0 = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "Boost Pump 0", actuator_boost_pump_0);

    prop = "/controls/fuel/tank[1]/boost-pump";
    var actuator_boost_pump_1 = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "Boost Pump 1", actuator_boost_pump_1);

    prop = "/controls/fuel/tank[2]/boost-pump";
    var actuator_boost_pump_2 = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "Boost Pump 2", actuator_boost_pump_2);

    prop = "/controls/fuel/tank[3]/boost-pump";
    var actuator_boost_pump_3 = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "Boost Pump 3", actuator_boost_pump_3);

    prop = "/controls/fuel/tank[1]/DC-boost-pump";
    var actuator_DC_boost_pump = compat_failure_modes.set_unserviceable(prop);
    FailureMgr.add_failure_mode(prop, "DC Boost Pump", actuator_DC_boost_pump);
}

var _init = func {
        removelistener(lsnr_s);
        install_failures();
    }

var lsnr_s = setlistener("sim/fdm-initialized", _init, 0, 0);
