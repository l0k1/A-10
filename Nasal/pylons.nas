var fcs = nil;
var pylonI = nil;
var pylon1 = nil;
var pylon2 = nil;
var pylon3 = nil;
var pylon4 = nil;
var pylon5 = nil;
var pylon6 = nil;
var pylon7 = nil;

var msgA = "If you need to repair now, then use Menu-Location-SelectAirport instead.";
var msgB = "Please land before changing payload.";
var msgC = "Please land before refueling.";

var cannon = stations.SubModelWeapon.new("30mm Cannon", 0.254, 150, [0,1], [], props.globals.getNode("controls/armament/trigger-gun",1), 0, nil,0);
cannon.typeShort = "GUN";
cannon.brevity = "Guns guns";

var fuelTankLeft1200 = stations.FuelTank.new("Left 1200 L Tank", "TK1200", 6, 317, "jaguar/wingtankL1200");
var fuelTankCenter1200 = stations.FuelTank.new("Center 1200 L Tank", "TK1200", 7, 317, "jaguar/ventraltank1200");
var fuelTankRight1200 = stations.FuelTank.new("Right 1200 L Tank", "TK1200", 8, 317, "jaguar/wingtankR1200");

fuelTankLeft1200.del();
fuelTankCenter1200.del();
fuelTankRight1200.del();

# 
# Matra R550 Majic: 14.5kg fuel, M2.5 above, 2 sec burn, 12kg warhead, 35G, rear aspect, 1.6 s arm, 500m minimum, 5km for non afterburner target, 25 sec selfd., 89kg mass, 164mm diam
# Bl799:



