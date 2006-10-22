##
# Sea Vixen electrical system.
# From the Pilot's Notes; 
# Based on Lightning work by AJ MacLeod
##

# If you want to modify this system, you can specify additional or 
# modify suppliers, buses, and outputs in the "Initialize the electrical system" 
# section below. You shouldn't need to modify the follwing script sections

# Limitations:
# 1. The bus controller is "hard coded" and assumes an input of main battery, 
# generators(s), and external. It only controls the main 24V bus.
# 2. Only the main battery is recharged from the generator output. There is no 
# underpinning mathematical calculation for this process.
# 3. Only 1 controlling property is specifed per entry. If you need more than this,
# an external Nasal script that sets the control property appropriately will be 
# needed. Wherever possible, existing properties have been used. 
# 4. Only the load in the main 24V DC bus is displayed. 
# 5. The load for inverters appears
# in the parent bus.

###
# Initialize internal values
##

#suppliers
external = nil;
battery = nil;
battery_emergency = nil; 
generator_port = nil;
generator_stbd = nil;
inverter_type_108 = nil;
inverter_type_DA1 = nil;

# buses
bus_controller = nil;
inverter_controller = nil;
bus_28VDC = nil;
bus_115VAC_1phase = nil;
bus_28VDC_emergency = nil;
bus_115AC_3phase_emergency = nil;
bus_115AC_3phase = nil;

#variables
var time = 0;
var dt = 0;
var last_time = 0.0;

##
# Initialize the electrical system
#

