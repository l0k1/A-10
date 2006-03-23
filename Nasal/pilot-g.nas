# == timer stuff ==

# set the update period

UPDATE_PERIOD = 0.3;

# set the timer for the selected function

registerTimer = func {
	
    settimer(arg[0], UPDATE_PERIOD);

} # end function 



# == Pilot G stuff ==

pilot_g = props.globals.getNode("accelerations/pilot-g", 1);
timeratio = props.globals.getNode("accelerations/timeratio", 1);
pilot_g_damped = props.globals.getNode("accelerations/pilot-g-damped", 1);

pilot_g_damped.setDoubleValue(0); 
timeratio.setDoubleValue(0.03); 

damp = 0;

updatePilotG = func {
        var n = timeratio.getValue(); 
		var g = pilot_g.getValue() ;
		if (g == nil) { g = 0; }
		damp = ( g * n) + (damp * (1 - n));
		
		pilot_g_damped.setDoubleValue(damp);

# print(sprintf("pilot_g_damped in=%0.5f, out=%0.5f", g, damp));
        
        settimer(updatePilotG, 0.1);

} #end updatePilotG()

updatePilotG();




# end 
