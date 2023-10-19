print("*** LOADING HUD.nas ... ***");
################################################################################
#
#                     Mirage/Jaguar HUD Adapted for A-10
#
################################################################################

var roundabout = func(x) {
  var y = x - int(x);
  return y < 0.5 ? int(x) : 1 + int(x) ;
};


var x_view = props.globals.getNode("sim/current-view/x-offset-m");
var y_view = props.globals.getNode("sim/current-view/y-offset-m");
var z_view = props.globals.getNode("sim/current-view/z-offset-m");

var Hud_Position = [-0.0005,0.0298,-3.16320];
var PilotCurrentView = [x_view.getValue(),y_view.getValue(),z_view.getValue()];

var pow2 = func(x) { return x * x; };
var vec_length = func(x, y,z=0) { return math.sqrt(pow2(x) + pow2(y)+pow2(z)); };


#Nodes values variables
var mydeviation = 0;
var myelevation = 0;
var displayIt = 0;
var target_callsign = "";
var target_altitude = 0;
var target_closureRate = 0;
var target_heading_deg = 0;
var target_Distance = 0;
var raw_list = [];
var MIL2HUD = R2D/10; #experimental
var hudMenuSpacing = 30;


var pow2 = func(x) { return x * x; };
var vec_length = func(x, y) { return math.sqrt(pow2(x) + pow2(y)); };
var round0 = func(x) { return math.abs(x) > 0.01 ? x : 0; };
var clamp = func(x, min, max) { return x < min ? min : (x > max ? max : x); }

#canvas.
#the canvas is wider than the actual hud : so display start at 16,7% of the hud and end at 84,3% (100%-16.7%)
#vertical is 100%
#the HUD is slanted. Angle : 40%
#Canvs start upper right
#x is positive rightwards. y is positive downwards
#480,480 --> (140,-150) - (150,200)
#Canvas coordinates :
#X: 80 to 400
#Y: 27.36 to 456.89


#OFFSET1 panel.xml :<offsets><x-m> 0.456 </x-m> <y-m> 0.000 </y-m><z-m> 0.159 </z-m></offsets>
#OFFSET2  interior.xml <offsets><x-m> -3.653 </x-m> <y-m>  0.000 </y-m>  <z-m> -0.297 </z-m>      <pitch-deg> -14 </pitch-deg>    </offsets>

#TO do = update distance to HUD in fonction of the position on it : if vertical on 2D HUD is high, distance should be lower.
#find a trigonometric way to calculate the y position (2D HUD) as the real hud have around 45° of inclinaison.
#Make it happen for all non null radar properies
#Make null properties hidded


centerHUDx = -3.20962;
centerHUDy = 0;
centerHUDz = (-0.15438 + -0.02038)/2;
var heightMeters = 0.067-(-0.067);
var wideMeters = math.abs(-0.02038 - (-0.15438));


#           888b     d888        d8888 8888888 888b    888 
#           8888b   d8888       d88888   888   8888b   888 
#           88888b.d88888      d88P888   888   88888b  888 
#           888Y88888P888     d88P 888   888   888Y88b 888 
#           888 Y888P 888    d88P  888   888   888 Y88b888 
#           888  Y8P  888   d88P   888   888   888  Y88888 
#           888   "   888  d8888888888   888   888   Y8888 
#           888       888 d88P     888 8888888 888    Y888

var HUD = {
  canvas_settings: {
    "name": "HUD",
    "size": [1024,1024],#<-- size of the texture
    "view": [1024,1024], #<- Size of the coordinate systems (the bigger the sharpener)
    "mipmapping": 0
  },
  new: func(placement)
  {
    var m = {
      parents: [HUD],
      canvas: canvas.new(HUD.canvas_settings)
    };
     
    # HUD .ac coords:    upper-left                 lower-right        
    HudMath.init([2.2458,-0.11882,1.5334], [2.1364,0.11872,1.2218], [1024,1024], [0,1.0], [1,0.0], 0);
        
    m.sy = 1024/2;                        
    m.sx = 1024/2;
    
    m.viewPlacement = 480;
    m.min = -m.viewPlacement * 0.846;
    m.max = m.viewPlacement * 0.846;

    m.MaxX = 512; #the canvas is 420 *2;
    m.MaxY = 512; #the canvas is 420 *2;
    
    m.red = 0.0;
    m.green = 1.0;
    m.blue = 0.0;
    
    m.MaxTarget = 30;
    
    m.myGreen = [m.red,m.green,m.blue,1];
    m.myLineWidth = 1.4;
    m.myFontSize = 1;
    
#     .setColor(m.myGreen)
    
    m.canvas.addPlacement(placement);
    #m.canvas.setColorBackground(red, green, blue, 0.0);
    #m.canvas.setColorBackground(0.36, 1, 0.3, 0.02);
    m.canvas.setColorBackground(m.red, m.green, m.blue, 0.00);
    
    #.set("stroke", "rgba(0,255,0,0.9)");
    #.setColor(0.3,1,0.3)
    
    m.root =
        m.canvas.createGroup()
                .setTranslation(HudMath.getCenterOrigin())
                .set("font", "A10-HUD.ttf")
                .setDouble("character-size",m.myFontSize* 16)
                .setDouble("character-aspect-ration", 0.9);

    m.text =
      m.root.createChild("group");
      
      m.rootLine =
      m.root.createChild("group");
            
            
    m.Fire_GBU =
      m.text.createChild("text")
            .setAlignment("center-center")
            .setTranslation(0, 70)
            .setColor(m.myGreen)
            .setDouble("character-size",m.myFontSize* 42);
            
            
    #fpv
    m.fpv = m.root.createChild("path")
        .setColor(m.myGreen)
        .moveTo(15, 0)
        .horiz(40)
        .moveTo(15, 0)
        .arcSmallCW(15,15, 0, -30, 0)
        .arcSmallCW(15,15, 0, 30, 0)
        .moveTo(-15, 0)
        .horiz(-40)
        .moveTo(0, -15)
        .vert(-15)
        .setStrokeLineWidth(m.myLineWidth*4);
  m.fpvL = m.root.createChild("text")
            .setAlignment("left-bottom")
            .setTranslation(0, 0)
            .setColor(m.myGreen)
            .setText("L")
            .setDouble("character-size",m.myFontSize* 42);
        
  m.AutopilotStar = m.root.createChild("text")
    .setColor(m.myGreen)
    .setTranslation(150,0)
    .setDouble("character-size",m.myFontSize* 50)
    .setAlignment("center-center")
    .setText("*"); 
        
        
         
  #tadpole - destination index
  m.HouseSize = 4;
  m.HeadingHouse = m.root.createChild("path")
    .setColor(m.myGreen)
    .setStrokeLineWidth(m.myLineWidth*5)
    #.moveTo(-20,0)
    #.vert(-30)
    #.lineTo(0,-50)
    #.lineTo(20,-30)
    #.vert(30);
    .moveTo(-12.5,0)
    .arcSmallCW(12.5,12.5, 0, 12.5*2, 0)
    .arcSmallCW(12.5,12.5, 0, -12.5*2, 0)
    .moveTo(0,-12.5)
    .vert(-35);
 
        
   #Chevrons Acceleration Vector (AV)
   m.chevronFactor = 40;
   m.chevronGroup = m.root.createChild("group");
   
  m.LeftChevron = m.chevronGroup.createChild("text")
  .setColor(m.myGreen)
  .setTranslation(-150,0)
  .setDouble("character-size",m.myFontSize* 60)
  .setAlignment("center-center")
  .setText(">");    
  
  m.RightChevron = m.chevronGroup.createChild("text")
    .setColor(m.myGreen)
    .setTranslation(150,0)
    .setDouble("character-size",m.myFontSize* 60)
    .setAlignment("center-center")
    .setText("<");   
   
        
    #bore cross
    m.boreCross = m.root.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-20, 0)
      .horiz(40)
      .moveTo(0, -20)
      .vert(40)
      .setStrokeLineWidth(m.myLineWidth*4);
                   
                   
    #WP cross
    m.WaypointCross = m.root.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-20, 0)
      .horiz(12)
      .moveTo(8, 0)
      .horiz(12)
      .moveTo(0, -20)
      .vert(12)
      .moveTo(0, 8)
      .vert(12)
      .setStrokeLineWidth(m.myLineWidth*4);
                   

                   

    # Horizon groups
    m.horizon_group = m.root.createChild("group");
    m.h_rot   = m.horizon_group.createTransform();
    m.horizon_sub_group = m.horizon_group.createChild("group");
  
    # Horizon and pitch lines
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-1000, 0)
      .horiz(2000)
      .setStrokeLineWidth(m.myLineWidth*4);
                   
                  
    m.ladderScale = 7.5;#7.5
    m.maxladderspan =  200;
    m.minladderspan = -200;
                   
   for (var myladder = 5;myladder <= 90;myladder+=5)
   {
     if (myladder/10 == int(myladder/10)){
        #Text bellow 0 left
        m.horizon_sub_group.createChild("text")
          .setColor(m.myGreen)
          .setAlignment("right-center")
          .setTranslation(-m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
          .setDouble("character-size",m.myFontSize* 30)
          .setText(myladder);
        #Text bellow 0 left
        m.horizon_sub_group.createChild("text")
          .setColor(m.myGreen)
          .setAlignment("left-center")
          .setTranslation(m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
          .setDouble("character-size",m.myFontSize* 30)
          .setText(myladder);

        #Text above 0 left         
        m.horizon_sub_group.createChild("text")
          .setColor(m.myGreen)
          .setAlignment("right-center")
          .setTranslation(-m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*-myladder)
          .setDouble("character-size",m.myFontSize* 30)
          .setText(myladder); 
        #Text above 0 right   
        m.horizon_sub_group.createChild("text")
          .setColor(m.myGreen)
          .setAlignment("left-center")
          .setTranslation(m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*-myladder)
          .setDouble("character-size",m.myFontSize* 30)
          .setText(myladder);
      }
      
  # =============  BELLOW 0 ===================           
    #half line bellow 0 (left part)       ------------------ 
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
      .vert(-m.maxladderspan/15)
      .setStrokeLineWidth(m.myLineWidth*4); 
                   
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
      .horiz(m.maxladderspan*2/15)
      .setStrokeLineWidth(m.myLineWidth*4);             
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-abs(m.maxladderspan - m.maxladderspan*2/15*2), HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
      .horiz(m.maxladderspan*2/15)
      .setStrokeLineWidth(m.myLineWidth*4);    
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-abs(m.maxladderspan - m.maxladderspan*2/15*4), HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
      .horiz(m.maxladderspan*2/15)
      .setStrokeLineWidth(m.myLineWidth*4);
                  
    #half line (rigt part)       ------------------   
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
      .vert(-m.maxladderspan/15)
      .setStrokeLineWidth(m.myLineWidth*4); 
                   
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
      .horiz(-m.maxladderspan*2/15)
      .setStrokeLineWidth(m.myLineWidth*4);             
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(abs(m.maxladderspan - m.maxladderspan*2/15*2), HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
      .horiz(-m.maxladderspan*2/15)
      .setStrokeLineWidth(m.myLineWidth*4);    
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(abs(m.maxladderspan - m.maxladderspan*2/15*4), HudMath.getPixelPerDegreeAvg(m.ladderScale)*myladder)
      .horiz(-m.maxladderspan*2/15)
      .setStrokeLineWidth(m.myLineWidth*4);              
                  
                  
  
                   
# =============  ABOVE 0 ===================               
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*-myladder)
      .vert(m.maxladderspan/15)
      .setStrokeLineWidth(m.myLineWidth*4); 
                   
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*-myladder)
      .horiz(m.maxladderspan/3*2)
      .setStrokeLineWidth(m.myLineWidth*4);             
          
    #half line (rigt part)       ------------------           
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*-myladder)
      .horiz(-m.maxladderspan/3*2)
      .setStrokeLineWidth(m.myLineWidth*4);            
    m.horizon_sub_group.createChild("path")
      .setColor(m.myGreen)
      .moveTo(m.maxladderspan, HudMath.getPixelPerDegreeAvg(m.ladderScale)*-myladder)
      .vert(m.maxladderspan/15)
      .setStrokeLineWidth(m.myLineWidth*4); 
                   

   }           
                   
       
    #This is the inverted T that is present in at -13 and putting this line on the horizon will keep the aircraft at 13 which is the perfect angle to take off and to land
    m.InvertedT = m.root.createChild("path")
      .setColor(m.myGreen)
      .moveTo(-m.maxladderspan/2, 0)
      .horiz(m.maxladderspan)
      .moveTo(0, 0)
      .vert(-m.maxladderspan/15*2)
      .setStrokeLineWidth(m.myLineWidth*6);
  
              
    m.headScaleTickSpacing = 45;           
    m.headScaleVerticalPlace = -475;
    m.headingStuff = m.root.createChild("group");
    m.headingScaleGroup = m.headingStuff.createChild("group");

    
     m.headingStuff.set("clip-frame", canvas.Element.LOCAL);
     m.headingStuff.set("clip", "rect(-600px, 150px, -400px, -150px)");# top,right,bottom,left
    
    
    m.head_scale = m.headingScaleGroup.createChild("path")
    .setColor(m.myGreen)
    .moveTo(-m.headScaleTickSpacing*2, m.headScaleVerticalPlace)
    .vert(-15)
    .moveTo(0, m.headScaleVerticalPlace)
    .vert(-15)
    .moveTo(m.headScaleTickSpacing*2, m.headScaleVerticalPlace)
    .vert(-15)
    .moveTo(m.headScaleTickSpacing*4, m.headScaleVerticalPlace)
    .vert(-15)
    .moveTo(-m.headScaleTickSpacing, m.headScaleVerticalPlace)
    .vert(-5)
    .moveTo(m.headScaleTickSpacing, m.headScaleVerticalPlace)
    .vert(-5)
    .moveTo(-m.headScaleTickSpacing*3, m.headScaleVerticalPlace)
    .vert(-5)
    .moveTo(m.headScaleTickSpacing*3, m.headScaleVerticalPlace)
    .vert(-5)
    .setStrokeLineWidth(m.myLineWidth*5)
    .show();
    
    #Heading middle number on horizon line
    me.hdgMH = m.headingScaleGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,m.headScaleVerticalPlace -15)
      .setDouble("character-size",m.myFontSize* 50)
      .setAlignment("center-bottom")
      .setText("0"); 
                   