init_electrical = func {
	print("Initializing Nasal Electrical System");


###
# suppliers 
##

###
#external ("name", "control property", initial switch position, volts)
###

	external = External.new		("external",
					"controls/electric/external-power",
					0,
					28);

###
#batteries ("name", "control property", initial switch position, nomimal voltage,
# nominal current (amps), nominal capacity (amp hours)
# 
###
	battery = Battery.new		("battery-main",
					"controls/electric/battery-switch", 
					1,
					24,
					30,
					25);
	battery_emergency = Battery.new("battery-emergency",
					"controls/electric/battery-switch[1]", 
					0,
					24,
					30,
					25);

###
# generators ("name", "rpm source", "control property", initial switch position, rated voltage
#, rated curent (amps), rpm_threshold )

	generator_port = Generator.new("generator",
					"engines/engine[0]/n1",
					"controls/electric/engine/generator",
					1,
					28.0,
					320.0,
					58);
	generator_stbd = Generator.new("generator[1]",
					"engines/engine[1]/n1",
					"controls/electric/engine[1]/generator",
					1,
					28.0,
					320.0,
					58);

###
# inverters ("name", "source", "control property", initial switch position, factor)

	inverter_type_108 = Inverter.new("inverter-type-108",
					"systems/electrical/outputs/inverter-type-108",
					"controls/electric/inverter-type-108", 
					1,
					4.10714285);
	inverter_type_DA1 = Inverter.new("inverter-type-DA1",
					"systems/electrical/outputs/inverter-type-DA1",
					"controls/electric/inverter-type-108", 
					1,
					4.79166667);
	inverter_type_103A_main = Inverter.new("inverter-type-103A-main",
					"systems/electrical/outputs/inverter-type-103A-main",
					"controls/electric/inverter-type-103A-main", 
					0,
					4.10714285);
	inverter_type_103A_stby = Inverter.new("inverter-type-103A-stby",
					"systems/electrical/outputs/inverter-type-103A-stby",
					"controls/electric/inverter-type-103A-stby", 
					1,
					4.10714285);


###
# buses ("name","source") 
##
		
	bus_28VDC = Bus.new		("28VDC",
					"bus-controller");
	bus_115VAC_1phase = Bus.new	("115VAC-1phase",
					"inverter-type-108");
	bus_28VDC_emergency = Bus.new	("28VDC-Emergency",
					"battery-emergency");
	bus_115AC_3phase_emergency = Bus.new("115AC-3phase-Emergency",
					"inverter-type-DA1-emergency");
	bus_115AC_3phase = Bus.new	("115AC-3phase",
					"inverter-controller");


###
# utilities
##
	bus_controller = BusController.new();
#("name-main", "control-main", initial switch pos, "name-stby", "control-stby",,initial switch pos, threshold for switching(volts))
	inverter_controller = InverterController.new("inverter-type-103A-main",
					"controls/electric/inverter-type-103A-main",
					0,
					"inverter-type-103A-stby",
					"controls/electric/inverter-type-103A-stby",
					1,
					90);
		
		

###
# outputs
# ("name", "control propery", intial switch position, "source bus", load at source voltage)
##

# 28VDC outputs
	boost_pump_1_port = Output.new	("boost-pump",
					"controls/fuel/tank/boost-pump",
					1,
					"28VDC",
					29);
	boost_pump_1_stbd = Output.new	("boost-pump[1]",
					"controls/fuel/tank[1]/boost-pump",
					1,
					"28VDC",
					29);
	boost_pump_2_port = Output.new	("boost-pump[2]",
					"controls/fuel/tank[4]/boost-pump",
					0,
					"28VDC",
					17);
	boost_pump_2_stbd = Output.new	("boost-pump[3]",
					"controls/fuel/tank[5]/boost-pump",
					0,
					"28VDC",
					17);
	boost_pump_3_port = Output.new	("boost-pump[4]",
					"controls/fuel/tank[6]/boost-pump",
					0,
					"28VDC",
					17);
	boost_pump_3_stbd = Output.new	("boost-pump[5]",
					"controls/fuel/tank[7]/boost-pump",
					0,
					"28VDC",
					17);
	boost_pump_4_port = Output.new	("boost-pump[6]",
					"controls/fuel/tank[8]/boost-pump",
					0,
					"28VDC",
					17);
	boost_pump_4_stbd = Output.new	("boost-pump[7]",
					"controls/fuel/tank[9]/boost-pump",
					0,
					"28VDC",
					17);
	boost_pump_pin_port = Output.new("boost-pump[8]",
					"controls/fuel/tank[10]/boost-pump",
					0,
					"28VDC",
					17);
	boost_pump_pin_stbd = Output.new("boost-pump[9]",
					"controls/fuel/tank[11]/boost-pump",
					0,
					"28VDC",
					17);
	auxiliary_pump_2_port = Output.new("auxiliary-pump[2]",
					"controls/fuel/tank[4]/boost-pump",
					0,
					"28VDC",
					17);
	auxiliary_pump_2_stbd = Output.new("auxiliary-pump[3]",
					"controls/fuel/tank[5]/boost-pump",
					0,
					"28VDC",
					17);
	auxiliary_pump_3_port = Output.new("auxiliary-pump[4]",
					"controls/fuel/tank[6]/boost-pump",
					0,
					"28VDC",
					17);
	auxiliary_pump_3_stbd = Output.new("auxiliary-pump[5]",
					"controls/fuel/tank[7]/boost-pump",
					0,
					"28VDC",
					17);
	auxiliary_pump_4_port = Output.new("auxiliary-pump[6]",
					"controls/fuel/tank[8]/boost-pump",
					0,
					"28VDC",
					17);
	auxiliary_pump_4_stbd = Output.new("auxiliary-pump[7]",
					"controls/fuel/tank[9]/boost-pump",
					0,
					"28VDC",
					17);
	inverter_type_108_supply = Output.new("inverter-type-108",
					"controls/electric/inverter",
					1,
					"28VDC",
					43.28);
	autopilot = Output.new		("autopilot",
					"controls/electric/autopilot",
					0,
					"28VDC",
					4.2);	
	pitot_heater_port = Output.new	("pitot-heater",
					"controls/anti-ice/pitot-heat",
					0,
					"28VDC",
					7.5);	
	pitot_heater_stbd = Output.new	("pitot-heater[1]",
					"controls/anti-ice/pitot-heat[1]",
					0,
					"28VDC",
					7.5);	
	cockpit_lighting = Output.new	("instrument-lighting",
					"controls/lighting/instrument-lights",
					0,
					"28VDC",
					4.5);
	taxi_lighting = Output.new	("taxi-lights",
					"controls/lighting/taxi-lights",
					0,
					"28VDC",
					4.5);	
	navigation_lights = Output.new	("navigation-lights",
					"controls/lighting/navigation-lights",
					0,
					"28VDC",
					2.5);
	formation_lights = Output.new	("formation-lights",
					"controls/lighting/formation-lights",
					0,
					"28VDC",
					1.0);	
	windscreen_de_ice = Output.new	("windscreen-de-ice",
					"controls/anti-ice/window-heat",
					0,
					"28VDC",
					1.65);
	hsi = Output.new		("hsi",
					,
					,
					"28VDC",
					0.75);
	turn_cordinator = Output.new	("turn-coordinator",
					,
					,
					"28VDC",
					0.75);
	nav = Output.new		("nav",
					,
					,
					"28VDC",
					1.75);
	nav_1 = Output.new		("nav[1]",
					,
					,
					"28VDC",
					1.75);
	DG = Output.new			("DG",
					,
					,
					"28VDC",
					1.0);
	MRG = Output.new		("MRG",
					,
					,
					"28VDC",
					1.0);
	radar = Output.new		("radar",
					,
					,
					"28VDC",
					6.0);
	inverter_type_103A_main_supply = Output.new("inverter-type-103A-main",
					"controls/electric/inverter-type-103A-main", 
					0,
					"28VDC",
					46);
	inverter_type_103A_stby_supply = Output.new("inverter-type-103A-stby",
					"controls/electric/inverter-type-103A-stby", 
					1,
					"28VDC",
					46);
	gear_pos_indicator = Output.new("gear-pos-indicator",
					,
					,
					"28VDC",
					0.5);

# 115VAC 1 Phase outputs

	TACAN	= Output.new		("tacan",
					,
					,
					"115VAC-1phase",
					0);	
	transponder = Output.new	("transponder",
					,
					,
					"115VAC-1phase",
					0);
					
# 24VDC - emergency outputs

	boost_pump_3_port_mg = Output.new("boost-pump-emergency",
					"controls/fuel/tank[6]/boost-pump",
					1,
					"28VDC-Emergency",
					17);
	boost_pump_3_stbd_mg = Output.new("boost-pump-emergency[1]",
					"controls/fuel/tank[7]/boost-pump",
					1,
					"28VDC-Emergency",
					17);
	auxiliary_pump_2_port_mg = Output.new("auxiliary-pump-emergency[1]",
					"controls/fuel/tank[4]/boost-pump[1]",
					0,
					"28VDC",
					3.5);
	auxiliary_pump_2_stbd_mg = Output.new("auxiliary-pump-emergency[2]",
					"controls/fuel/tank[5]/boost-pump[1]",
					0,
					"28VDC-Emergency",
					3.5);
	auxiliary_pump_3_port_mg = Output.new("auxiliary-pump-emergency[3]",
					"controls/fuel/tank[6]/boost-pump[1]",
					0,
					"28VDC-Emergency",
					3.5);
	auxiliary_pump_3_stbd_mg = Output.new("auxiliary-pump-emergency[4]",
					"controls/fuel/tank[7]/boost-pump[1]",
					0,
					"28VDC-Emergency",
					3.5);
	auxiliary_pump_4_port_mg = Output.new("auxiliary-pump-emergency[5]",
					"controls/fuel/tank[8]/boost-pump[1]",
					0,
					"28VDC-Emergency",
					3.5);
	auxiliary_pump_4_stbd_mg = Output.new("auxiliary-pump-emergency[6]",
					"controls/fuel/tank[9]/boost-pump[1]",
					0,
					"28VDC-Emergency",
					3.5);
	inverter_type_DA1_mg = Output.new("inverter-type-DA1",
					,
					,
					"28VDC-Emergency",
					1.5);
	gear_pos_indicator = Output.new("gear-pos-indicator-emergency",
					,
					,
					"28VDC-Emergency",
					0.5);

# 115AC-3phase - emergency outputs

	fuel_gauge_mg = Output.new("fuel-gauge-emergency",
					,
					,
					"115AC-3phase-Emergency",
					0.5);

# 115AC-3phase - outputs

	flight_instruments = Output.new("flight-instruments",
					,
					,
					"115AC-3phase",
					0.5);
	fuel_gauges = Output.new("fuel-gauges",
					,
					,
					"115AC-3phase",
					0.5);
	flow_meter = Output.new("flow-meter",
					,
					,
					"115AC-3phase",
					0.5);
	top_temperature_controls = Output.new("top_temperature_controls",
					,
					,
					"115AC-3phase",
					0.5);
	fire_warning_system = Output.new("fire-warning-system",
					,
					,
					"115AC-3phase",
					0.5);
	auto_throttle = Output.new("auto-throttle",
					,
					,
					"115AC-3phase",
					0.5);
	

# Request that the update fuction be called next frame
	settimer(update_electrical, 0);
}

