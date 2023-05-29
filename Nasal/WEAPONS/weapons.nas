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
    if (selectedWeap.type != "AGM-65B" or selectedWeap.type == nil) {
        print ("Weapon is not of type AGM-65B - Skipping sequence");
        seekerTimer.stop();
    }else{
        if (!masterArm) {
            print("Master Arm safe - Skipping");
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
    if ((masterArm) and (selectedWeap.type == "AGM-65B")) {
        if ((armament.MISSILE_LOCK) == (selectedWeap.status)) {
            selectedWeap.setCaged(0);
            print("Valid tgt - Uncaging");
        } else {
            selectedWeap.setCaged(1);
            print("Not uncaging - no valid tgt to lock");
        }
    } else {
        print("Selected Weapon is not an AGM-65 or Master Arm safe. Not locking target");
    }

};


cursorUp = maketimer(rate,yUp);
cursorDown = maketimer(rate,yDown);
cursorLeft = maketimer(rate,xLeft);
cursorRight = maketimer(rate,xRight);

setlistener("A-10/stations/station[2]/selected",mavUpdate);
setlistener("A-10/stations/station[8]/selected",mavUpdate);
setlistener("controls/armament/trigger",mavUpdate);