var pylonSets = {
	empty: {name: "Empty", content: [], fireOrder: [], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 1},
	mm20:  {name: "30mm Cannon", content: [cannon], fireOrder: [0], launcherDragArea: 0.0, launcherMass: 0, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},

    m83:  {name: "1 x MK-83", content: ["MK-83"], fireOrder: [0], launcherDragArea: 0.005, launcherMass: 300, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    m83d:  {name: "2 x MK-83", content: ["MK-83","MK-83"], fireOrder: [0,1], launcherDragArea: 0.005, launcherMass: 300, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    m83h:  {name: "1 x MK-83HD", content: ["MK-83HD"], fireOrder: [0], launcherDragArea: 0.005, launcherMass: 300, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    m83hd:  {name: "2 x MK-83HD", content: ["MK-83HD","MK-83HD"], fireOrder: [0,1], launcherDragArea: 0.005, launcherMass: 300, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    c87:  {name: "1 x CBU-87", content: ["CBU-87"], fireOrder: [0], launcherDragArea: 0.005, launcherMass: 300, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    c87d:  {name: "2 x CBU-87", content: ["CBU-87","CBU-87"], fireOrder: [0,1], launcherDragArea: 0.005, launcherMass: 300, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    bl:  {name: "1 x BL755", content: ["BL755"], fireOrder: [0], launcherDragArea: 0.005, launcherMass: 300, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    bld:  {name: "2 x BL755", content: ["BL755","BL755"], fireOrder: [0,1], launcherDragArea: 0.005, launcherMass: 300, launcherJettisonable: 0, showLongTypeInsteadOfCount: 0, category: 2},
    
    # 340 = outer pylon
#	smokeWL: {name: "Smokewinder White", content: [smokewinderWhite1], fireOrder: [0], launcherDragArea: -0.05, launcherMass: 53+340, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
#	smokeWR: {name: "Smokewinder White", content: [smokewinderWhite10], fireOrder: [0], launcherDragArea: -0.05, launcherMass: 53+340, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},

# name must match content name as otherwise won't be able to use on dialog.
	fuel12L: {name: fuelTankLeft1200.type, content: [fuelTankLeft1200], fireOrder: [0], launcherDragArea: 0.35, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
	fuel12R: {name: fuelTankRight1200.type, content: [fuelTankRight1200], fireOrder: [0], launcherDragArea: 0.35, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},
    fuel12C: {name: fuelTankCenter1200.type, content: [fuelTankCenter1200], fireOrder: [0], launcherDragArea: 0.35, launcherMass: 531, launcherJettisonable: 1, showLongTypeInsteadOfCount: 1, category: 2},

    # A/A weapons on non-wing pylons:
	aim9:    {name: "AIM-9",   content: ["AIM-9"], fireOrder: [0], launcherDragArea: -0.025, launcherMass: 53, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
    majic:    {name: "Majic",   content: ["Majic"], fireOrder: [0], launcherDragArea: -0.025, launcherMass: 53, launcherJettisonable: 0, showLongTypeInsteadOfCount: 1, category: 1},
};

# sets. The first in the list is the default. Earlier in the list means higher up in dropdown menu.
# These are not strictly needed in F-14 beside from the Empty, since it uses a custom payload dialog, but there for good measure.
var pylon1set = [pylonSets.empty, pylonSets.majic, pylonSets.aim9];
var pylon2set = [pylonSets.empty, pylonSets.majic, pylonSets.aim9, pylonSets.m83, pylonSets.m83h, pylonSets.c87, pylonSets.bl];
var pylon3set = [pylonSets.empty, pylonSets.m83, pylonSets.m83h, pylonSets.m83d, pylonSets.m83hd, pylonSets.c87, pylonSets.c87d, pylonSets.bl, pylonSets.bld, pylonSets.fuel12L];
var pylon4set = [pylonSets.empty, pylonSets.m83, pylonSets.m83h, pylonSets.c87, pylonSets.bl, pylonSets.fuel12C];
var pylon5set = [pylonSets.empty, pylonSets.m83, pylonSets.m83h, pylonSets.m83d, pylonSets.m83hd, pylonSets.c87, pylonSets.c87d, pylonSets.bl, pylonSets.bld, pylonSets.fuel12R];
var pylon6set = [pylonSets.empty, pylonSets.majic, pylonSets.aim9, pylonSets.m83, pylonSets.m83h, pylonSets.c87, pylonSets.bl];
var pylon7set = [pylonSets.empty, pylonSets.majic, pylonSets.aim9];

# pylons
pylonI = stations.InternalStation.new("Internal gun mount", 7, [pylonSets.mm20], props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[7]",1));
pylon1 = stations.Pylon.new("Left Over Wing",             0, [8.851, -2.080,  0.120], pylon1set,  0, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[0]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[0]",1),func{return 1});
pylon2 = stations.Pylon.new("Left Outboard Wing",         1, [9.051, -2.980, -0.230], pylon2set,  1, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[1]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[1]",1),func{return 1});
pylon3 = stations.Pylon.new("Left Inboard Wing",          2, [8.751, -2.080, -0.230], pylon3set,  2, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[2]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[2]",1),func{return 1});
pylon4 = stations.Pylon.new("Fuselage Pylon",             3, [8.611,  0.000, -0.875], pylon4set,  3, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[3]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[3]",1),func{return 1});
pylon5 = stations.Pylon.new("Right Inboard Wing",         4, [8.751,  2.080, -0.230], pylon5set,  4, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[4]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[4]",1),func{return 1});
pylon6 = stations.Pylon.new("Right Outboard Wing",        5, [9.051,  2.980, -0.230], pylon6set,  5, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[5]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[4]",1),func{return 1});
pylon7 = stations.Pylon.new("Right Over Wing",            6, [8.851,  2.080,  0.120], pylon7set,  6, props.globals.getNode("fdm/jsbsim/inertia/pointmass-weight-lbs[6]",1),props.globals.getNode("fdm/jsbsim/inertia/pointmass-dragarea-sqft[4]",1),func{return 1});

#pylon1.forceRail = 1;# set the missiles mounted on this pylon on a rail.
#pylon9.forceRail = 1;

var pylons = [pylon1,pylon2,pylon3,pylon4,pylon5,pylon6,pylon7,pylonI];

# The order of first vector in this line is the default pylon order weapons is released in.
# The order of second vector in this line is the order cycle key would cycle through the weapons (but since the f-14 dont have that the order is not important):
fcs = fc.FireControl.new(pylons, [0,6,1,5,2,4,3,7], ["30mm Cannon", "Majic", "AIM-9", "MK-83", "MK-83HD", "CBU-87", "BL755"]);

#print("** Pylon & fire control system started. **");
var getDLZ = func {
    if (fcs != nil and getprop("controls/armament/master-arm")) {
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

var reloadCannon = func {
    #setprop("ai/submodels/submodel[4]/count", 100);
    #setprop("ai/submodels/submodel[5]/count", 100);#flares
    cannon.reloadAmmo();
}

# reload cannon only
var cannon_load = func {
    if (fcs != nil and (!getprop("payload/armament/msg") or getprop("fdm/jsbsim/gear/unit[0]/WOW"))) {
        reloadCannon();
        return 1;
    } else {
      screen.log.write(msgB);
      return 0;
    }
}


var bore_loop = func {
    #enables firing of aim9 without radar. The aim-9 seeker will be fixed 3.5 degs below bore and any aircraft the gets near that will result in lock.
    bore = 0;
    if (fcs != nil) {
        var standby = 1;#getprop("sim/multiplay/generic/int[2]");
        var aim = fcs.getSelectedWeapon();
        if (aim != nil and (aim.type == "AIM-9" or aim.type == "MAGIC-2" or aim.type == "Majic")) {
            if (standby == 1) {
                #aim.setBore(1);
                aim.setContacts(radar.completeList);
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

# swamp TODO list:
#
# add JSB pointmasses for those coords
# add more weapons and smokewinders. Plus get correct loadout options for each pylon
# 