###
# Specify classes - this section should not require modification
##

External = {
	new : func(name, control, switch, volts){
		var obj = { parents : [External]};
		obj.name = name;
		obj.control = props.globals.getNode(control, 1);
		obj.control.setBoolValue(switch);
		obj.extvolts = volts;
		obj.output_volts = 0;
		return obj;
	},
	get_output_volts : func {
		if( me.control.getValue() ){
			me.output_volts = me.extvolts;
		} else {
			me.output_volts = 0;
		}
		me.set_props();
		return me.output_volts;
	},
	set_props : func{
		props.globals.getNode("systems/electrical/suppliers/", 1).getChild(me.name,0 ,1 ).setDoubleValue(me.output_volts);
	},
};	

Battery = {
	new : func ( name, control, switch, volts, amps, amphrs) {
		var obj = { parents : [Battery]};
		obj.control = props.globals.getNode(control, 1);
		obj.control.setBoolValue(switch);
		obj.name = name;
		obj.rated_volts = volts;
		obj.rated_amps = amps;
		obj.rated_amp_hours = amphrs;
		obj.charge_norm = 1.0;
		obj.charge_amps = 14.0;
		obj.output_volts = 0;
		obj.output_amps = 0;
		obj.set_props();
		append(Battery.list, obj); 
		return obj;
	},
	set_charge : func ( dt ) {
		amphrs_supplied = me.charge_amps * dt / 3600.0;
		supplied_norm = amphrs_supplied / me.rated_amp_hours;
		me.charge_norm += supplied_norm;
		me.update(0, dt);
	},
	update : func( amps, dt ) {
		if ( me.control.getValue()) {
			#calculate remaining charge
			amphrs_used = amps * dt / 3600.0;
			used_norm = amphrs_used / me.rated_amp_hours;
			me.charge_norm -= used_norm;
			if ( me.charge_norm < 0.0 ) {
					me.charge_norm = 0.0;
			} elsif ( me.charge_norm > 1.0 ) {
					me.charge_norm = 1.0;
			}	
			#calculate output volts
			var v = 1.0 - me.charge_norm;
			var tmp = -(3.0 * v - 1.0);
			var factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
			me.output_volts = me.rated_volts * factor ;
			#calculate output amps
			a = 1.0 - me.charge_norm;
			tmp = -(3.0 * a - 1.0);
			factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
			me.output_amps = me.rated_amps * factor;
			me.set_props();
		} else {
			me.output_volts = 0;
		}
	},
	get_output_volts : func {
		return me.output_volts; 
	},
	get_output_amps : func {
		return me.output_amps;	
	},
	get_name : func {
		return me.name
	},
	set_props : func {
		props.globals.getNode("systems/electrical/suppliers", 1).getChild(me.name,0,1).setDoubleValue(me.output_volts);
	},
	list : [],
};


