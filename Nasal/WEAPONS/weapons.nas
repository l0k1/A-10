# # Advanced weapons handling code
print("****Loading Advanced Weapons Handling Code****");

var selectedWeap = pylons.fcs.getSelectedWeapon();
var defaultX = 0;
var defaultY = -4;
#Seeker Loop for cursor control
var seekerLoop = func {
    var cursorX = getprop("A-10/displays/hud/cursor-slew-x");
    var cursorY = getprop("A-10/displays/hud/cursor-slew-y");
    if (selectedWeap == nil) {
        seekerTimer.stop();
    }else{
        selectedWeap.commandDir(cursorX,cursorY);
    }
};
seekerTimer = maketimer(0.025,seekerLoop);

#Maverick Init:
var mavInit = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    selectedWeap.setContacts(radar_system.getCompleteList());
    selectedWeap.commandDir(defaultX,defaultY);
    selectedWeap.setAutoUncage(0);
    selectedWeap.setCaged(1);
    armament.contact = nil;
    seekerTimer.start();
};

var mavUpdate = func {
    selectedWeap = pylons.fcs.getSelectedWeapon();
    var masterArm = getprop("controls/armament/master-arm");
    if (selectedWeap == nil or selectedWeap.type != "AGM-65B" or selectedWeap.type == nil) {
        #print ("Weapon is not of type AGM-65B - Skipping sequence");
        seekerTimer.stop();
    }else{
        if (!masterArm) {
            #print("Master Arm safe - Skipping");
        }else{
            setprop("A-10/displays/hud/cursor-slew-x",defaultX);
            setprop("A-10/displays/hud/cursor-slew-y",defaultY);
            mavInit();
        }
    }

};

#Maverick seeker control
var rate = 0.015;
var step = 0.1;

var xRight = func {
    var current = math.clamp(getprop("A-10/displays/hud/cursor-slew-x"),-6,6);
    setprop("A-10/displays/hud/cursor-slew-x", current + step);

};

var xLeft = func {
    var current = math.clamp(getprop("A-10/displays/hud/cursor-slew-x"),-6,6);
    setprop("A-10/displays/hud/cursor-slew-x", current - step);

};

var yUp = func {
    var current = math.clamp(getprop("A-10/displays/hud/cursor-slew-y"),-9,1.4);
    setprop("A-10/displays/hud/cursor-slew-y", current + step);

};

var yDown = func {
    var current = math.clamp(getprop("A-10/displays/hud/cursor-slew-y"),-9,1.4);
    setprop("A-10/displays/hud/cursor-slew-y", current - step);

};

var lock = func {
    var masterArm = getprop("controls/armament/master-arm");
    if ((selectedWeap != nil) and (masterArm) and (selectedWeap.type == "AGM-65B")) {
        if ((armament.MISSILE_LOCK) == (selectedWeap.status)) {
            selectedWeap.setCaged(0);
            #print("Valid tgt - Uncaging");
        } else {
            selectedWeap.setCaged(1);
            #print("Not uncaging - no valid tgt to lock");
        }
    } else {
        #print("Selected Weapon is not an AGM-65 or Master Arm safe. Not locking target");
    }

};


cursorUp = maketimer(rate,yUp);
cursorDown = maketimer(rate,yDown);
cursorLeft = maketimer(rate,xLeft);
cursorRight = maketimer(rate,xRight);

setlistener("A-10/stations/station[2]/selected",mavUpdate);
setlistener("A-10/stations/station[8]/selected",mavUpdate);
setlistener("controls/armament/trigger",mavUpdate);

#A/A Master Mode

# AIM-9 Cooling

var setCooling = func (c){
    if (pylons.fcs != nil) {
        foreach(var w;pylons.fcs.getAllOfType("AIM-9M")) {
            if (w.isCooling() != c) {
                w.setCooling(c);
            }
        }
    }
    setprop("A-10/stores/aim9-light", c);
};

var setAim9Power = func (p){
    if (pylons.fcs != nil) {
        foreach(var w;pylons.fcs.getAllOfType("AIM-9M")) {
            if (w.isPowerOn() != p) {
                w.setPowerOn(p);
            }
        }
    }
};

var stnHasAim9 = func (stn) {
    foreach(var w;pylons.pylons[stn].getWeapons()) {
        if (w != nil and w.type == "AIM-9M") {
            return 1;
        }
    }
    return 0;
};

var selectAim9Pylons = func {
    var aim9Loaded = 0;
    if (pylons.fcs != nil) {
        foreach (var stnIndex; [0,10]) { # Station 1 and 11 are the only possible stations for AIM-9
            if (stnHasAim9(stnIndex)){
                setprop("A-10/stations/station[" ~ stnIndex ~ "]/selected",1);
                aim9Loaded = 1;
            }
        }
        if (aim9Loaded) {pylons.fcs.selectWeapon("AIM-9M");};
    }
};

var aim9Knob = func {
    var k = getprop("controls/armament/aim9-knob");
    var coolingActive = (k > 0);
    var sel = (k == 2);

    setCooling(coolingActive);
    setAim9Power(sel);

    if (sel) {
        selectAim9Pylons();
    }

    setprop("/A-10/hud/air-to-air-mode",sel);
};

setlistener("controls/armament/aim9-knob",aim9Knob);
aim9Knob(); #init knob on reload
