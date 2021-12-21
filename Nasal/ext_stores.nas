

#On verifie et on largue
var dropTanks = func(){
        for(var i = 2 ;i < 5 ; i = i + 1 ){
           var select = getprop("sim/weight["~ i ~"]/selected");
           if(select == "droptank"){ load.dropLoad(i);}

        }
}

var clean = func() {
        



        setprop("sim/weight[0]/selected", "none");
        setprop("sim/weight[1]/selected", "none");
        setprop("sim/weight[2]/selected", "none");
        setprop("sim/weight[3]/selected", "none");
        setprop("sim/weight[4]/selected", "none");
		setprop("sim/weight[5]/selected", "none");
		setprop("sim/weight[6]/selected", "none");
		


}

var Ferry = func() {
        setprop("consumables/fuel/tank[5]/selected", 0);
        setprop("consumables/fuel/tank[5]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[5]/level-gal_us", 0);
		setprop("consumables/fuel/tank[6]/selected", 0);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[6]/level-gal_us", 0);
        setprop("consumables/fuel/tank[7]/selected", 0);
        setprop("consumables/fuel/tank[7]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[7]/level-gal_us", 0);



        setprop("sim/weight[0]/selected", "none");
        setprop("sim/weight[1]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[2]/selected", "1500 l Droptank");
        setprop("sim/weight[3]/selected", "1000 l Droptank");
        setprop("sim/weight[4]/selected", "1500 l Droptank");
		setprop("sim/weight[5]/selected", "ALQ-101 ECM pod");
		setprop("sim/weight[6]/selected", "none");
		setprop("consumables/fuel/tank[5]/selected", 1);
        setprop("consumables/fuel/tank[5]/capacity-gal_us", 396);
        setprop("consumables/fuel/tank[5]/level-gal_us", 396);
		setprop("consumables/fuel/tank[6]/selected", 1);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 211);
        setprop("consumables/fuel/tank[6]/level-gal_us", 211);
		setprop("consumables/fuel/tank[7]/selected", 1);
        setprop("consumables/fuel/tank[7]/capacity-gal_us", 396);
        setprop("consumables/fuel/tank[7]/level-gal_us", 396);


}


var casbomb = func() {
        
        setprop("sim/weight[0]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[1]/selected", "MK-82");
        setprop("sim/weight[2]/selected", "2x-MK-82");
        setprop("sim/weight[3]/selected", "2x-MK-82");
        setprop("sim/weight[4]/selected", "2x-MK-82");
		setprop("sim/weight[5]/selected", "MK-82");
		setprop("sim/weight[6]/selected", "ALQ-101 ECM pod");
		


}

var casbomblong = func() {
        
		setprop("consumables/fuel/tank[6]/selected", 0);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[6]/level-gal_us", 0);
        



        setprop("sim/weight[0]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[1]/selected", "MK-82");
        setprop("sim/weight[2]/selected", "2x-MK-82");
        setprop("sim/weight[3]/selected", "1000 l Droptank");
       setprop("sim/weight[4]/selected", "2x-MK-82");
		setprop("sim/weight[5]/selected", "MK-82");
		setprop("sim/weight[6]/selected", "ALQ-101 ECM pod");
		
		
		setprop("consumables/fuel/tank[6]/selected", 1);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 211);
        setprop("consumables/fuel/tank[6]/level-gal_us", 211);
		
}

var caslgb = func() {
        
		setprop("consumables/fuel/tank[6]/selected", 0);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[6]/level-gal_us", 0);
        



        setprop("sim/weight[0]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[1]/selected", "GBU-16");
        setprop("sim/weight[2]/selected", "GBU-16");
        setprop("sim/weight[3]/selected", "1000 l Droptank");
        setprop("sim/weight[4]/selected", "GBU-16");
		setprop("sim/weight[5]/selected", "GBU-16");
		setprop("sim/weight[6]/selected", "ALQ-101 ECM pod");
		
		
		setprop("consumables/fuel/tank[6]/selected", 1);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 211);
        setprop("consumables/fuel/tank[6]/level-gal_us", 211);
		
}


var casmulti = func() {
        
		setprop("consumables/fuel/tank[6]/selected", 0);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[6]/level-gal_us", 0);
        



        setprop("sim/weight[0]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[1]/selected", "GBU-16");
        setprop("sim/weight[2]/selected", "2x-MK-82");
        setprop("sim/weight[3]/selected", "1000 l Droptank");
        setprop("sim/weight[4]/selected", "2x-MK-82");
		setprop("sim/weight[5]/selected", "GBU-16");
		setprop("sim/weight[6]/selected", "ALQ-101 ECM pod");
		
		
		setprop("consumables/fuel/tank[6]/selected", 1);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 211);
        setprop("consumables/fuel/tank[6]/level-gal_us", 211);
		
}