##
# Generator model class.

Generator = {
	 new : func(name, source, control, switch, volts, amps, threshold) {
		var obj = { parents : [ Generator ] };
		obj.name = name;
		obj.rpm_source = props.globals.getNode( source, 1 );
		obj.control = props.globals.getNode( control, 1 );
		obj.control.setBoolValue( switch );
		obj.rated_volts = volts;
		obj.rated_amps = amps;
		obj.rpm_threshold = threshold;
		obj.output_volts = 0;
		obj.output_amps = 0;
		obj.online = 0;
		obj.props_node = props.globals.getNode( "systems/electrical/suppliers", 1 ).getChild(name, 0, 1);
		append(Generator.list, obj); 
		return obj;
	},
	update : func {
		# scale generator output for n1 < rpm_threshold.  For rpms >= 
		# rpm_threshold give full output.  
		
		rpm =  me.rpm_source.getValue();
		factor = rpm / me.rpm_threshold;
		if ( factor > 1.0 ) {
				factor = 1.0;
		}
		if ( me.control.getValue() ){
			me.output_volts = me.rated_volts * factor;
		} else {
			me.output_volts = 0
		}
		if ( me.output_volts >= 25 ){
			me.online = 1;
		} else {
			me.online = 0;
		}
		# adjust output amps by input voltage (V = IR)
		me.output_amps = me.output_volts * me.rated_amps / me.rated_volts;
		me.set_props();
	},
	apply_load : func( load ) {
		available_amps = me.get_output_amps();
		return amps;
	},
	get_output_volts : func {
		return me.output_volts;
	},
	get_output_amps : func {
		return me.output_amps;
	},
	get_online : func {
		return me.online;
	},
	set_props : func {
		me.props_node.setDoubleValue(me.output_volts);
	},
	list : [],
};

