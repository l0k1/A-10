var ARM_SIM = -1;
var ARM_OFF = 0;# these 3 are needed by fire-control.
var ARM_ARM = 1;
var pause_listener = 0;
var debug_a10 = 0;
props.globals.getNode("sim/model/A-10/weapons/master-arm-switch",1).setIntValue(0);

var fcs = nil;
var pylonI = nil;
var pylon1 = nil;
var pylon2 = nil;
var pylon3 = nil;
var pylon4 = nil;
var pylon5 = nil;
var pylon6 = nil;
var pylon7 = nil;
var pylon8 = nil;
var pylon9 = nil;
var pylon10 = nil;
var pylon11 = nil;

var msgA = "If you need to repair now, then use Menu-Location-SelectAirport instead.";
var msgB = "Please land before changing payload.";
var msgC = "Please land before refueling.";

var cannon = stations.SubModelWeapon.new("30mm Cannon", 0.254, 1174, [1], [], props.globals.getNode("controls/armament/trigger-gun",1), 0, nil,0);
cannon.typeShort = "GUN";
cannon.brevity = "Guns guns";
var hyd701 = stations.SubModelWeapon.new("LAU-68", 23.6, 7, [5], [], props.globals.getNode("controls/armament/trigger-hydra-1",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd701.typeShort = "M151";
hyd701.brevity = "Rockets away";
var hyd702 = stations.SubModelWeapon.new("LAU-68", 23.6, 7, [6], [], props.globals.getNode("controls/armament/trigger-hydra-2",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd702.typeShort = "M151";
hyd702.brevity = "Rockets away";
var hyd703 = stations.SubModelWeapon.new("LAU-68", 23.6, 7, [7], [], props.globals.getNode("controls/armament/trigger-hydra-3",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd703.typeShort = "M151";
hyd703.brevity = "Rockets away";
var hyd707 = stations.SubModelWeapon.new("LAU-68", 23.6, 7, [8], [], props.globals.getNode("controls/armament/trigger-hydra-7",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd707.typeShort = "M151";
hyd707.brevity = "Rockets away";
var hyd708 = stations.SubModelWeapon.new("LAU-68", 23.6, 7, [9], [], props.globals.getNode("controls/armament/trigger-hydra-8",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd708.typeShort = "M151";
hyd708.brevity = "Rockets away";
var hyd709 = stations.SubModelWeapon.new("LAU-68", 23.6, 7, [10], [], props.globals.getNode("controls/armament/trigger-hydra-9",1), 1, func{return getprop("payload/armament/fire-control/serviceable") and getprop("controls/armament/master-arm") == 1;},1);
hyd709.typeShort = "M151";
hyd709.brevity = "Rockets away";
var fuelTankLeft600 = stations.FuelTank.new("600 Gal Fuel Tank", "TK600", 4, 600, "sim/model/A-10/weapons/wingtankL");
var fuelTankCenter600 = stations.FuelTank.new("600 Gal Fuel Tank", "TK600", 5, 600, "sim/model/A-10/weapons/wingtankC");
var fuelTankRight600 = stations.FuelTank.new("600 Gal Fuel Tank", "TK600", 6, 600, "sim/model/A-10/weapons/wingtankR");
var ecm131L = stations.Smoker.new("AN/ALQ-131", "AL131", "A-10/stores/ecm-mounted-left");
var ecm184L = stations.Smoker.new("AN/ALQ-184", "AL184", "A-10/stores/ecm-mounted-left");
var ecm131R = stations.Smoker.new("AN/ALQ-131", "AL131", "A-10/stores/ecm-mounted-right");
var ecm184R = stations.Smoker.new("AN/ALQ-184", "AL184", "A-10/stores/ecm-mounted-right");

fuelTankLeft600.del();
fuelTankCenter600.del();
fuelTankRight600.del();

var pylonSets = {
    empty: {name: "Empty", content: [], fireOrder: [], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
    mm20: {name: "30mm Cannon", content: [cannon], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
    mk82: {name: "1 x MK-82", content: ["MK-82"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 100, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    cbu87: {name: "1 x CBU-87", content: ["CBU-87"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 100, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    mk84: {name: "1 x MK-84", content: ["MK-84"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 220, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    mk82air: {name: "1 x MK-82AIR", content: ["MK-82AIR"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 100, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    mk82tri: {name: "3 x MK-82", content: ["MK-82","MK-82","MK-82"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 313, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    mk82atri: {name: "3 x MK-82AIR", content: ["MK-82AIR","MK-82AIR","MK-82AIR"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 313, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    Daim9: {name: "2 x AIM-9M", content: ["AIM-9M","AIM-9M"], fireOrder: [0,1], launcherDragArea: 0.0, launcherMass: 90, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
    lau681: {name: "LAU-68", content: [hyd701], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 202.5, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    lau682: {name: "LAU-68", content: [hyd702], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 202.5, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    lau683: {name: "LAU-68", content: [hyd703], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 202.5, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    lau687: {name: "LAU-68", content: [hyd707], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 202.5, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    lau688: {name: "LAU-68", content: [hyd708], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 202.5, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    lau689: {name: "LAU-68", content: [hyd709], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 202.5, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    agm65tri: {name: "3 x AGM-65B", content: ["AGM-65B","AGM-65B","AGM-65B"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 689, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    left600: {name: fuelTankLeft600.type, content: [fuelTankLeft600], fireOrder: [0], launcherDragArea: 0, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
    center600: {name: fuelTankCenter600.type, content: [fuelTankCenter600], fireOrder: [0], launcherDragArea: 0, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
    right600: {name: fuelTankRight600.type, content: [fuelTankRight600], fireOrder: [0], launcherDragArea: 0, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
    alq131L: {name: "AN/ALQ-131(V) ECM Pod", content: [ecm131L], fireOrder: [0], launcherDragArea: 0, launcherMass: 480, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 2},
    alq184L: {name: "AN/ALQ-184(V) ECM Pod", content: [ecm184L], fireOrder: [0], launcherDragArea: 0, launcherMass: 480, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 2},
    alq131R: {name: "AN/ALQ-131(V) ECM Pod", content: [ecm131R], fireOrder: [0], launcherDragArea: 0, launcherMass: 480, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 2},
    alq184R: {name: "AN/ALQ-184(V) ECM Pod", content: [ecm184R], fireOrder: [0], launcherDragArea: 0, launcherMass: 480, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 2},
};

#sets
var pylon1set = [pylonSets.empty, pylonSets.Daim9, pylonSets.mk82, pylonSets.mk82air, pylonSets.cbu87, pylonSets.alq131L, pylonSets.alq184L];
var pylon2set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82air, pylonSets.cbu87, pylonSets.lau681];
var pylon3set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82air, pylonSets.mk84, pylonSets.cbu87, pylonSets.mk82tri, pylonSets.mk82atri, pylonSets.lau682];
var pylon4set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82air, pylonSets.mk84, pylonSets.cbu87, pylonSets.mk82tri, pylonSets.mk82atri, pylonSets.lau683, pylonSets.left600];
var pylon5set = [pylonSets.empty, pylonSets.mk82air, pylonSets.mk82, pylonSets.mk84, pylonSets.cbu87];
var pylon6set = [pylonSets.empty, pylonSets.center600];
var pylon7set = [pylonSets.empty, pylonSets.mk82air, pylonSets.mk82, pylonSets.mk84, pylonSets.cbu87];
var pylon8set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82air, pylonSets.mk84, pylonSets.cbu87, pylonSets.mk82tri, pylonSets.mk82atri, pylonSets.lau687, pylonSets.right600];
var pylon9set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82air, pylonSets.mk84, pylonSets.cbu87, pylonSets.mk82tri, pylonSets.mk82atri, pylonSets.lau688];
var pylon10set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82air, pylonSets.cbu87, pylonSets.lau689];
var pylon11set = [pylonSets.empty, pylonSets.Daim9, pylonSets.mk82, pylonSets.mk82air, pylonSets.cbu87, pylonSets.alq131R, pylonSets.alq184R];

# pylons
pylonI = stations.InternalStation.new("Internal gun mount", 11, [pylonSets.mm20], props.globals.getNode("sim/weight[11]/weight-lb",1));
pylon1 = stations.Pylon.new("Pylon 1", 0, [7.38, -5.93, -0.22], pylon1set,  0, props.globals.getNode("sim/weight[0]/weight-lb",1),props.globals.getNode("sim/drag[0]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[0]/selected");});
pylon2 = stations.Pylon.new("Pylon 2", 1, [7.70, -4.86, -0.38], pylon2set,  1, props.globals.getNode("sim/weight[1]/weight-lb",1),props.globals.getNode("sim/drag[1]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[1]/selected");});
pylon3 = stations.Pylon.new("Pylon 3", 2, [7.65, -3.61, -0.52], pylon3set,  2, props.globals.getNode("sim/weight[2]/weight-lb",1),props.globals.getNode("sim/drag[2]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[2]/selected");});
pylon4 = stations.Pylon.new("Pylon 4", 3, [7.64, -1.68, -0.63], pylon4set,  3, props.globals.getNode("sim/weight[3]/weight-lb",1),props.globals.getNode("sim/drag[3]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[3]/selected");});
pylon5 = stations.Pylon.new("Pylon 5", 4, [7.61, -0.56, -0.63], pylon5set,  4, props.globals.getNode("sim/weight[4]/weight-lb",1),props.globals.getNode("sim/drag[4]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[4]/selected");});
pylon6 = stations.Pylon.new("Pylon 6", 5, [7.61, 0, 0], pylon6set,  5, props.globals.getNode("sim/weight[5]/weight-lb",1),props.globals.getNode("sim/drag[5]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[5]/selected");});
pylon7 = stations.Pylon.new("Pylon 7", 6, [7.61, 0.56, -0.63], pylon7set,  6, props.globals.getNode("sim/weight[6]/weight-lb",1),props.globals.getNode("sim/drag[6]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[6]/selected");});
pylon8 = stations.Pylon.new("Pylon 8", 7, [7.64, 1.68, -0.63], pylon8set,  7, props.globals.getNode("sim/weight[7]/weight-lb",1),props.globals.getNode("sim/drag[7]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[7]/selected");});
pylon9 = stations.Pylon.new("Pylon 9", 8, [7.65, 3.61, -0.52], pylon9set,  8, props.globals.getNode("sim/weight[8]/weight-lb",1),props.globals.getNode("sim/drag[8]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[8]/selected");});
pylon10 = stations.Pylon.new("Pylon 10", 9, [7.70, 4.86, -0.38], pylon10set,  9, props.globals.getNode("sim/weight[9]/weight-lb",1),props.globals.getNode("sim/drag[9]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[9]/selected");});
pylon11 = stations.Pylon.new("Pylon 11", 10, [7.38, 5.93, -0.22], pylon11set,  10, props.globals.getNode("sim/weight[10]/weight-lb",1),props.globals.getNode("sim/drag[10]/dragarea-sqft",1),func{return getprop("payload/armament/fire-control/serviceable") and getprop("systems/electrical/outputs/gau-8")>20;},func{return getprop("A-10/stations/station[10]/selected");});



var pylons = [pylon1,pylon2,pylon3,pylon4,pylon5,pylon6,pylon7,pylon8,pylon9,pylon10,pylon11,pylonI];

# The order of first vector in this line is the default pylon order weapons is released in.
# The order of second vector in this line is the order cycle key would cycle through the weapons:
fcs = fc.FireControl.new(pylons, [11,7,3,10,0,9,1,8,2,6,4], ["30mm Cannon", "AIM-9M", "MK-82", "MK-82AIR", "MK-84", "CBU-87", "AGM-65B", "LAU-68"]);

#print("** Pylon & fire control system started. **");
var getDLZ = func {
    if (fcs != nil and getprop("model/A-10/master-arm-switch")) {
        var w = fcs.getSelectedWeapon();
        if (w!=nil and w.parents[0] == armament.AIM) {
            var result = w.getDLZ(1);
            if (result != nil and size(result) == 5 and result[4]<result[0]*1.5 and armament.contact != nil and armament.contact.get_display()) {
                #target is within 150% of max weapon fire range.
        	    return result;
            }
        }
    }
    return nil;
}

var gau8_ammo_count="/ai/submodels/submodel[1]/count";
var a10_ammo_weight="/yasim/weights/ammunition-weight-lbs";
var reloadCannon = func {
    if (getprop("velocities/groundspeed-kt") < 5) {
        setprop (gau8_ammo_count, 1174);
        var bweight=1174*0.9369635;
        setprop(a10_ammo_weight, bweight);
        gui.popupTip ("GAU-8/A reloaded with 1174 rounds", 5);    
    } else {
        gui.popupTip(msgB, 5);
    }
}

var bore_loop = func {
    #enables firing of aim9 without radar. The aim-9 seeker will be fixed 3.5 degs below bore and any aircraft the gets near that will result in lock.
    bore = 0;
    if (fcs != nil) {
        var standby = 1;#getprop("sim/multiplay/generic/int[2]");
        var aim = fcs.getSelectedWeapon();
        if (aim != nil and (aim.type == "AIM-9M")) {
            if (standby == 1) {
                #aim.setBore(1);
                aim.setContacts(radar_system.getCompleteList());
                aim.commandDir(0,-3.5);# the real is bored to -6 deg below real bore
                bore = 1;
            } else {
                aim.commandRadar();
                aim.setContacts([]);
            }
        }
    }
    settimer(bore_loop, 0.5);
};
var bore = 0;
if (fcs!=nil) {
    bore_loop();
}


var ripple = func {
    fcs.setRippleDist(getprop("controls/armament/ripple-dist"));
    fcs.setRippleMode(getprop("controls/armament/ripple"));
};

setlistener("controls/armament/ripple-dist", ripple());
setlistener("controls/armament/ripple", ripple());

#StationSelectionListener
print("StationEnablePropStart");
var enable_react = func (node) {
    pause_listener = 1;
    var weapon_type_enabled = "";
    var weapons = pylons[node.getParent().getIndex()].getWeapons();
    foreach(var w ; weapons) {
        if (w != nil) {
            weapon_type_enabled = w.type;
            break;
        }
    }
    if (debug_a10) print("Weapon enabled on station ",node.getParent().getIndex()," is: ",weapon_type_enabled);
    if (weapon_type_enabled == "" and node.getValue()) {
        # Something was enabled that does not have any weapons. Delesect everything else.
        foreach(var station ; station_enable) {
            if (station.getParent().getIndex() != node.getParent().getIndex()) {
                station.setBoolValue(0);
                if (debug_a10) print("Deselect station ",station.getParent().getIndex());
            }
        }
    } else {
        for(var j = 0; j <= 10; j+= 1) {
            if (j != node.getParent().getIndex()) {
                var weapons_here = pylons[j].getWeapons();
                var has_same_type = 0;
                foreach(var w ; weapons_here) {
                    if (w != nil and weapon_type_enabled == w.type) {
                        has_same_type = 1;
                    }
                }
                station_enable[j].setBoolValue(station_enable[j].getValue() and has_same_type);
                if (debug_a10) print("Selecting station ",j,": ", station_enable[j].getValue() and has_same_type);
            }
        }
    }
    if (node.getValue()) {
        fcs.selectPylon(node.getParent().getIndex());# This selects it in the fire-control, so dont have to use 'w' key.
    }
    pause_listener = 0;
};

# The station enable properties
var station_enable = [];
for(var i = 0; i <=10 ; i+=1) {
    var p = props.globals.getNode("A-10/stations/station["~i~"]/selected", 0 );
    if (p == nil) {print("Properties do not exist!"); break;}
    append(station_enable, p);
    setlistener(p, func (node) {if (!pause_listener) enable_react(node);});
}
print("StationEnablePropEnd");