var radiation = func() {
        
        setprop("sim/weight[0]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[1]/selected", "ALARM");
        setprop("sim/weight[2]/selected", "ALARM");
        setprop("sim/weight[3]/selected", "ALARM");
        setprop("sim/weight[4]/selected", "ALARM");
		setprop("sim/weight[5]/selected", "ALARM");
		setprop("sim/weight[6]/selected", "ALQ-101 ECM pod");
		
		
		
}

var radiationlong = func() {
        setprop("consumables/fuel/tank[5]/selected", 0);
        setprop("consumables/fuel/tank[5]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[5]/level-gal_us", 0);
		
        setprop("consumables/fuel/tank[7]/selected", 0);
        setprop("consumables/fuel/tank[7]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[7]/level-gal_us", 0);



        setprop("sim/weight[0]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[1]/selected", "ALARM");
        setprop("sim/weight[2]/selected", "1000 l Droptank");
        setprop("sim/weight[3]/selected", "ALARM");
        setprop("sim/weight[4]/selected", "1000 l Droptank");
		setprop("sim/weight[5]/selected", "ALARM");
		setprop("sim/weight[6]/selected", "ALQ-101 ECM pod");
		setprop("consumables/fuel/tank[5]/selected", 1);
        setprop("consumables/fuel/tank[5]/capacity-gal_us", 211);
        setprop("consumables/fuel/tank[5]/level-gal_us", 211);
		
		setprop("consumables/fuel/tank[7]/selected", 1);
        setprop("consumables/fuel/tank[7]/capacity-gal_us", 211);
        setprop("consumables/fuel/tank[7]/level-gal_us", 211);


}

var antiship = func() {
        



        setprop("sim/weight[0]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[1]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[2]/selected", "SeaEagle");
        setprop("sim/weight[3]/selected", "SeaEagle");
        setprop("sim/weight[4]/selected", "SeaEagle");
		setprop("sim/weight[5]/selected", "ALQ-101 ECM pod");
		setprop("sim/weight[6]/selected", "AIM-9 Sidewinder");
		


}

var antishiplong = func() {
        
		setprop("consumables/fuel/tank[6]/selected", 0);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 0);
        setprop("consumables/fuel/tank[6]/level-gal_us", 0);
        



        setprop("sim/weight[0]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[1]/selected", "AIM-9 Sidewinder");
        setprop("sim/weight[2]/selected", "SeaEagle");
        setprop("sim/weight[3]/selected", "1000 l Droptank");
        setprop("sim/weight[4]/selected", "SeaEagle");
		setprop("sim/weight[5]/selected", "AIM-9 Sidewinder");
		setprop("sim/weight[6]/selected", "ALQ-101 ECM pod");
		
		
		setprop("consumables/fuel/tank[6]/selected", 1);
        setprop("consumables/fuel/tank[6]/capacity-gal_us", 211);
        setprop("consumables/fuel/tank[6]/level-gal_us", 211);
		
}

#La boite de dialogue
#var ext_loads_dlg = gui.Dialog.new("dialog","Aircraft/F-15-ACTIVE/Dialogs/external-loads.xml");

#Begining of the dropable function.
#It has to be simplified and generic made
#Need to know how to make a table
dropLoad = func (number) {
          var select = getprop("sim/weight["~ number ~"]/selected");
          if(select != "none"){
                if(select == "Droptank"){
                     tank_submodel(number,select);
                     setprop("consumables/fuel/tank["~ number ~"]/selected", 0);
                     settimer(func load.dropLoad_stop(number),2);
                     setprop("controls/armament/station["~ number ~"]/release", 1);
                     setprop("sim/weight["~ number ~"]/selected", "none");
                     setprop("sim/weight["~ number ~"]/weight-lb", 0);
                }else{
                     load.dropMissile(number);
                     settimer(func load.dropLoad_stop(number),0.5);
                }


           }

           
}


#Need to be changed
dropLoad_stop = func(n) {     
         setprop("controls/armament/station["~ n ~"]/release", 0);
}





dropMissile = func (number) { 

  var target  = hud.closest_target();
  if(target == nil){ return;}

  
        #print(typeMissile);


          var typeMissile = getprop("sim/weight["~ number ~"]/selected");
          missile.Loading_missile(typeMissile);
          Current_missile = missile.MISSILE.new(number);
          Current_missile.status = 0;
          Current_missile.search(target);             
          Current_missile.release();
          setprop("controls/armament/station["~ number ~"]/release", 1);
          setprop("sim/weight["~ number ~"]/selected", "none");
          setprop("sim/weight["~ number ~"]/weight-lb", 0);
     

}

#var tank_submodel = func (pylone, select){

        #Drop Tanks
        #if(pylone == 1 and select == "Droptank"){ setprop("controls/armament/station[1]/release-droptank", 1);}
        #if(pylone == 4 and select == "Droptank"){ setprop("controls/armament/station[5]/release-droptank", 1);}
        #if(pylone == 7 and select == "Droptank"){ setprop("controls/armament/station[9]/release-droptank", 1);}


#}




