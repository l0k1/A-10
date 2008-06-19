# controls:
# - controls/APU/off-start-switch
# - controls/APU/serviceable
# - controls/APU/generator-serviceable
# - systems/electrical/outputs/apu-start-system
# - sim/model/A-10/systems/apu/out-of-fuel
# - sim/model/A-10/systems/apu/egt-overt
# - apu's start/stop animation:
# - sim/model/A-10/system/apu/rpm-norm
# - sim/model/A-10/system/apu/tmp
# - outputs:
# - systems/electrical/APU-gen-volts
# - sim/model/A-10/systems/apu/fuel-consumed-lbs

var update_loop = func {
	var fuel_cons = 0.0;
	var apu_rpm = getprop("sim/model/A-10/systems/apu/rpm-norm");
	var apu_temp = getprop("sim/model/A-10/systems/apu/temp");
	var apu_start_system = getprop("systems/electrical/outputs/apu-start-system");
	var apu_gen_volts = getprop("systems/electrical/APU-gen-volts");
	var apu_rpm_goal = 0.0;
	var apu_temp_goal = getprop("environment/temperature-degc");
	if((apu_start_system >= 23) and !getprop("sim/model/A-10/systems/apu/out-of-fuel") and !getprop("sim/model/A-10/systems/apu/egt-overt") and (getprop("environment/pressure-inhg")>16.89)) {
		# APU running/starting we try to reach the 100% rpm
		apu_rpm_goal = 100;
		apu_temp_goal = apu_rpm_goal * 6;
	}
	# APU generator not runnig, while APU running so APU would come very hot.
	if((apu_gen_volts < 23) and (apu_start_system > 23) and !getprop("sim/model/A-10/systems/apu/egt-overt"))
		apu_temp_goal = apu_rpm_goal * 9;
	apu_rpm = A10.apuRpmFilter.filter(apu_rpm_goal);
	apu_temp = A10.apuTempFilter.filter(apu_temp_goal);
	# APU overheating: we shutdown it automatically during ground operation
	if((apu_temp > 720) and getprop("gear/gear[1]/wow"))
		setprop("sim/model/A-10/systems/apu/egt-overt", 1);
	# RaZ apu/egt-overt if we stop the APU
	if(getprop("sim/model/A-10/systems/apu/egt-overt") and !getprop("controls/APU/off-start-switch") and (apu_rpm < 10))
		setprop("sim/model/A-10/systems/apu/egt-overt", 0);
	# APU overheating we kill it
	if(apu_temp > 850) { setprop("controls/APU/serviceable", 0); }
	setprop("sim/model/A-10/systems/apu/rpm-norm", apu_rpm);
	setprop("sim/model/A-10/systems/apu/temp", apu_temp);
	# fuel consumption @ rpm 100% => 500pph
	if((apu_rpm > 10) and (apu_start_system >= 23))
		fuel_cons = getprop("sim/model/A-10/systems/apu/fuel-consumed-lbs") + (apu_rpm * 0.00138889 * A10.UPDATE_PERIOD);
	setprop("sim/model/A-10/systems/apu/fuel-consumed-lbs", fuel_cons);
	if((!getprop("controls/APU/off-start-switch") and getprop("controls/electric/APU-generator")) or ((apu_gen_volts > 23) and (getprop("controls/electric/engine[0]/generator") or getprop("controls/electric/engine[1]/generator")))) {
		# TODO : make a better systems/electrical/power_source and if APU gen is PWR and power_source is not apu then light on
		setprop("systems/A-10-electrical/apu-gen-caution-light", 1);
	} else {
		setprop("systems/A-10-electrical/apu-gen-caution-light", 0);
	}
}