##
# electical output class
#

Output = {
	 new : func (prop, control, switch, bus, load) {
		var obj = { parents : [Output] };
		obj.prop = props.globals.getNode("systems/electrical/outputs", 1).getChild(prop,0,1);
		if (control != nil){
		obj.control = props.globals.getNode(control,1);
		obj.control.setBoolValue(switch);
		} else {
		obj.control = "";
		}
		
		obj.bus = bus;
		obj.resistance = 28 / load;
		obj.volts = 0;
		obj.load = 0;
		obj.set_prop();
		append(Output.list, obj); 
		return obj;
	},
	update : func (volts) {
		if ( me.control != "" ) {
			if (me.control.getValue()){
				me.volts = volts;
				me.load = me.volts / me.resistance;
			} else {
				me.volts = 0;
				me.load = 0
			}
		} else {
			me.volts = volts;
			me.load = me.volts / me.resistance;
		}
		me.set_prop();
		return me.load; 
	},
	get_bus : func () {
		return me.bus;
	},
	set_prop : func {
		me.prop.setDoubleValue(me.volts);
	},
	list : [],
};


##
# inverter class
#
Inverter = {
	new : func (name, source, control, switch, factor) {
		var obj = { parents : [Inverter] };
		obj.name = name;
		obj.source = props.globals.getNode( source, 1 );
		obj.source.setDoubleValue( 0 );
		obj.control = props.globals.getNode( control, 1 );
		obj.control.setBoolValue( switch );
		obj.factor = factor;
		obj.output_volts = 0;
		obj.props_node = props.globals.getNode( "systems/electrical/suppliers", 1).getChild( name, 0, 1 );
		obj.set_props();
		append( Inverter.list, obj );
		return obj;
	},
	update : func {
		if ( me.control != "" ) {
			if ( me.control.getValue() ){
				me.output_volts = me.source.getValue() * me.factor;
			} else {
				me.output_volts = 0;
			}
		} else {
			me.output_volts = me.source.getValue() * me.factor;
		}
		me.set_props();
		return;
	},
	get_output_volts : func {
		return me.output_volts;
	},
	get_name : func {
		return me.name;
	},
	set_props : func {
		me.props_node.setDoubleValue( me.output_volts );
	},
	list : [],
};

##
# bus controller class
#
BusController = {
	new : func () {
		var obj = { parents : [BusController] };
		obj.volts = 0;
		obj.master_bat = props.globals.getNode( "controls/electric/battery-switch", 1);
		return obj;
	},
	update :  func (dt) {
		# determine power source
		me.volts = 0.0;
		var power_source = nil;
		
		# if the main battery is conected, use that
		if ( me.master_bat.getValue() ) {
			me.volts = battery.get_output_volts();
			power_source = "battery";
		}
		
		# if generators are on line and giving more volts than the battery, use them 
		foreach (var g; Generator.list) {
			if ( g.get_online() and ( g.get_output_volts() > me.volts ) ) {
				me.volts = g.get_output_volts(); 
				power_source = "generator";
			}
		}
		
		#if external power is connected, use it
		if ( external.get_output_volts() > me.volts ) {
			me.volts = external.get_output_volts();
			power_source = "external";
		}
		
		# if the poser source is a battery, discharge/charge it as appropriate
		if ( power_source == "battery" ) {
			battery.update(bus_28VDC.get_load(), dt );
		} else {
			battery.set_charge ( dt )
		}
		
		me.set_props();
		return power_source;
	},
	get_output_volts : func {
		return me.volts; 
	},
	set_props : func {
		props.globals.getNode( "systems/electrical/volts", 1).setDoubleValue( me.volts );
		props.globals.getNode( "systems/electrical/amps", 1).setDoubleValue( bus_28VDC.get_load() );
	},
};

