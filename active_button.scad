use <common.scad>

FOREVER = 1000;
$fn = 60;

//TODO Doesn't work, yet.
module activeButton(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 20,
    size = 1.5,
    inputLengths = 25,
    ventDiam = undef,
    ventOutLength = 25,
    ventAreaWidth = 10,
    ventAreaLength = 40
  ) {
    if (ventDiam == undef) {
      activeButton(channelDiam, leadIn, leadOut, size, inputLengths, ventDiam=channelDiam*2, ventOutLength=ventOutLength, ventAreaWidth=ventAreaWidth, ventAreaLength=ventAreaLength);
    } else {
      channel([0,-leadIn],[0,ventAreaLength+leadOut],d=channelDiam);
      
      channel([inputLengths,channelDiam/2],[0,channelDiam/2],d=channelDiam);
      
      channel([0,ventAreaLength-ventDiam/2],[ventOutLength,ventAreaLength-ventDiam/2],d=ventDiam);
      
      channel([-ventDiam/2,ventAreaLength-ventDiam/2],
              [-ventDiam/2-ventAreaWidth+ventDiam,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],d=ventDiam,cap="circle");
      channel([-ventDiam/2-ventAreaWidth+ventDiam,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],
              [-ventOutLength,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],d=ventDiam,cap="circle");
      
      channel([-ventAreaWidth/2,channelDiam/2],[-ventAreaWidth/2,ventAreaLength],d=ventAreaWidth);
      
      * channel([-ventAreaWidth+ventDiam/2,0],[-ventOutLength,0],d=ventDiam,cap="circle");
    }
}


{
  sx=50;
  sy=80;
  oy=-20;
  screw_inset = 3;
  cover_screw_slop = 0.5;
  rescale = 0.5;

  translate([0,0,0])
  difference() { // Body
    scale(rescale)
      translate([-sx/2,oy, -3])
      cube([sx, sy, 10]);
    scale(rescale)
      linear_extrude(height=FOREVER)
      activeButton();
    
    for (o=[[-1,1],[1,1],[-1,-1],[1,-1]]) {
      r=rescale;
      translate([o[0]*(r*sx/2-screw_inset),o[1]*(r*sy/2-screw_inset) + r*sy/2 + r*oy,0])
        cylinder(d=3, h=FOREVER, center=true);
    }
  }
  
  translate([sx*0.6, 0, 0])
  difference() { // Cover
    scale(rescale)
      translate([-sx/2,oy, -3])
      cube([sx, sy, 4]);
    for (o=[[-1,1],[1,1],[-1,-1],[1,-1]]) {
      r=rescale;
      translate([o[0]*(r*sx/2-screw_inset),o[1]*(r*sy/2-screw_inset) + r*sy/2 + r*oy,0])
        cylinder(d=3, h=FOREVER, center=true);
    }
  }
}


//deflectionInverter();