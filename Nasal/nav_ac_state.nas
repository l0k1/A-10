# save and restore aircraft settings
# ----------------------------------
#
# inspired from Melchior FRANZ's  ac_state.nas  -- Public Domain
#
# nav_ac_state.nas save the Fairchild A-10 nav[0] preseted frequencies
# in a separate file: A-10-nav.xml

# - Calls to this function are disabled until we have the time or other needs
# to have save() writing on getprop( "/sim/fg-home/") or somewhere else in a secure maner.


var file = getprop("sim/aircraft") ~ "-nav.xml";


loadxml = func(name, node) { fgcommand("loadxml", props.Node.new({"filename": name, "targetnode": node})); }
savexml = func(name, node) { fgcommand("savexml", props.Node.new({"filename": name, "sourcenode": node})); }
# this is the root of a little property tree:   props.Node.new({"filename": name, "sourcenode": node})); }
# that contains two children "filename", and "sourcenode"  with respective values

freq_state_load = func() {
	loadxml(file, "instrumentation/nav/presets");
    print("restoring nav presets from ", file);
}


freq_state_save = func() {
	savexml(file, "instrumentation/nav/presets");
    print("saving nav presets in ", file);
}