#     # Heading left number on horizon line
      me.hdgLH = m.headingScaleGroup.createChild("text")
        .setColor(m.myGreen)
        .setTranslation(-m.headScaleTickSpacing*2,m.headScaleVerticalPlace -15)
        .setDouble("character-size",m.myFontSize* 50)
        .setAlignment("center-bottom")
        .setText("350");           

#     # Heading right number on horizon line
      me.hdgRH = m.headingScaleGroup.createChild("text")
        .setColor(m.myGreen)
        .setTranslation(m.headScaleTickSpacing*2,m.headScaleVerticalPlace -15)
        .setDouble("character-size",m.myFontSize* 50)
        .setAlignment("center-bottom")
        .setText("10");    
          
      # Heading right right number on horizon line
      me.hdgRRH = m.headingScaleGroup.createChild("text")
        .setColor(m.myGreen)
        .setTranslation(m.headScaleTickSpacing*4,m.headScaleVerticalPlace -15)
        .setDouble("character-size",m.myFontSize* 50)
        .setAlignment("center-bottom")
        .setText("20");          

    
      
    #Point the The Selected Route. it's at the middle of the HUD
    m.TriangleSize = 4;
    m.head_scale_route_pointer = m.headingStuff.createChild("path")
      .setColor(m.myGreen)
      .setStrokeLineWidth(m.myLineWidth*3)
      .moveTo(0, m.headScaleVerticalPlace)
      .lineTo(m.TriangleSize*-5/2, (m.headScaleVerticalPlace)+(m.TriangleSize*5))
      .lineTo(m.TriangleSize*5/2,(m.headScaleVerticalPlace)+(m.TriangleSize*5))
      .lineTo(0, m.headScaleVerticalPlace);
    
    

    #a line representthe middle and the actual heading
    m.heading_pointer_line = m.headingStuff.createChild("path")
      .setColor(m.myGreen)
      .setStrokeLineWidth(m.myLineWidth*4)
      .moveTo(0, m.headScaleVerticalPlace + 2)
      .vert(20);
    

     m.speedAltGroup = m.root.createChild("group");
     # Heading right right number on horizon line
    me.Speed = m.speedAltGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(- m.maxladderspan-150,m.headScaleVerticalPlace)
      .setDouble("character-size",m.myFontSize* 35)
      .setAlignment("right-bottom")
      .setText("0"); 
          
    me.Speed_Mach = m.speedAltGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(- m.maxladderspan+100,m.headScaleVerticalPlace+25)
      .setDouble("character-size",m.myFontSize* 30)
      .setAlignment("right-bottom")
      .setText("0"); 
          

     # Heading right right number on horizon line
     me.hundred_feet_Alt = m.speedAltGroup.createChild("text")
          .setTranslation(m.maxladderspan+275 ,m.headScaleVerticalPlace)
          .setDouble("character-size",m.myFontSize* 35)
          .setAlignment("right-bottom")
          .setText("0");   
      
          
    m.alphaGroup = m.root.createChild("group");      
  
    #alpha
    m.alpha = m.alphaGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(- m.maxladderspan-70,m.headScaleVerticalPlace+50)
      .setDouble("character-size",m.myFontSize* 40)
      .setAlignment("right-center")
      .setText("α");
          
    #aoa 
    m.aoa = m.alphaGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(- m.maxladderspan-50,m.headScaleVerticalPlace+50)
      .setDouble("character-size",m.myFontSize* 30)
      .setAlignment("left-center")
      .setText("0.0");
    
      
    m.alphaGloadGroup = m.root.createChild("group");  
    m.gload_Text = m.alphaGloadGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(-375,-400)
      .setDouble("character-size",m.myFontSize* 35)
      .setAlignment("left-center")
      .setText("0.0");
      
    m.alpha_Text = m.alphaGloadGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(- m.maxladderspan-50,-90)
      .setDouble("character-size",m.myFontSize* 35)
      .setAlignment("right-center")
      .setText("0.0");  
      
      m.alphaGloadGroup.hide();
      
    m.loads_Type_text = m.root.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(- m.maxladderspan-125,-10)
      .setDouble("character-size",m.myFontSize* 25)
      .setAlignment("right-center")
      .setText("0.0");  
    m.loads_Type_text.hide();
    
    
    # Bullet count when 30mm is selected
    m.bullet_CountGroup = m.root.createChild("group");  
    m.Bullet_Count = m.bullet_CountGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(m.minladderspan-125,25)
      .setDouble("character-size",m.myFontSize* 25)
      .setFont("A10-HUD.ttf")
      .setAlignment("right-center")
      .setText("0.0");  
    m.bullet_CountGroup.hide();
    
      #Betty Altitude to call - GCAS
      m.GCASGroup = m.root.createChild("group");  
        
      m.warnAlt = m.GCASGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0)
      .setDouble("character-size",m.myFontSize* 35)
      .setAlignment("center-center")
      .setText("0000"); 
      
      m.altBoxLine = m.GCASGroup.createChild("path")
        .setColor(m.myGreen)
        .moveTo(-70, -25)
        .horiz(140)
        .vert(50)
        .horiz(-140)
        .vert(-50)
        .setStrokeLineWidth(m.myLineWidth*4);         
      m.GCASGroup.setTranslation(0,m.headScaleVerticalPlace*2/5);

      m.fpa = m.root.createChild("text")
        .setColor(m.myGreen)
        .setTranslation(m.maxladderspan+265 ,m.headScaleVerticalPlace+340)
        .setDouble("character-size",m.myFontSize* 30)
        .setAlignment("right-bottom")
        .setText("FPA");
      
      m.hudRAlt = m.root.createChild("text")
        .setColor(m.myGreen)
        .setTranslation(m.maxladderspan+200 ,25)
        .setDouble("character-size",m.myFontSize* 25)
        .setAlignment("right-bottom")
        .setText("0RALT");
          
      #Waypoint Group
      m.waypointGroup = m.root.createChild("group");

      
      m.waypointSimpleGroup = m.root.createChild("group");

      # #Distance to active Waypoint
      # m.waypointDistAlt = m.waypointSimpleGroup.createChild("text")
      #   .setColor(m.myGreen)
      #   .setTranslation(m.maxladderspan+145 ,85)
      #   .setDouble("character-size",m.myFontSize* 25)
      #   .setAlignment("left-bottom")
      #   .setText("0");    

      #active Waypoint NUMBER
      m.waypointDistAlt = m.waypointSimpleGroup.createChild("text")
        .setColor(m.myGreen)
        .setTranslation( m.maxladderspan +93 ,85)
        .setDouble("character-size",m.myFontSize* 25)
        .setAlignment("left-bottom")
        .setText("00"); 

      m.stptInfo = m.waypointSimpleGroup.createChild("text")
        .setColor(m.myGreen)
        .setTranslation(m.maxladderspan+93 ,55) #+25 for font size + 5 for gap
        .setDouble("character-size",m.myFontSize* 25)
        .setAlignment("left-bottom")
        .setText("stptInfo");

      m.utcTime = m.waypointSimpleGroup.createChild("text")
        .setColor(m.myGreen)
        .setTranslation(m.maxladderspan+93 ,115)
        .setDouble("character-size",m.myFontSize* 25)
        .setAlignment("left-bottom")
        .setText("00:00:00");

      
      
                   
    m.radarStuffGroup = m.root.createChild("group");
    
    
    #SSLC snake gun sight: (not LCOS, SNAP or EEGS)
    #time * vectorSize >= 1.5
    
    m.eegsGroup = m.root.createChild("group");
    #m.averageDt = 0.050;
    m.averageDt = 0.10;
    #m.funnelParts = 10;
    m.funnelParts = 1.5 / m.averageDt;
    m.eegsRightX = [0];
    m.eegsRightY = [0];
    m.eegsLeftX  = [0];
    m.eegsLeftY  = [0]; 
    m.gunPos  = nil;
    m.shellPosXInit = [0];
    m.shellPosYInit =  [0];
    m.shellPosDistInit = [0];
    m.wingspanFT = 35;# 7- to 40 meter
    m.resetGunPos();

    m.eegsRightX = m.makeVector(m.funnelParts,0);
    m.eegsRightY = m.makeVector(m.funnelParts,0);
    m.eegsLeftX  = m.makeVector(m.funnelParts,0);
    m.eegsLeftY  = m.makeVector(m.funnelParts,0);

    m.eegsMe = {ac: geo.Coord.new(), eegsPos: geo.Coord.new(),shellPosX: m.makeVector(m.funnelParts,0),shellPosY: m.makeVector(m.funnelParts,0),shellPosDist: m.makeVector(m.funnelParts,0)};

    m.lastTime = systime();
    m.eegsLoop = maketimer(m.averageDt, m, m.displayEEGS);
    m.eegsLoop.simulatedTime = 1;
    
   ##################################### Target Circle ####################################
    m.targetArray = [];
    m.circle_group2 = m.radarStuffGroup.createChild("group");
    for(var i = 1; i <= m.MaxTarget; i += 1){
      myCircle = m.circle_group2.createChild("path")
        .setColor(m.myGreen)
        .moveTo(25, 0)
        .arcSmallCW(25,25, 0, -50, 0)
        .arcSmallCW(25,25, 0, 50, 0)
        .setStrokeLineWidth(m.myLineWidth*5)
        .hide()
        ;
      append(m.targetArray, myCircle);
    }
    m.targetrot   = m.circle_group2.createTransform();
  
    ####################### Info Text ########################################
    m.TextInfoArray = [];
    m.TextInfoGroup = m.radarStuffGroup.createChild("group");
    
    for(var i = 1; i <= m.MaxTarget; i += 1){
        text_info = m.TextInfoGroup.createChild("text", "infos")
          .setColor(m.myGreen)
          .setTranslation(15, -10)
          .setAlignment("left-center")
          .setFont("A10-HUD.ttf")
          .setFontSize(m.myFontSize*26)
          .setColor(0,180,0,0.9)
          .hide()
          .setText("VOID");
        append(m.TextInfoArray, text_info);
    }
    m.Textrot   = m.TextInfoGroup.createTransform();
    
  
    
    #######################  Triangles ##########################################
    
    var TriangleSize = 30;
    m.TriangleGroupe = m.radarStuffGroup.createChild("group");
    

    # le triangle donne le cap relatif
        m.triangle = m.TriangleGroupe.createChild("path")
          .setColor(m.myGreen)
          .setStrokeLineWidth(m.myLineWidth*3)
          .moveTo(0, TriangleSize*-1)
          .lineTo(TriangleSize*0.866, TriangleSize*0.5)
          .lineTo(TriangleSize*-0.866, TriangleSize*0.5)
          .lineTo(0, TriangleSize*-1);
    TriangleSize = TriangleSize*0.7;
    
        m.triangle2 = m.TriangleGroupe.createChild("path")
          .setColor(m.myGreen)
          .setStrokeLineWidth(m.myLineWidth*3)
          .moveTo(0, TriangleSize*-1)
          .lineTo(TriangleSize*0.866, TriangleSize*0.5)
          .lineTo(TriangleSize*-0.866, TriangleSize*0.5)
          .lineTo(0, TriangleSize*-1.1);
         m.triangleRot =  m.TriangleGroupe.createTransform();
         
    m.TriangleGroupe.hide();
    
    
    m.Square_Group = m.radarStuffGroup.createChild("group");
     
    m.Locked_Square  = m.Square_Group.createChild("path")
      .setColor(m.myGreen)
      .move(-25,-25)
      .vert(50)
      .horiz(50)
      .vert(-50)
      .horiz(-50)
      .setStrokeLineWidth(m.myLineWidth*6);
      
    m.Locked_Square_Dash  = m.Square_Group.createChild("path")
      .setColor(m.myGreen)
      .move(-25,-25)
      .vert(50)
      .horiz(50)
      .vert(-50)
      .horiz(-50)
      .setStrokeDashArray([10,10])
      .setStrokeLineWidth(m.myLineWidth*5);  
    m.Square_Group.hide();    
      
    
    
    m.missileFireRange = m.root.createChild("group");
    m.MaxFireRange = m.missileFireRange.createChild("path")
      .setColor(m.myGreen)
      .moveTo(210,0)
      .horiz(-30)
      .setStrokeLineWidth(m.myLineWidth*6); 
    m.MinFireRange = m.missileFireRange.createChild("path")
      .setColor(m.myGreen)
      .moveTo(210,0)
      .horiz(-30)
      .setStrokeLineWidth(m.myLineWidth*6); 
    m.NEZFireRange = m.missileFireRange.createChild("path")
      .setColor(m.myGreen)
      .moveTo(215,0)
      .horiz(-40)
      .setStrokeLineWidth(m.myLineWidth*4);   
    m.missileFireRange.hide();
      
    m.pullUp = m.root.createChild("path")
      .setColor(m.myGreen)
      .moveTo(200,200)
      .lineTo(-200,-200)
      .moveTo(-200,200)
      .lineTo(200,-200)
      .hide()
      .setStrokeLineWidth(m.myLineWidth*4);
    
    m.distanceToTargetLineGroup = m.root.createChild("group");
    m.distanceToTargetLineMin = -100;
    m.distanceToTargetLineMax = 100;
    m.distanceToTargetLine = m.distanceToTargetLineGroup.createChild("path")
      .setColor(m.myGreen)
      .moveTo(200,m.distanceToTargetLineMin)
      .horiz(30)
      .moveTo(200,m.distanceToTargetLineMin)
      .vert(m.distanceToTargetLineMax-m.distanceToTargetLineMin)
      .horiz(30)
      .setStrokeLineWidth(m.myLineWidth*5); 
    
    m.distanceToTargetLineTextGroup = m.distanceToTargetLineGroup.createChild("group");
      
    m.distanceToTargetLineChevron = m.distanceToTargetLineTextGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(200,0)
      .setDouble("character-size",m.myFontSize* 60)
      .setAlignment("left-center")
      .setText("<"); 
      
    m.distanceToTargetLineChevronText = m.distanceToTargetLineTextGroup.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(230,0)
      .setDouble("character-size",m.myFontSize* 40)
      .setAlignment("left-center")
      .setText("x");
    
    m.distanceToTargetLineGroup.hide(); 

    
      
