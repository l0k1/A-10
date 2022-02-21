var ARM_SIM = -1;
var ARM_OFF = 0;# these 3 are needed by fire-control.
var ARM_ARM = 1;
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

var cannon = stations.SubModelWeapon.new("30mm Cannon", 0.254, 150, [0], [], props.globals.getNode("sim/model/A-10/weapons/gun-rate-switch",1), 0, nil,0);
cannon.typeShort = "GUN";
cannon.brevity = "Guns guns";
var lau = stations.SubModelWeapon.new("LAU-68", 0.254, 150, [0], [], props.globals.getNode("controls/armament/trigger",1), 0, nil,0);

var fuelTankLeft600 = stations.FuelTank.new("600 Gal Fuel Tank", "TK600", 4, 600, "sim/model/A-10/weapons/wingtankL");
var fuelTankCenter600 = stations.FuelTank.new("600 Gal Fuel Tank", "TK600", 5, 600, "sim/model/A-10/weapons/wingtankC");
var fuelTankRight600 = stations.FuelTank.new("600 Gal Fuel Tank", "TK600", 6, 600, "sim/model/A-10/weapons/wingtankR");
var ecm131 = stations.Smoker.new("AN/ALQ-131", "AL131", "A-10/stores/ecm-mounted");

fuelTankLeft600.del();
fuelTankCenter600.del();
fuelTankRight600.del();

var pylonSets = {
    empty: {name: "Empty", content: [], fireOrder: [], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
    mm20: {name: "30mm Cannon", content: [cannon], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
    mk82: {name: "1 x MK-82", content: ["MK-82"], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 500, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    mk82tri: {name: "3 x MK-82", content: ["MK-82","MK-82","MK-82"], fireOrder: [0,1,2], launcherDragArea: 0.0, launcherMass: 500, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    Daim9: {name: "2 x AIM-9", content: ["AIM-9","AIM-9"], fireOrder: [0,1], launcherDragArea: 0.0, launcherMass: 90, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
    lau68: {name: "LAU-68", content: [lau], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 202.5, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 3},
    left600: {name: fuelTankLeft600.type, content: [fuelTankLeft600], fireOrder: [0], launcherDragArea: 0, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
    center600: {name: fuelTankCenter600.type, content: [fuelTankCenter600], fireOrder: [0], launcherDragArea: 0, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
    right600: {name: fuelTankRight600.type, content: [fuelTankRight600], fireOrder: [0], launcherDragArea: 0, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
};

#sets
var pylon1set = [pylonSets.empty, pylonSets.Daim9, pylonSets.mk82];
var pylon2set = [pylonSets.empty, pylonSets.mk82, pylonSets.lau68];
var pylon3set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82tri, pylonSets.lau68];
var pylon4set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82tri, pylonSets.lau68, pylonSets.left600];
var pylon5set = [pylonSets.empty, pylonSets.mk82];
var pylon6set = [pylonSets.empty, pylonSets.mk82, pylonSets.center600];
var pylon7set = [pylonSets.empty, pylonSets.mk82];
var pylon8set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82tri, pylonSets.lau68, pylonSets.right600];
var pylon9set = [pylonSets.empty, pylonSets.mk82, pylonSets.mk82tri, pylonSets.lau68];
var pylon10set = [pylonSets.empty, pylonSets.mk82, pylonSets.lau68];
var pylon11set = [pylonSets.empty, pylonSets.Daim9, pylonSets.mk82];

# pylons
pylonI = stations.InternalStation.new("Internal gun mount", 11, [pylonSets.mm20], props.globals.getNode("sim/weight[11]/weight-lb",1));
pylon1 = stations.Pylon.new("Pylon 1", 0, [0.103, 0.310,  2.875], pylon1set,  0, props.globals.getNode("sim/weight[0]/weight-lb",1),props.globals.getNode("sim/drag[0]/dragarea-sqft",1),func{return 1});
pylon2 = stations.Pylon.new("Pylon 2",         1, [0.108, 0.085, 1.824], pylon2set,  1, props.globals.getNode("sim/weight[1]/weight-lb",1),props.globals.getNode("sim/drag[1]/dragarea-sqft",1),func{return 1});
pylon3 = stations.Pylon.new("Pylon 3",          2, [0.022, -0.058, 0.604], pylon3set,  2, props.globals.getNode("sim/weight[2]/weight-lb",1),props.globals.getNode("sim/drag[2]/dragarea-sqft",1),func{return 1});
pylon4 = stations.Pylon.new("Pylon 4",             3, [-0.075, -0.141, -1.339], pylon4set,  3, props.globals.getNode("sim/weight[3]/weight-lb",1),props.globals.getNode("sim/drag[3]/dragarea-sqft",1),func{return 1});
pylon5 = stations.Pylon.new("Pylon 5",         4, [-0.105, -0.130, -2.455], pylon5set,  4, props.globals.getNode("sim/weight[4]/weight-lb",1),props.globals.getNode("sim/drag[4]/dragarea-sqft",1),func{return 1});
pylon6 = stations.Pylon.new("Pylon 6",        5, [-0.106, -0.131, -3.022], pylon6set,  5, props.globals.getNode("sim/weight[5]/weight-lb",1),props.globals.getNode("sim/drag[5]/dragarea-sqft",1),func{return 1});
pylon7 = stations.Pylon.new("Pylon 7",            6, [-0.106, -0.131, -2.454], pylon7set,  6, props.globals.getNode("sim/weight[6]/weight-lb",1),props.globals.getNode("sim/drag[6]/dragarea-sqft",1),func{return 1});
pylon8 = stations.Pylon.new("Pylon 8",            7, [-0.076, -0.142, -1.339], pylon8set,  7, props.globals.getNode("sim/weight[7]/weight-lb",1),props.globals.getNode("sim/drag[7]/dragarea-sqft",1),func{return 1});
pylon9 = stations.Pylon.new("Pylon 9",            8, [0.022, -0.058, 0.604], pylon9set,  8, props.globals.getNode("sim/weight[8]/weight-lb",1),props.globals.getNode("sim/drag[8]/dragarea-sqft",1),func{return 1});
pylon10 = stations.Pylon.new("Pylon 10",            9, [0.108, 0.085, 1.825], pylon10set,  9, props.globals.getNode("sim/weight[9]/weight-lb",1),props.globals.getNode("sim/drag[9]/dragarea-sqft",1),func{return 1});
pylon11 = stations.Pylon.new("Pylon 11",            10, [0.103, 0.310, 2.875], pylon11set,  10, props.globals.getNode("sim/weight[10]/weight-lb",1),props.globals.getNode("sim/drag[10]/dragarea-sqft",1),func{return 1});



var pylons = [pylon1,pylon2,pylon3,pylon4,pylon5,pylon6,pylon7,pylon8,pylon9,pylon10,pylon11,pylonI];

# The order of first vector in this line is the default pylon order weapons is released in.
# The order of second vector in this line is the order cycle key would cycle through the weapons:
fcs = fc.FireControl.new(pylons, [11,7,3,10,0,9,1,8,2], ["30mm Cannon", "AIM-9", "MK-82", "LAU-68"]);

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
        gui.popupTip ("GAU-8 reloaded -- 1174 rounds", 5);    
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
        if (aim != nil and (aim.type == "AIM-9")) {
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