##
# inverter controller class
#
InverterController = {
	new : func ( 	name_main, control_main, switch_main, 
			name_stby, control_stby, switch_stby,
			threshold) {
		var obj = { parents : [InverterController] };
		
		obj.main = name_main;
		obj.main_control = props.globals.getNode( control_main, 1);
		obj.main_control.setBoolValue( switch_main ); 
		obj.stby = name_stby;
		obj.stby_control = props.globals.getNode( control_stby, 1);
		obj.stby_control.setBoolValue( switch_stby ); 
		obj.threshold = threshold;
		obj.volts = 0;
		return obj;
	},
	update :  func () {
		# if at least 1 generators is on line, switch on main inverter, and 
		# switch off stby
		var n = 0;
		me.volts = 0; 
		foreach ( var g; Generator.list ) {
			if ( g.get_online() ) {
				n += 1;
			}
		}
		
		# if n is greater than 0, at least 1 generator must be online
		if ( n > 0 ) {
			me.main_control.setBoolValue(1);
		} else {	
			me.main_control.setBoolValue(0);
		}
		
		# check the output voltage
		foreach ( var i; Inverter.list ) {
			if ( i.get_name() == me.main  ) {
				me.volts = i.get_output_volts();
			}
		}
			
		#set the stby switch state
		if ( me.volts < me.threshold ) {
			me.stby_control.setBoolValue(1);
			foreach ( var i; Inverter.list ) {
				if ( i.get_name() == me.stby  ) {
					me.volts = i.get_output_volts();
				}
			}
		} else {
			me.stby_control.setBoolValue(0);
		}

	},
	get_output_volts : func {
		return me.volts; 
	},
};

##
# bus class
#
Bus = {
	new : func (name, source) {
		var obj = { parents : [Bus] };
		obj.name = name;
		obj.source = source;
		obj.volts = 0;
		obj.load = 0;
		append(Bus.list, obj);
		return obj;
	},
	update :  func ( dt ){
		me.load = 0;
		me.volts = 0;
		var power_source = "";
		# get the power source
		if ( me.source == "inverter-controller" ) {
			me.volts = inverter_controller.get_output_volts();	
			power_source = "inverter-controller";
		} elsif ( me.source == "bus-controller" ) {
			me.volts = bus_controller.get_output_volts();
			power_source = "bus-controller";
		} else { # we have to search all potential sources
			# first search all the inverters
			foreach (var i; Inverter.list) {
				if ( i.get_name() == me.source ) {
					me.volts = i.get_output_volts();
					power_source = "inverter";
				} 
			}	
			
			# now search all the batteries	
			foreach (var b; Battery.list) {
				if ( b.get_name() == me.source ) {
					me.volts = b.get_output_volts();
					power_source = "battery";
				}
			}
		}
			
		# next, search all the outputs for the ones tied to this bus, and sum the load		
		foreach (var o; Output.list) {
			if ( o.get_bus() == me.name ){
				me.load += o.update(me.volts);
			}
		}	
		
		# last, if the source is a battery, discharge it.
		if (power_source == "battery") {
			foreach (var b; Battery.list) {
				if ( b.get_name() == me.source ) {
						b.update(me.load, dt);
				}
			}
		}		
		
		return me.load;
	},
	get_load : func{
		return me.load;
	},
	list : [],
};
		
###
# This is the main loop which keeps eveything updated
#
update_electrical = func {
	time = props.globals.getNode("/sim/time/elapsed-sec", 1).getValue();
	dt = time - last_time;
	last_time = time;
	
		
		foreach (var g; Generator.list) {
			g.update();	
		}		
		
		foreach ( var i; Inverter.list) {
			i.update();	
		}	
		
		bus_controller.update(dt);
		inverter_controller.update();
		
		foreach (var b; Bus.list) {
			b.update(dt);	
		}		
		
# Request that the update fuction be called again 
		settimer(update_electrical, 0.3 );
}

###
# Setup a timer based call to initialized the electrical system as
# soon as possible.
settimer(init_electrical, 0);