#       obj.ASC = obj.svg.createChild("path")# (Attack Steering Cue (ASC))
#       .moveTo(-8*mr,0)
#       .arcSmallCW(8*mr,8*mr, 0, 8*mr*2, 0)
#       .arcSmallCW(8*mr,8*mr, 0, -8*mr*2, 0)
#       .setStrokeLineWidth(m.myLineWidth*1)
#       .setColor(0,1,0).hide();
#       append(obj.total, obj.ASC);  
      
 
      
    
    
    m.root.setColor(m.red,m.green,m.blue,1);


#           888    888 888     888 8888888b.       888b     d888 8888888888 888b    888 888     888 
#           888    888 888     888 888  "Y88b      8888b   d8888 888        8888b   888 888     888 
#           888    888 888     888 888    888      88888b.d88888 888        88888b  888 888     888 
#           8888888888 888     888 888    888      888Y88888P888 8888888    888Y88b 888 888     888 
#           888    888 888     888 888    888      888 Y888P 888 888        888 Y88b888 888     888 
#           888    888 888     888 888    888      888  Y8P  888 888        888  Y88888 888     888 
#           888    888 Y88b. .d88P 888  .d88P      888   "   888 888        888   Y8888 Y88b. .d88P 
#           888    888  "Y88888P"  8888888P"       888       888 8888888888 888    Y888  "Y88888P"

    m.menu =
      m.canvas.createGroup()
            .setTranslation(100,75)
            .set("font", "A10-HUD.ttf")
            .setDouble("character-size",m.myFontSize* 25)
            .setDouble("character-aspect-ratio", 1);


    m.menuLine1 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*1)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menuLine2 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*2)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");
      
    m.menuLine3 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*3)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menuLine4 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*4)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menuLine5 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*5)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menuLine6 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*6)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menuLine7 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*7)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menuLine8 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*8)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menuLine9 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*9)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menuLine10 = m.menu.createChild("text")
      .setColor(m.myGreen)
      .setTranslation(0,0+hudMenuSpacing*10)
      #.setDouble("character-size",m.myFontSize* 14)
      .setAlignment("left-center")
      .setText("8888888888888888");

    m.menu.hide();

    
    m.loads_hash =  {
     "30mm Cannon":"30MM",
     "MK-82": "MK82LD",
     "MK-82AIR": "MK82AIR",
     "MK-84": "MK84LD",
     "CBU-87": "CBU87",
     "AGM-65B": "AGM65",
     "LAU-68": "RKT",
     "AIM-9M": "AIM9",
    };
    
    #m.pylonsSide_hash = {
    #  0 : "L",
    #  1 : "L",
    #  2 : "L",
    #  3 : "C",
    #  4 : "R",
    #  5 : "R",
    #  6 : "R",
    #};
    
    m.input = {
      pitch:      "/orientation/pitch-deg",
      roll:       "/orientation/roll-deg",
      hdg:        "/orientation/heading-magnetic-deg",
      hdgReal:    "/orientation/heading-deg",
      hdgBug:     "/autopilot/settings/heading-bug-deg",
      hdgDisplay: "/instrumentation/efis/mfd/true-north",
      speed_n:    "velocities/speed-north-fps",
      speed_e:    "velocities/speed-east-fps",
      speed_d:    "velocities/speed-down-fps",
      alpha:      "/orientation/alpha-deg",
      beta:       "/orientation/side-slip-deg",
      gload:      "/accelerations/pilot-g",
      ias:        "/velocities/airspeed-kt",
      mach:       "/velocities/mach",
      gs:         "/velocities/groundspeed-kt",
      vs:         "/velocities/vertical-speed-fps",
      uBody_fps:  "/velocities/uBody-fps",
      vBody_fps:  "/velocities/vBody-fps",
      wBody_fps:  "/velocities/wBody-fps",
      alt:        "/position/altitude-ft",
      alt_instru: "/instrumentation/altimeter/indicated-altitude-ft",
      rad_alt:    "position/altitude-agl-ft", #"/instrumentation/radar-altimeter/radar-altitude-ft",
      wow_nlg:    "/gear/gear[1]/wow",
      gearPos:    "/gear/gear[1]/position-norm",
      airspeed:   "/velocities/airspeed-kt",
      target_spd: "/autopilot/settings/target-speed-kt",
      acc:        "/fdm/jsbsim/accelerations/udot-ft_sec2",
      NavFreq:    "/instrumentation/nav/frequencies/selected-mhz",
      destRunway: "/autopilot/route-manager/destination/runway",
      destAirport:"/autopilot/route-manager/destination/airport",
      distNextWay:"/autopilot/route-manager/wp/dist",
      NextWayNum :"/autopilot/route-manager/current-wp",
      NextWayTrueBearing:"/autopilot/route-manager/wp/true-bearing-deg",
      NextWayBearing:"/autopilot/route-manager/wp/bearing-deg",
      AutopilotStatus:"/autopilot/locks/AP-status",
      ILS_valid     :"/instrumentation/nav/data-is-valid",
      NavHeadingRunwayILS:"/instrumentation/nav/heading-deg",
      ILS_gs_in_range :"/instrumentation/nav/gs-in-range",
      ILS_gs_deg:  "/instrumentation/nav/gs-direct-deg",
      NavHeadingNeedleDeflectionILS:"/instrumentation/nav/heading-needle-deflection-norm",

      x_offset_m:    "/sim/current-view/x-offset-m",
      y_offset_m:    "/sim/current-view/y-offset-m",
      z_offset_m:    "/sim/current-view/z-offset-m",
      
      MasterArm      :"/controls/armament/master-arm",
      TimeToTarget   :"/sim/dialog/groundtTargeting/time-to-target",
      AirToAir       :"/A-10/hud/air-to-air-mode",

      currentWp     : "/autopilot/route-manager/current-wp",
      currentWpID   : "/autopilot/route-manager/wp/id",
      wpTimeToGo    : "/autopilot/route-manager/wp/eta",
      utcTime       : "/sim/time/gmt-string",

      HUDPower      : "systems/electrical/outputs/hud", 
      HUDMode       : "controls/hud/m-sel",
    };
    
    foreach(var name; keys(m.input))
      m.input[name] = props.globals.getNode(m.input[name], 1);
    
    m.low = 1;
    return m;
  },
  update: func()
  {

    if(me.input.HUDPower.getValue()<23){
      me.root.setVisible(0);
    }else{
      if (me.input.HUDMode.getValue()==1){
        me.menu.setVisible(1);
      } else {
        me.menu.setVisible(0);
      }
      if (me.input.HUDMode.getValue()>=2){
            me.root.setVisible(1);
      } else {
        me.root.setVisible(0);
      }
    }

    me.hydra = 0;
    me.strf = me.input.AirToAir.getValue()==1?0:1; #A/G Gun symbology based on HUD mode
    me.designatedDistanceFT = nil;
    #me.airspeed.setText(sprintf("%d", me.input.ias.getValue()));
    #me.groundspeed.setText(sprintf("G %3d", me.input.gs.getValue()));
    #me.vertical_speed.setText(sprintf("%.1f", me.input.vs.getValue() * 60.0 / 1000));
    HudMath.reCalc();
    me.input.hdgDisplay.setBoolValue(0);#use magn degs
    
    #loading Flightplan
    me.fp = flightplan();
    
    #Choose the heading to display
    me.getHeadingToDisplay();
    
    #Think this code sucks. If everyone have better, please, proceed :)
    me.eegsShow=0;
    me.selectedWeap = pylons.fcs.getSelectedWeapon();

    me.texelPerDegreeX = HudMath.getPixelPerDegreeXAvg(5);
    me.texelPerDegreeY = HudMath.getPixelPerDegreeYAvg(5);

    
    me.Fire_GBU.setText("Fire");
    me.showFire_GBU = 0;
    
    me.low = 0;
    if((me.selectedWeap != nil and me.input.MasterArm.getValue()) and (me.input.HUDMode.getValue()==3)){
      if ((me.selectedWeap.type == "MK-82" or me.selectedWeap.type == "MK-82AIR" or me.selectedWeap.type == "MK-84" or me.selectedWeap.type == "CBU-87") and (!me.input.AirToAir.getValue())) {
        var ccip = me.selectedWeap.getCCIPadv(16,0.1);
        if (ccip != nil) {
          me.targetArray[0].show();
          var c = HudMath.getPosFromCoord(ccip[0]);
          me.targetArray[0].setTranslation(subvec(c,0,2));
          if (me["fpvCalc"] != nil) {
            me.rootLine.removeAllChildren();
            me.rootLine.createChild("path")
              .setColor(me.myGreen)
              .moveTo(me.fpvCalc)
              .lineTo(c)
              .setStrokeLineWidth(me.myLineWidth*4);
            me.rootLine.show();
            me.rootLine.update();
          }
          me.low = !ccip[1];
        } else {
          me.targetArray[0].hide();
          me.rootLine.hide();
        }        
      } elsif (me.selectedWeap.type == "AIM-9M") {
        var seeker = me.selectedWeap.getSeekerInfo();
        if (seeker != nil) {
          me.targetArray[0].show();
          var c = HudMath.getCenterPosFromDegs(seeker[0],seeker[1]);
          me.targetArray[0].setTranslation(c);
        } else {
          me.targetArray[0].hide();
        }        
        me.rootLine.hide();
      } elsif (me.selectedWeap.type == "AGM-65B") {
        var seeker = me.selectedWeap.getSeekerInfo();
        if (seeker != nil) {
          me.targetArray[0].show();
          var c = HudMath.getCenterPosFromDegs(seeker[0],seeker[1]);
          me.targetArray[0].setTranslation(c);
        } else {
          me.targetArray[0].hide();
          me.rootLine.hide();
        }        
      } elsif(me.selectedWeap.type != "30mm Cannon" and me.selectedWeap.type != "LAU-68"){
        #Doing the math only for bombs
        if(me.selectedWeap.stage_1_duration+me.selectedWeap.stage_2_duration == 0){
          
          #print("Class of Load:" ~ me.selectedWeap.class);     
          me.DistanceToShoot = nil;
          me.DistanceToShoot = me.selectedWeap.getCCRP(me.input.TimeToTarget.getValue(), 0.05);
        
          if(me.DistanceToShoot != nil ){
            if(me.DistanceToShoot/ (me.input.gs.getValue() * KT2MPS) < 30){
              me.showFire_GBU = 1;
                me.Fire_GBU.setText(sprintf("TTR: %d ", int(me.DistanceToShoot/ (me.input.gs.getValue() * KT2MPS))));
              if(me.DistanceToShoot/ (me.input.gs.getValue() * KT2MPS) < 15){
                me.Fire_GBU.setText(sprintf("Fire : %d ", int(me.DistanceToShoot/ (me.input.gs.getValue() * KT2MPS))));
              }
            }
          }else{
             #print("Distance to shoot : nil");
          }
        }
        me.targetArray[0].hide();
        me.rootLine.hide();
      } else {
        me.targetArray[0].hide();
        me.rootLine.hide();
        me.eegsShow=me.input.MasterArm.getValue();
      }      
    } else {
          me.targetArray[0].hide();
          me.rootLine.hide();
    }
    
    me.Fire_GBU.setVisible(me.showFire_GBU);
    
    

    #me.hdg.setText(sprintf("%03d", me.input.hdg.getValue()));
    me.horizStuff = HudMath.getStaticHorizon();
    me.horizon_group.setTranslation(me.horizStuff[0]);
    me.h_rot.setRotation(me.horizStuff[1]);
    me.horizon_sub_group.setTranslation(me.horizStuff[2]);
    
#     var rot = -me.input.roll.getValue() * math.pi / 180.0;
    #me.Textrot.setRotation(rot);

    #Displaying ILS STUFF (but only show after LOCALIZER capture)
    #me.display_ILS_STUFF();
    
    #ILS not dependent of the Scale (but only show after GS capture)
    #me.display_ILS_Square();
    #me.RunwayOnTheHorizonLine.hide();
    
    
    # Bore Cross. In navigation, the cross should only appear on NextWaypoint gps cooord, when dist to this waypoint is bellow 10 nm
    me.NXTWP = geo.Coord.new();
    
    #Calculate the GPS coord of the next WP
    me.NextWaypointCoordinate();
      
    #Display the Next WP
    me.displayWaypointCross();
     
    #Gun Cross (bore)
    me.displayBoreCross();
    
    
    
    
    # flight path vector (FPV)
    me.display_Fpv();

    # display Flight Path Angle
    me.display_fpa();
    
    # displaying the little house
    me.display_house();
    
    #chevronGroup
    me.display_Chevron();

    #Don't know what that does ...
#     var speed_error = 0;
#     if( me.input.target_spd.getValue() != nil )
#       speed_error = 4 * clamp(
#         me.input.target_spd.getValue() - me.input.airspeed.getValue(),
#         -15, 15
#       );
      
    #Acc accBoxGroup in G(so I guess /9,8)
    me.display_GCAS_Box();

    #display_radarAltimeter
    me.display_radAlt();
            
    #Display speedAltGroup
    me.display_speedAltGroup();
    
    #Display diplay_inverted_T
    me.display_inverted_T();
    
    #Display aoa 
    me.display_alpha();
    
    #Display gload
    me.display_gload();

    #Diplay Load type
    me.display_loadsType();

    #Display bullet Count
    me.display_BulletCount();
    
    #Display selected
    #me.displaySelectedPylons();
    
    #Display Route dist and waypoint number
    me.display_Waypoint();
    
    #me.display_vsi();#right hud scale
    #me.display_aoa();
    
    #me.hdg.hide();
    #me.groundspeed.hide();  
    #me.rad_alt.hide();
    #me.airspeed.hide();
    #me.energy_cue.hide();
    #me.acc.hide();
    #me.vertical_speed.hide();
    
    #Displaying the circles, the squares or even the triangles (triangles will be for a IR lock without radar)
    #me.displayTarget();
    
    
    # -------------------- displayHeadingHorizonScale ---------------
    me.displayHeadingHorizonScale();
    
    
    # -------------------- display_heading_bug ---------------
    me.display_heading_bug();
    
    
    #---------------------- EEFS --------------------
    if (!me.eegsShow) {
      me.eegsGroup.setVisible(me.eegsShow);
    }
    if (me.eegsShow and !me.eegsLoop.isRunning) {
        me.eegsLoop.start();
    } elsif (!me.eegsShow and me.eegsLoop.isRunning) {
        me.eegsLoop.stop();
    }
    
    # Terrain warning:
    var timeC = 15;
    if ((getprop("velocities/speed-east-fps") != 0 or getprop("velocities/speed-north-fps") != 0) and getprop("gear/gear[0]/wow") != 1 and
          getprop("/gear/gear[1]/wow") != 1 and (
         (getprop("/gear/gear[0]/position-norm")<1)
      or (getprop("/gear/gear[0]/position-norm")>0.99 and getprop("/position/altitude-agl-ft") > 164)
      )) {
      me.start = geo.aircraft_position();

      me.speed_down_fps  = getprop("velocities/speed-down-fps");
      me.speed_east_fps  = getprop("velocities/speed-east-fps");
      me.speed_north_fps = getprop("velocities/speed-north-fps");
      me.speed_horz_fps  = math.sqrt((me.speed_east_fps*me.speed_east_fps)+(me.speed_north_fps*me.speed_north_fps));
      me.speed_fps       = math.sqrt((me.speed_horz_fps*me.speed_horz_fps)+(me.speed_down_fps*me.speed_down_fps));
      me.headingc = 0;
      if (me.speed_north_fps >= 0) {
        me.headingc -= math.acos(me.speed_east_fps/me.speed_horz_fps)*R2D - 90;
      } else {
        me.headingc -= -math.acos(me.speed_east_fps/me.speed_horz_fps)*R2D - 90;
      }
      me.headingc = geo.normdeg(me.heading);
      #cos(90-heading)*horz = east
      #acos(east/horz) - 90 = -head

      me.end = geo.Coord.new(me.start);
      me.end.apply_course_distance(me.heading, me.speed_horz_fps*FT2M);
      me.end.set_alt(me.end.alt()-me.speed_down_fps*FT2M);

      me.dir_x = me.end.x()-me.start.x();
      me.dir_y = me.end.y()-me.start.y();
      me.dir_z = me.end.z()-me.start.z();
      me.xyz = {"x":me.start.x(),  "y":me.start.y(),  "z":me.start.z()};
      me.dir = {"x":me.dir_x,      "y":me.dir_y,      "z":me.dir_z};

      me.geod = get_cart_ground_intersection(me.xyz, me.dir);
      if (me.geod != nil) {
        me.end.set_latlon(me.geod.lat, me.geod.lon, me.geod.elevation);
        me.dist = me.start.direct_distance_to(me.end)*M2FT;
        me.time = me.dist / me.speed_fps;
        timeC = me.time;
      }
    }
    if (timeC < 8) {
      me.pullUp.show();
    } else {
      me.pullUp.hide();
    }

    settimer(func me.update(), 0.05);
  },
  
  display_vsi: func () {
    var fps = me.input.vs.getValue();
    me.vsiArrow.setTranslation(0,-fps);
    me.vsiScale.setScale(1,-fps/200);
  },
  
  display_aoa: func () {
    var aoa = me.input.alpha.getValue();
    if (aoa>25) aoa = 25;
    if (aoa<-15) aoa = -15;
    if (me.input.gs.getValue()<5) aoa = 0;
    me.AoAArrow.setTranslation(0,-aoa*10);
    me.AoAScale.setScale(1,aoa/15);
    
  },
  
  getHeadingToDisplay:func(){
    
      if(me.input.hdgDisplay.getValue()){
        me.heading = me.input.hdgReal.getValue();
      }else{
        me.heading = me.input.hdg.getValue();
      }
  },
  
  displayHeadingHorizonScale:func(){
      #Depend of which heading we want to display
#       if(me.input.hdgDisplay.getValue()){
#         me.heading = me.input.hdgReal.getValue();
#       }else{
#         me.heading = me.input.hdg.getValue();
#       }
    
      me.headOffset = me.heading/10 - int (me.heading/10);
      me.headScaleOffset = me.headOffset;
      me.middleText = roundabout(me.heading/10);

      me.middleText = me.middleText == 36?0:me.middleText;
      me.leftText = me.middleText == 0?35:me.middleText-1;
      me.rightText = me.middleText == 35?0:me.middleText+1;
      me.rightRightText = me.rightText == 35?0:me.rightText+1;
      
      if (me.headOffset > 0.5) {
        me.middleOffset = -(me.headScaleOffset-1)*me.headScaleTickSpacing*2;
        #me.hdgLineL.show();
        #me.hdgLineR.hide();
      } else {
        me.middleOffset = -me.headScaleOffset*me.headScaleTickSpacing*2;
        #me.hdgLineR.show();
        #me.hdgLineL.hide();
      }
      #print(" me.heading:", me.heading,", me.headOffset:",me.headOffset, ", me.middleOffset:",me.middleOffset);
      me.headingScaleGroup.setTranslation(me.middleOffset , 0);
      me.hdgRH.setText(sprintf("%02d", me.rightText));
      me.hdgMH.setText(sprintf("%02d", me.middleText));
      me.hdgLH.setText(sprintf("%02d", me.leftText));
      me.hdgRRH.setText(sprintf("%02d", me.rightRightText));
      
      #me.hdgMH.setTranslation(me.middleOffset , 0);
      me.headingScaleGroup.update();
    
  },
  
  # flight path vector (FPV)
  display_Fpv:func(){
    me.fpvCalc = HudMath.getFlightPathIndicatorPos();
    me.fpv.setTranslation(me.fpvCalc);
    me.fpvL.setVisible(me.low);
    me.fpvL.setTranslation(me.fpvCalc[0],me.fpvCalc[1]-20);#CCIP Too low indicator
    if(me.input.AutopilotStatus.getValue()=="AP1"){
      me.AutopilotStar.setTranslation(me.fpvCalc);
      me.AutopilotStar.show();
    }else{
      me.AutopilotStar.hide();
    }
    
    # if (me.input.MasterArm.getValue()) {
    me.headingStuff.setTranslation(0,700);
    #me.speedAltGroup.setTranslation(0, math.min(375,math.max(-300,me.fpvCalc[1]))+356);
    me.speedAltGroup.setTranslation(0, 300)
    # } else {
    #   me.headingStuff.setTranslation(0,math.min(300,math.max(-356,me.fpvCalc[1]))+612);
    #   me.speedAltGroup.setTranslation(0, math.min(375,math.max(-356,me.fpvCalc[1]))+356);
    # }
  },

  display_fpa:func(){
    me.fpa.setText(sprintf("%01d", me.input.pitch.getValue()));
    me.fpa.show();
  },
  
  display_house:func(){
    if(me.input.NextWayNum.getValue()!=-1){
      if(me.input.distNextWay.getValue() != nil and me.input.gearPos.getValue() == 0 and
        (!me.isInCanvas(HudMath.getPosFromCoord(me.NXTWP)[0],HudMath.getPosFromCoord(me.NXTWP)[1]) or me.input.distNextWay.getValue()>10) ){
        #Depend of which heading we want to display
#           if(me.input.hdgDisplay.getValue()){
#             me.heading = me.input.hdgReal.getValue();
#           }else{
#             me.heading = me.input.hdg.getValue();
#           }
          if(me.input.hdgDisplay.getValue()){
            me.houseTranslation = -(geo.normdeg180(me.heading - me.input.NextWayTrueBearing.getValue() ))*me.headScaleTickSpacing/5;
            #me.waypointHeading.setText(sprintf("%03d/",me.input.NextWayTrueBearing.getValue()));
          }else{
            me.houseTranslation = -(geo.normdeg180(me.heading - me.input.NextWayBearing.getValue() ))*me.headScaleTickSpacing/5;
            #me.waypointHeading.setText(sprintf("%03d/",me.input.NextWayBearing.getValue()));
          }
          #headOffset = -(geo.normdeg180(me.heading - me.input.hdgBug.getValue() ))*me.headScaleTickSpacing/5;
          #me.head_scale_route_pointer.setTranslation(headOffset,0);
        
        
        #print(me.houseTranslation/(me.headScaleTickSpacing/5));
        
        me.HeadingHouse.setTranslation(clamp(me.houseTranslation,-me.maxladderspan,me.maxladderspan),clamp(me.fpvCalc[1],-450,450));
        if(abs(me.houseTranslation/(me.headScaleTickSpacing/5))>90){
          me.HeadingHouse.setRotation(me.horizStuff[1]+(180* D2R));
        }else{
          me.HeadingHouse.setRotation(me.horizStuff[1]);
        }
        me.HeadingHouse.show();
      }else{
        me.HeadingHouse.hide();
      }
    }else{
        me.HeadingHouse.hide();
    }
  },
  
  display_Chevron : func(){
     
    #me.chevronGroup.setTranslation(me.fpvCalc[0],me.fpvCalc[1]-me.input.acc_yas.getValue()*me.chevronFactor);
    
    me.chevronGroup.hide();
  },
  
  display_heading_bug : func(){
      #Depend of which heading we want to display
#       if(me.input.hdgDisplay.getValue()){
#         me.heading = me.input.hdgReal.getValue();
#       }else{
         me.heading = me.input.hdg.getValue();
#       }
      if (me.heading != nil and me.input.hdgBug.getValue() != nil) {
        headOffset = -(geo.normdeg180(me.heading - me.input.hdgBug.getValue() ))*me.headScaleTickSpacing/5;
        me.head_scale_route_pointer.setTranslation(headOffset,0);
        me.head_scale_route_pointer.setVisible(me.input.NextWayNum.getValue()!=-1 and me.input.distNextWay.getValue() != nil);
        } else {
          me.head_scale_route_pointer.setVisible(0);
        }
      me.headingScaleGroup.update();
  },
  
  display_GCAS_Box:func(){ # This is for the GCAS box, linked to OSP ALT ALERT switch. Add to A-10.nas, only RALT for now so max 5k. 34-1-1 1-69
    if(0 and me.input.wow_nlg.getValue()){
      me.warnAlt.setText(sprintf("%.2f", int(me.input.acc.getValue()/9.8*1000+1)/1000));
      me.GCASGroup.show();
    }else{
      me.GCASGroup.hide();
    } 
    
    me.GCASGroup.update();
    
  },
  display_speedAltGroup:func(){
      me.Speed.setText(sprintf("%d",int(me.input.ias.getValue())));
      if(me.input.mach.getValue()>= 1.5){#this large means it will never display unless reduced
        me.Speed_Mach.setText(sprintf("%0.2f",me.input.mach.getValue()));
        me.Speed_Mach.show();
      }else{
        me.Speed_Mach.hide();
      } 

    me.hundred_feet_Alt.setText(sprintf("%5d",math.round(me.input.alt_instru.getValue(),10)));
    me.speedAltGroup.update();       
  },
  
  display_radAlt:func(){
    if(abs(me.input.pitch.getValue())<20 and abs(me.input.roll.getValue())<20 and me.input.rad_alt.getValue() <9999){ #if the angle is above 20° or 10000AGL the radar do not work
      me.hudRAlt.setText(sprintf("%04dR",math.round(me.input.rad_alt.getValue(),10)));
    }else{
      me.hudRAlt.setText("XXXXR");
    }
    me.hudRAlt.show();
  },

  display_inverted_T:func(){
    if(me.input.gearPos.getValue()){
      me.InvertedT.setTranslation(0, HudMath.getCenterPosFromDegs(0,-13)[1]);
      me.InvertedT.show();
    }else{
      me.InvertedT.hide();
    }
  },
  display_alpha:func(){
    if(0 and me.input.gearPos.getValue() < 1 and abs(me.input.alpha.getValue())>2 and me.input.MasterArm.getValue() == 0){
      me.aoa.setText(sprintf("%0.1f",me.input.alpha.getValue()));
      me.alphaGroup.show();
    }else{
      me.alphaGroup.hide();
    }
  },
  
  display_gload:func(){
    me.gload_Text.setText(sprintf("%0.1f",me.input.gload.getValue()));
    me.alphaGloadGroup.show();
    me.alpha_Text.setText("");
  },
  
  display_loadsType:func{
    if (me.input.HUDMode.getValue() == 3){
      if(me.input.MasterArm.getValue() and me.selectedWeap != nil){
  #       print(me.loads_hash[me.selectedWeap.type]);
        me.loads_Type_text.setText(me.loads_hash[me.selectedWeap.type]);
        me.loads_Type_text.show();
      }else{
        me.loads_Type_text.hide();
      }
    } else {
      me.loads_Type_text.hide()
    }
  },
  
  display_BulletCount:func{
    if (me.input.HUDMode.getValue() == 3){
      if(me.input.MasterArm.getValue() and me.selectedWeap != nil){
  #       print("Test");
  #       print("Test:" ~ me.loads_hash[me.selectedWeap.type] ~ " : " ~ pylons.fcs.getAmmo());
  #       print("Test:" ~ me.selectedWeap.type ~ " : " ~ pylons.fcs.getAmmo());
        if(me.selectedWeap.type == "30mm Cannon"){
  #         print(me.loads_hash[me.selectedWeap.type] ~ " : " ~ pylons.fcs.getAmmo());
          me.Bullet_Count.setText(sprintf("%3d", pylons.fcs.getAmmo()));
          me.bullet_CountGroup.show();
        }else{
          me.bullet_CountGroup.hide();
        }
      }else{
        me.bullet_CountGroup.hide();
      }

    }else{
        me.bullet_CountGroup.hide()
    }
      
  },

  
  display_Waypoint:func(){ #waypointSimpleGroup is what we use. WaypointGroup is old code references

    # me.stptElevation = getprop("/autopilot/route-manager/route/wp[" ~ me.input.currentWp.getValue() ~ "]/altitude-ft");
    if(me.input.distNextWay.getValue() != nil and me.input.gearPos.getValue() == 0){
      if(me.input.distNextWay.getValue()>10){
        me.waypointDistAlt.setText(sprintf("%dN",int(me.input.distNextWay.getValue())));
      }else{
        me.waypointDistAlt.setText(sprintf("%01.1fN/%s",me.input.distNextWay.getValue(),getprop("autopilot/route-manager/wp/eta")));
      }
      # me.waypointNumberSimple.setText(sprintf("%02d",me.input.NextWayNum.getValue()));
      me.stptInfo.setText(sprintf("%02d/%s",me.input.NextWayNum.getValue(),me.input.currentWpID.getValue()));
      me.utcTime.setText(sprintf("%s",getprop("sim/time/gmt-string")));
      
      if(me.input.AutopilotStatus.getValue()=="AP1"){
        me.waypointGroup.show();
        me.waypointSimpleGroup.hide();
      }else{
        me.waypointSimpleGroup.show();
        me.waypointGroup.hide();
      }
    }else{
      me.waypointGroup.hide();
      me.waypointSimpleGroup.hide();
    }
      
  },
  
  
  
  displayDLZ:func(){
    if(me.selectedWeap != nil and me.input.MasterArm.getValue()){
        
        #Testings
        if(me.selectedWeap.type != "30mm Cannon" and me.selectedWeap.type != "LAU-68"){ 
            if(me.selectedWeap.class == "A" and me.selectedWeap.parents[0] == armament.AIM){
            #Taking back the DLZ
            
            me.myDLZ = pylons.getDLZ();

            if(me.myDLZ != nil and size(me.myDLZ) == 5 and me.myDLZ[4]<me.myDLZ[0]*2){
              #Max
              me.MaxFireRange.setTranslation(0,clamp((me.distanceToTargetLineMax-me.distanceToTargetLineMin)-(me.myDLZ[0]*(me.distanceToTargetLineMax-me.distanceToTargetLineMin)/ me.MaxRadarRange)-100,me.distanceToTargetLineMin,me.distanceToTargetLineMax));

              #MmiFireRange
              me.MinFireRange.setTranslation(0,clamp((me.distanceToTargetLineMax-me.distanceToTargetLineMin)-(me.myDLZ[3]*(me.distanceToTargetLineMax-me.distanceToTargetLineMin)/ me.MaxRadarRange)-100,me.distanceToTargetLineMin,me.distanceToTargetLineMax));

              #NEZFireRange           
              me.NEZFireRange.setTranslation(0,clamp((me.distanceToTargetLineMax-me.distanceToTargetLineMin)-(me.myDLZ[2]*(me.distanceToTargetLineMax-me.distanceToTargetLineMin)/ me.MaxRadarRange)-100,me.distanceToTargetLineMin,me.distanceToTargetLineMax));

              me.missileFireRange.show();
              return 1;
            }
          }elsif(me.selectedWeap.class == "GM" or me.selectedWeap.class == "M"){
              me.MaxFireRange.setTranslation(0,clamp((me.distanceToTargetLineMax-me.distanceToTargetLineMin)-(me.selectedWeap.max_fire_range_nm*(me.distanceToTargetLineMax-me.distanceToTargetLineMin)/ me.MaxRadarRange)-100,me.distanceToTargetLineMin,me.distanceToTargetLineMax));
              
              #MmiFireRange
              me.MinFireRange.setTranslation(0,clamp((me.distanceToTargetLineMax-me.distanceToTargetLineMin)-(me.selectedWeap.min_fire_range_nm*(me.distanceToTargetLineMax-me.distanceToTargetLineMin)/ me.MaxRadarRange)-100,me.distanceToTargetLineMin,me.distanceToTargetLineMax));
              
              me.NEZFireRange.hide();
              me.MaxFireRange.show();
              me.MinFireRange.show();
              
              return 1;   
          }
        } 
      }
      return 0;
  },
  
  
  displayRunway:func(){
    
    #Coord of the runways gps coord
    var RunwayCoord =  geo.Coord.new();
    var RunwaysCoordCornerLeft = geo.Coord.new();
    var RunwaysCoordCornerRight = geo.Coord.new();
    var RunwaysCoordEndCornerLeft = geo.Coord.new();
    var RunwaysCoordEndCornerRight = geo.Coord.new();
    
    #var info = airportinfo(icao;
    #Need to select the runways and write the conditions
    #2. SYNTHETIC RUNWAY. The synthetic runway symbol is an aid for locating the real runway, especially during low visibility conditions. 
    #It is only visible when: 
    #a. The INS is on.
    #b. The airport is the current fly-to waypoint. 
    #c. The runway data (heading and glideslope) were entered.
    #d. Both localizer and glideslope have been captured 
    #e. The runway is less than 10 nautical miles away. 
    #f. Lateral deviation is less than 7º.
    # The synthetic runway is removed from the HUD as soon as there is weight on the landing gear’s wheels. 
    
    
    #print("reciprocal:" , info.runways[rwy].reciprocal, " ICAO:", info.id, " runway:",info.runways[rwy].id);
    
    #Calculating GPS coord of the runway's corners
    RunwayCoord.set_latlon(me.info.runways[me.selectedRunway].lat, me.info.runways[me.selectedRunway].lon, me.info.elevation);
    
    RunwaysCoordCornerLeft.set_latlon(me.info.runways[me.selectedRunway].lat, me.info.runways[me.selectedRunway].lon, me.info.elevation);
    RunwaysCoordCornerLeft.apply_course_distance((me.info.runways[me.selectedRunway].heading)-90,(me.info.runways[me.selectedRunway].width)/2);
    
    RunwaysCoordCornerRight.set_latlon(me.info.runways[me.selectedRunway].lat, me.info.runways[me.selectedRunway].lon, me.info.elevation);
    RunwaysCoordCornerRight.apply_course_distance((me.info.runways[me.selectedRunway].heading)+90,(me.info.runways[me.selectedRunway].width)/2);
    
    RunwaysCoordEndCornerLeft.set_latlon(me.info.runways[me.selectedRunway].lat, me.info.runways[me.selectedRunway].lon, me.info.elevation);
    RunwaysCoordEndCornerLeft.apply_course_distance((me.info.runways[me.selectedRunway].heading)-90,(me.info.runways[me.selectedRunway].width)/2);
    RunwaysCoordEndCornerLeft.apply_course_distance((me.info.runways[me.selectedRunway].heading),me.info.runways[me.selectedRunway].length);
    
    RunwaysCoordEndCornerRight.set_latlon(me.info.runways[me.selectedRunway].lat, me.info.runways[me.selectedRunway].lon, me.info.elevation);
    RunwaysCoordEndCornerRight.apply_course_distance((me.info.runways[me.selectedRunway].heading)+90,(me.info.runways[me.selectedRunway].width)/2);
    RunwaysCoordEndCornerRight.apply_course_distance((me.info.runways[me.selectedRunway].heading),me.info.runways[me.selectedRunway].length);
    
    
    #Calculating the HUD coord of the runways coord
    me.MyRunwayTripos                     = HudMath.getPosFromCoord(RunwayCoord);
    me.MyRunwayCoordCornerLeftTripos      = subvec(HudMath.getPosFromCoord(RunwaysCoordCornerLeft),0,2);
    me.MyRunwayCoordCornerRightTripos     = subvec(HudMath.getPosFromCoord(RunwaysCoordCornerRight),0,2);
    me.MyRunwayCoordCornerEndLeftTripos   = subvec(HudMath.getPosFromCoord(RunwaysCoordEndCornerLeft),0,2);
    me.MyRunwayCoordCornerEndRightTripos  = subvec(HudMath.getPosFromCoord(RunwaysCoordEndCornerRight),0,2);
    
    
    

    #Updating : clear all previous stuff
    me.myRunwayGroup.removeAllChildren();
    #drawing the runway
    me.RunwaysDrawing = me.myRunwayGroup.createChild("path")
    .setColor(me.myGreen)
    .moveTo(me.MyRunwayCoordCornerLeftTripos)
    .lineTo(me.MyRunwayCoordCornerRightTripos)
    .lineTo(me.MyRunwayCoordCornerEndRightTripos)
    .lineTo(me.MyRunwayCoordCornerEndLeftTripos)
    .lineTo(me.MyRunwayCoordCornerLeftTripos)
    .setStrokeLineWidth(me.myLineWidth*4);
    
    me.myRunwayGroup.update();
    
    #tranlating the circle ...
    #old stuff : not used anymore
    #me.myRunway.setTranslation(MyRunwayTripos);
    #me.myRunwayBeginLeft.setTranslation(MyRunwayCoordCornerLeftTripos);
    #me.myRunwayBeginRight.setTranslation(MyRunwayCoordCornerRightTripos);
    #me.myRunwayEndRight.setTranslation(MyRunwayCoordCornerEndLeftTripos);
    #me.myRunwayEndLeft.setTranslation(MyRunwayCoordCornerEndRightTripos);
    
    
    #myRunwayBeginLeft
    #me.myRunway.hide();
  },
  
  displayBoreCross:func(){
    #maybe it should be a different cross.
    if(me.input.MasterArm.getValue() and pylons.fcs.getSelectedWeapon() !=nil){   
      if(me.selectedWeap.type == "30mm Cannon" or me.selectedWeap.type == "LAU-68"){#if weapons selected
        me.boreCross.setTranslation(HudMath.getBorePos());
        me.boreCross.show();
      }else{
        me.boreCross.hide();
      }
    }else{
      me.boreCross.hide();
    }
    
  },
  
  displayWaypointCross:func(){
    if(me.input.distNextWay.getValue()!= nil and me.input.distNextWay.getValue()<10 and me.input.gearPos.getValue() == 0 
                       and me.input.NextWayNum.getValue()!=-1 and me.NXTWP != nil and me.fp.currentWP() != nil){#if waypoint is active
      me.WaypointCross.setTranslation(subvec(HudMath.getPosFromCoord(me.NXTWP),0,2));
      me.WaypointCross.show();
    }else{
      me.WaypointCross.hide();
    }
  },
  
  NextWaypointCoordinate:func(){ 
      if(me.fp.currentWP() != nil){
          me.NxtElevation = getprop("/autopilot/route-manager/route/wp[" ~ me.input.currentWp.getValue() ~ "]/altitude-m");
          #print("me.NxtWP_latDeg:",me.NxtWP_latDeg, " me.NxtWP_lonDeg:",me.NxtWP_lonDeg);
          var Geo_Elevation = geo.elevation(me.fp.currentWP().lat , me.fp.currentWP().lon);    
          Geo_Elevation = Geo_Elevation == nil ? 0: Geo_Elevation; 
          #print("Geo_Elevation:",Geo_Elevation," me.NxtElevation:",me.NxtElevation);
          if( me.NxtElevation  == nil or me.NxtElevation  < Geo_Elevation){
            me.NXTWP.set_latlon(me.fp.currentWP().lat , me.fp.currentWP().lon ,  Geo_Elevation + 2);
          }else{
            me.NXTWP.set_latlon(me.fp.currentWP().lat , me.fp.currentWP().lon , me.NxtElevation );
          }
          
      }
  },

  resetGunPos: func {
    me.gunPos   = [];
    for(i = 0;i < me.funnelParts*4;i+=1){
      var tmp = [];
      for(var myloopy = 0;myloopy <= i+1;myloopy+=1){
        append(tmp,nil);
      }
      append(me.gunPos, tmp);
    }
  },
  makeVector: func (siz,content) {
        var vec = setsize([],siz*4);
        var k = 0;
        while(k<siz*4) {
            vec[k] = content;
            k += 1;
        }
        return vec;
  },
  
  displayEEGS: func() {
        #note: this stuff is expensive like hell to compute, but..lets do it anyway.
        #var me.funnelParts = 40;#max 10
        var st = systime();
        me.eegsMe.dt = st-me.lastTime;
        if (me.eegsMe.dt > me.averageDt*3) {
            me.lastTime = st;
            me.resetGunPos();  
            me.eegsGroup.removeAllChildren();
        } else {
            #printf("dt %05.3f",me.eegsMe.dt);
            me.lastTime = st;
            
            me.eegsMe.hdg   = me.input.hdgReal.getValue();
            me.eegsMe.pitch = me.input.pitch.getValue();
            me.eegsMe.roll  = me.input.roll.getValue();
                   
            var hdp = {roll:me.eegsMe.roll,current_view_z_offset_m: me.input.z_offset_m.getValue()};
            
            
            me.eegsMe.ac = geo.aircraft_position();
            me.eegsMe.allow = 1;
            me.drawEEGSPipper = 0;
            me.drawEEGS300 = 0;
            me.drawEEGS600 = 0;
            me.strfRange = 4500 * M2FT;  
            if(me.strf or me.hydra) {
                me.groundDistanceFT = nil;
                var l = 0;
                for (l = 0;l < me.funnelParts*4;l+=1) {
                    # compute display positions of funnel on hud
                    var pos = me.gunPos[l][0];
                    if (pos == nil) {
                        me.eegsMe.allow = 0;
                    } else {
                        var ac  = me.gunPos[l][0][1];
                        pos     = me.gunPos[l][0][0];
                        var el = geo.elevation(pos.lat(),pos.lon());
                        if (el == nil) {
                            el = 0;
                        }

                        if (l != 0 and el > pos.alt()) {
                            var hitPos = geo.Coord.new(pos);
                            hitPos.set_alt(el);
                            me.groundDistanceFT = (el-pos.alt())*M2FT;#ac.direct_distance_to(hitPos)*M2FT;
                            me.strfRange = hitPos.direct_distance_to(me.eegsMe.ac)*M2FT;
                            l = l;
                            break;
                        }
                    }
                }
                #print("me.eegsMe.allow:" ~ me.eegsMe.allow);
                #print(" me.groundDistanceFT:"~ (me.groundDistanceFT==nil?"nil":me.groundDistanceFT));
                # compute display positions of pipper on hud                
                if (me.eegsMe.allow and me.groundDistanceFT != nil) {
                    #print("test");
                    for (var ll = l-1;ll <= l;ll+=1) {
                        var ac    = me.gunPos[ll][0][1];
                        var pos   = me.gunPos[ll][0][0];
                        var pitch = me.gunPos[ll][0][2];

                        me.eegsMe.posTemp = HudMath.getPosFromCoord(pos,ac);
                        me.eegsMe.shellPosDist[ll] = ac.direct_distance_to(pos)*M2FT;
                        me.eegsMe.shellPosX[ll] = me.eegsMe.posTemp[0];#me.eegsMe.xcS;
                        me.eegsMe.shellPosY[ll] = me.eegsMe.posTemp[1];#me.eegsMe.ycS;
                        
                        if (l == ll and me.strfRange*FT2M < 4500) {
                            var highdist = me.eegsMe.shellPosDist[ll];
                            var lowdist = me.eegsMe.shellPosDist[ll-1];
                            me.groundDistanceFT = me.groundDistanceFT/math.cos(90-pitch*D2R);
                            #me.groundDistanceFT = math.sqrt(me.groundDistanceFT*me.groundDistanceFT+me.groundDistanceFT*me.groundDistanceFT);#we just assume impact angle of 45 degs
                            me.eegsPipperX = HudMath.extrapolate(highdist-me.groundDistanceFT,lowdist,highdist,me.eegsMe.shellPosX[ll-1],me.eegsMe.shellPosX[ll]);
                            me.eegsPipperY = HudMath.extrapolate(highdist-me.groundDistanceFT,lowdist,highdist,me.eegsMe.shellPosY[ll-1],me.eegsMe.shellPosY[ll]);
                            me.drawEEGSPipper = 1;
                            #print("Should draw Piper");
                        }
                    }
                }
            }else{       
              for (var l = 0;l < me.funnelParts;l+=1) {
                  # compute display positions of funnel on hud
                  var pos = me.gunPos[l][l+1];
                  if (pos == nil) {
                      me.eegsMe.allow = 0;
                  } else {
                      var ac  = me.gunPos[l][l][1];
                      pos     = me.gunPos[l][l][0];
                      
                      var ps = HudMath.getPosFromCoord(pos, ac);
                      me.eegsMe.xcS = ps[0];
                      me.eegsMe.ycS = ps[1];
                      me.eegsMe.shellPosDist[l] = ac.direct_distance_to(pos)*M2FT;
                      me.eegsMe.shellPosX[l] = me.eegsMe.xcS;
                      me.eegsMe.shellPosY[l] = me.eegsMe.ycS;
                      if (me.designatedDistanceFT != nil and !me.drawEEGSPipper) {
                        if (l != 0 and me.eegsMe.shellPosDist[l] >= me.designatedDistanceFT and me.eegsMe.shellPosDist[l]>me.eegsMe.shellPosDist[l-1]) {
                          var highdist = me.eegsMe.shellPosDist[l];
                          var lowdist = me.eegsMe.shellPosDist[l-1];
                          var fractionX = HudMath.extrapolate(me.designatedDistanceFT,lowdist,highdist,me.eegsMe.shellPosX[l-1],me.eegsMe.shellPosX[l]);
                          var fractionY = HudMath.extrapolate(me.designatedDistanceFT,lowdist,highdist,me.eegsMe.shellPosY[l-1],me.eegsMe.shellPosY[l]);
                          me.eegsRightX[0] = fractionX;
                          me.eegsRightY[0] = fractionY;
                          me.drawEEGSPipper = 1;
                        }
                      }
                      if (!me.drawEEGS300) {
                        if (l != 0 and me.eegsMe.shellPosDist[l] >= 300*M2FT and me.eegsMe.shellPosDist[l]>me.eegsMe.shellPosDist[l-1]) {
                          var highdist = me.eegsMe.shellPosDist[l];
                          var lowdist = me.eegsMe.shellPosDist[l-1];
                          var fractionX = HudMath.extrapolate(300*M2FT,lowdist,highdist,me.eegsMe.shellPosX[l-1],me.eegsMe.shellPosX[l]);
                          var fractionY = HudMath.extrapolate(300*M2FT,lowdist,highdist,me.eegsMe.shellPosY[l-1],me.eegsMe.shellPosY[l]);
                          me.eegsRightX[1] = fractionX;
                          me.eegsRightY[1] = fractionY;
                          me.drawEEGS300 = 1;
                        }
                      }
                      if (!me.drawEEGS600) {
                        if (l != 0 and me.eegsMe.shellPosDist[l] >= 600*M2FT and me.eegsMe.shellPosDist[l]>me.eegsMe.shellPosDist[l-1]) {
                          var highdist = me.eegsMe.shellPosDist[l];
                          var lowdist = me.eegsMe.shellPosDist[l-1];
                          var fractionX = HudMath.extrapolate(600*M2FT,lowdist,highdist,me.eegsMe.shellPosX[l-1],me.eegsMe.shellPosX[l]);
                          var fractionY = HudMath.extrapolate(600*M2FT,lowdist,highdist,me.eegsMe.shellPosY[l-1],me.eegsMe.shellPosY[l]);
                          me.eegsRightX[2] = fractionX;
                          me.eegsRightY[2] = fractionY;
                          me.drawEEGS600 = 1;
                        }
                      }
                  }
              }
            }
            if (me.eegsMe.allow and !(me.strf or me.hydra)) {
                # draw the funnel
                for (var k = 0;k<me.funnelParts;k+=1) {
                    
                    me.eegsLeftX[k]  = me.eegsMe.shellPosX[k];
                    me.eegsLeftY[k]  = me.eegsMe.shellPosY[k];
                }
                me.eegsGroup.removeAllChildren();
                for (var i = 0; i < me.funnelParts-1; i+=1) {
                    me.fnnl = me.eegsGroup.createChild("path")
                        .setColor(me.myGreen)
                        .moveTo(me.eegsLeftX[i], me.eegsLeftY[i])
                        .lineTo(me.eegsLeftX[i+1], me.eegsLeftY[i+1])
                        .setStrokeLineWidth(4);
                    if (i==0) {
                      me.fnnl.setStrokeDashArray([5,5]);
                    }
                }
                if (me.drawEEGSPipper) {
                    me.EEGSdeg = math.max(0,HudMath.extrapolate(me.designatedDistanceFT*FT2M,1200,300,360,0))*D2R;
                    me.EEGSdegPos = [math.sin(me.EEGSdeg)*40,40-math.cos(me.EEGSdeg)*40];
                    
                    #drawing mini and centra point 
                    me.eegsGroup.createChild("path")
                          .moveTo(me.eegsRightX[0],me.eegsRightY[0])
                          .lineTo(me.eegsRightX[0],me.eegsRightY[0])
                          .moveTo(me.eegsRightX[0], me.eegsRightY[0]-40)  
                          .lineTo(me.eegsRightX[0], me.eegsRightY[0]-55)
                          .moveTo(me.eegsRightX[0], me.eegsRightY[0]+40)  
                          .lineTo(me.eegsRightX[0], me.eegsRightY[0]+55)
                          .moveTo(me.eegsRightX[0]-40, me.eegsRightY[0])  
                          .lineTo(me.eegsRightX[0]-55, me.eegsRightY[0])
                          .moveTo(me.eegsRightX[0]+40, me.eegsRightY[0])  
                          .lineTo(me.eegsRightX[0]+55, me.eegsRightY[0])
                          .setColor(me.myGreen)
                          .setStrokeLineWidth(4);
                          
                          
                    #drawing mini and centra point 
                    if(me.designatedDistanceFT*FT2M <1200){
                    me.eegsGroup.createChild("path")
                          .moveTo(me.eegsRightX[0],me.eegsRightY[0]-40)
                          .lineTo(me.eegsRightX[0], me.eegsRightY[0]-55)
                          .setCenter(me.eegsRightX[0],me.eegsRightY[0])
                          .setColor(me.myGreen)
                          .setStrokeLineWidth(4)
                          .setRotation(me.EEGSdeg);
                    }
                    
                    if (me.EEGSdeg<180*D2R) {
                      me.eegsGroup.createChild("path")
                          .setColor(me.myGreen)
                          .moveTo(me.eegsRightX[0], me.eegsRightY[0]-40)
                          .arcSmallCW(40,40,0,me.EEGSdegPos[0],me.EEGSdegPos[1])
                          .setStrokeLineWidth(4);
                    } elsif (me.EEGSdeg>=360*D2R) {
                      me.eegsGroup.createChild("path")
                          .setColor(me.myGreen)
                          .moveTo(me.eegsRightX[0], me.eegsRightY[0]-40)
                          .arcSmallCW(40,40,0,0,80)
                          .arcSmallCW(40,40,0,0,-80)
                          .setStrokeLineWidth(4);
                    } else {
                      me.eegsGroup.createChild("path")
                          .setColor(me.myGreen)
                          .moveTo(me.eegsRightX[0], me.eegsRightY[0]-40)
                          .arcLargeCW(40,40,0,me.EEGSdegPos[0],me.EEGSdegPos[1])
                          .setStrokeLineWidth(4);
                    }
                }
                if (me.drawEEGS300 and !me.drawEEGSPipper) {
                    var halfspan = math.atan2(me.wingspanFT*0.5,300*M2FT)*R2D*HudMath.getPixelPerDegreeAvg(2.0);#35ft average fighter wingspan
                    me.eegsGroup.createChild("path")
                        .setColor(me.myGreen)
                        .moveTo(me.eegsRightX[1]-halfspan, me.eegsRightY[1])
                        .horiz(halfspan*2)
                        .setStrokeLineWidth(4);
                }
                if (me.drawEEGS600 and !me.drawEEGSPipper) {
                    var halfspan = math.atan2(me.wingspanFT*0.5,600*M2FT)*R2D*HudMath.getPixelPerDegreeAvg(2.0);#35ft average fighter wingspan
                    me.eegsGroup.createChild("path")
                        .setColor(me.myGreen)
                        .moveTo(me.eegsRightX[2]-halfspan, me.eegsRightY[2])
                        .horiz(halfspan*2)
                        .setStrokeLineWidth(4);
                }                
                me.eegsGroup.update();
            }
            #print("me.strfRange in meters:" ~me.strfRange*FT2M);
            #Same Piper asthe A/A it should be done in a function
            if (me.eegsMe.allow and (me.strf or me.hydra)) {
                me.eegsGroup.removeAllChildren();
                if (me.drawEEGSPipper and me.strfRange*FT2M <= 4000) {

                    #print("me.strfRange in meters:" ~me.strfRange*FT2M);
                    me.EEGSdeg = math.max(0,HudMath.extrapolate(me.strfRange*FT2M,2400,600,360,0))*D2R;
                    me.EEGSdegPos = [math.sin(me.EEGSdeg)*40,40-math.cos(me.EEGSdeg)*40];
                  
                    
                    #drawing mini line and centra point 
                    me.eegsGroup.createChild("path")
                          .moveTo(me.eegsPipperX,me.eegsPipperY)
                          .lineTo(me.eegsPipperX,me.eegsPipperY)
                          .arcSmallCW(3, 3, 0, 3*2, 0)
                          .arcSmallCW(3, 3, 0, -3*2, 0)
                          .moveTo(me.eegsPipperX, me.eegsPipperY-40)  
                          .lineTo(me.eegsPipperX, me.eegsPipperY-55)
                          .moveTo(me.eegsPipperX, me.eegsPipperY+40)  
                          .lineTo(me.eegsPipperX, me.eegsPipperY+55)
                          .moveTo(me.eegsPipperX-40, me.eegsPipperY)  
                          .lineTo(me.eegsPipperX-55, me.eegsPipperY)
                          .moveTo(me.eegsPipperX+40, me.eegsPipperY)  
                          .lineTo(me.eegsPipperX+55, me.eegsPipperY)
                          .setColor(me.myGreen)
                          .setStrokeLineWidth(4);
                          
                          # Distance to target
                    me.eegsGroup.createChild("text")
                    .setColor(me.myGreen)
                    .setTranslation(me.maxladderspan,-120)
                    .setDouble("character-size", 35)
                    .setAlignment("left-center")
                    .setText(sprintf("%.1f NM", me.strfRange*FT2M/1852));     
                          
                    
                     #drawing piper
                    if(me.strfRange*FT2M <4000){
                    me.eegsGroup.createChild("path")
                          .moveTo(me.eegsPipperX,me.eegsPipperY-40)
                          .lineTo(me.eegsPipperX, me.eegsPipperY-55)
                          .setCenter(me.eegsPipperX,me.eegsPipperY)
                          .setColor(me.myGreen)
                          .setStrokeLineWidth(4)
                          .setRotation(me.EEGSdeg);
                    }
                    
                    if (me.EEGSdeg<180*D2R) {
                      me.eegsGroup.createChild("path")
                          .setColor(me.myGreen)
                          .moveTo(me.eegsPipperX, me.eegsPipperY-40)
                          .arcSmallCW(40,40,0,me.EEGSdegPos[0],me.EEGSdegPos[1])
                          .setStrokeLineWidth(4);
                    } elsif (me.EEGSdeg>=360*D2R) {
                      me.eegsGroup.createChild("path")
                          .setColor(me.myGreen)
                          .moveTo(me.eegsPipperX, me.eegsPipperY-40)
                          .arcSmallCW(40,40,0,0,80)
                          .arcSmallCW(40,40,0,0,-80)
                          .setStrokeLineWidth(4);
                    } else {
                      me.eegsGroup.createChild("path")
                          .setColor(me.myGreen)
                          .moveTo(me.eegsPipperX, me.eegsPipperY-40)
                          .arcLargeCW(40,40,0,me.EEGSdegPos[0],me.EEGSdegPos[1])
                          .setStrokeLineWidth(4);
                    }
                  
                  
                  
                    #var mr = 0.4 * 1.5;
#                     var mr = 1.8;
#                     var pipperRadius = 15 * mr;
#                     if (me.strfRange <= 4000) {
#                         me.eegsGroup.createChild("path")
#                             .moveTo(me.eegsPipperX-pipperRadius, me.eegsPipperY-pipperRadius-2)
#                             .horiz(pipperRadius*2)
#                             .moveTo(me.eegsPipperX-pipperRadius, me.eegsPipperY)
#                             .arcSmallCW(pipperRadius, pipperRadius, 0, pipperRadius*2, 0)
#                             .arcSmallCW(pipperRadius, pipperRadius, 0, -pipperRadius*2, 0)
#                             .moveTo(me.eegsPipperX-2*mr,me.eegsPipperY)
#                             .arcSmallCW(2*mr,2*mr, 0, 2*mr*2, 0)
#                             .arcSmallCW(2*mr,2*mr, 0, -2*mr*2, 0)
#                             .setStrokeLineWidth(4)
#                             .setColor(me.myGreen);
#                     } else {
#                         me.eegsGroup.createChild("path")
#                             .moveTo(me.eegsPipperX-pipperRadius, me.eegsPipperY)
#                             .arcSmallCW(pipperRadius, pipperRadius, 0, pipperRadius*2, 0)
#                             .arcSmallCW(pipperRadius, pipperRadius, 0, -pipperRadius*2, 0)
#                             .moveTo(me.eegsPipperX-2*mr,me.eegsPipperY)
#                             .arcSmallCW(2*mr,2*mr, 0, 2*mr*2, 0)
#                             .arcSmallCW(2*mr,2*mr, 0, -2*mr*2, 0)
#                             .setStrokeLineWidth(4)
#                             .setColor(me.myGreen);
#                     }
                }
                me.eegsGroup.update();
            }
            
            
            
            
            #calc shell positions
            
            me.eegsMe.vel = me.input.uBody_fps.getValue() +3250.0 ; #3250.0 = speed
            
            #me.eegsMe.geodPos = aircraftToCart({x:0.148887, y:-0.050417, z: 0.297955});#position (meters) of gun in aircraft (x and z inverted)
            me.eegsMe.geodPos = aircraftToCart({x:0.1622, y:-0.004295, z: 0.27001});#position (meters) of gun in aircraft (x and z inverted)
            #me.eegsMe.geodPos = aircraftToCart({x:7, y:6, z: 0});#position (meters) of gun in aircraft (x and z inverted) - Testing value do not use in live environment
            me.eegsMe.eegsPos.set_xyz(me.eegsMe.geodPos.x, me.eegsMe.geodPos.y, me.eegsMe.geodPos.z);
            me.eegsMe.altC = me.eegsMe.eegsPos.alt();
            
            me.eegsMe.rs = armament.AIM.rho_sndspeed(me.eegsMe.altC*M2FT);#simplified
            me.eegsMe.rho = me.eegsMe.rs[0];
            me.eegsMe.mass =  (me.hydra?23.6:0.9369635) * armament.LBM2SLUGS;#0.1069=lbs
            
            #print("x,y");
            #printf("%d,%d",0,0);
            #print("-----");
            var multi = (me.strf or me.hydra)?4:1;
            for (var j = 0;j < me.funnelParts*multi;j+=1) {
                
                #calc new speed
                me.eegsMe.Cd = drag(me.eegsMe.vel/ me.eegsMe.rs[1],me.hydra?0:0.193);#0.193=cd
                me.eegsMe.q = 0.5 * me.eegsMe.rho * me.eegsMe.vel * me.eegsMe.vel;
                me.eegsMe.deacc = (me.eegsMe.Cd * me.eegsMe.q * (me.hydra?0.00136354:0.007609)) / me.eegsMe.mass;;#0.007609=eda
                me.eegsMe.vel -= me.eegsMe.deacc * me.averageDt;
                me.eegsMe.speed_down_fps       = -math.sin(me.eegsMe.pitch * D2R) * (me.eegsMe.vel);
                me.eegsMe.speed_horizontal_fps = math.cos(me.eegsMe.pitch * D2R) * (me.eegsMe.vel);
                
                me.eegsMe.speed_down_fps += 9.81 *M2FT *me.averageDt;
                
                
                 
                me.eegsMe.altC -= (me.eegsMe.speed_down_fps*me.averageDt)*FT2M;
                
                me.eegsMe.dist = (me.eegsMe.speed_horizontal_fps*me.averageDt)*FT2M;
                
                me.eegsMe.eegsPos.apply_course_distance(me.eegsMe.hdg, me.eegsMe.dist);
                me.eegsMe.eegsPos.set_alt(me.eegsMe.altC);
                
                me.old = me.gunPos[j];
                me.gunPos[j] = [[geo.Coord.new(me.eegsMe.eegsPos),me.eegsMe.ac, me.eegsMe.pitch]];
                for (var m = 0;m<j+1;m+=1) {
                    append(me.gunPos[j], me.old[m]);
                } 
                
                me.eegsMe.vel = math.sqrt(me.eegsMe.speed_down_fps*me.eegsMe.speed_down_fps+me.eegsMe.speed_horizontal_fps*me.eegsMe.speed_horizontal_fps);
                me.eegsMe.pitch = math.atan2(-me.eegsMe.speed_down_fps,me.eegsMe.speed_horizontal_fps)*R2D;
            }                        
        }
        me.eegsGroup.show();
    },


    isInCanvas:func(x,y){
        #print("x:",x," y:",y," me.MaxX:",me.MaxX," MaxY",me.MaxY, " Result:",abs(x)<me.MaxX and abs(y)<me.MaxY;
        return abs(x)<me.MaxX and abs(y)<me.MaxY;
    },
    
    
    interpolate: func (start, end, fraction) {
        me.xx = (start.x()*(1-fraction)
          +end.x()*fraction);
        me.yy = (start.y()*(1-fraction)+end.y()*fraction);
        me.zz = (start.z()*(1-fraction)+end.z()*fraction);

        me.cc = geo.Coord.new();
        me.cc.set_xyz(me.xx,me.yy,me.zz);

        return me.cc;
    },
    
};

var myHud = nil;

var init = setlistener("/sim/signals/fdm-initialized", func() {
  removelistener(init); # only call once
  myHud = HUD.new({"node": "hud-screen", "texture": "hud_canvas.png"});
  myHud.update();
});

var drag = func (Mach, _cd) { #Check especially as A10 realistically shouldnt exceed m.7
    if (Mach < 0.7)
        return 0.0125 * Mach + _cd;
    elsif (Mach < 1.2)
        return 0.3742 * math.pow(Mach, 2) - 0.252 * Mach + 0.0021 + _cd;
    else
        return 0.2965 * math.pow(Mach, -1.1506) + _cd;
};

var deviation_normdeg = func(our_heading, target_bearing) {
  var dev_norm = target_bearing-our_heading;
    dev_norm=geo.normdeg180(dev_norm);
  return dev_norm;
};


