use <common.scad>

$fn = 60;

// See common.scad for explanation of endpoints
function passiveButtonEndpoints(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 20,
    sideOut = 20
  ) = [
  [[[0,-leadIn],[0,-1],channelDiam]], // Ins
  [[[0,leadIn],[0,1],channelDiam]], // Outs
  [[[sideOut,0],[1,0],channelDiam]], // Vents
  ];

// See common.scad for explanation of bounds
function passiveButtonBounds(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 20,
    sideOut = 20
  ) = [-channelDiam/2,sideOut,leadOut,-leadIn]; // Left, right, top, bottom

module passiveButton(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 20,
    sideOut = 20
  ) {
    channel([0,-leadIn],[sideOut,0],dir1=[0,1],dir2=[-1,0],d=channelDiam);
    channel([sideOut,0],[0,leadIn],dir1=[-1,0],dir2=[0,-1],d=channelDiam);
    
    /*
    channel([inputLengths,channelDiam/2],[0,channelDiam/2],d=channelDiam);
    
    channel([0,ventAreaLength-ventDiam/2],[ventOutLength,ventAreaLength-ventDiam/2],d=ventDiam);
    
    channel([-ventDiam/2,ventAreaLength-ventDiam/2],
            [-ventDiam/2-ventAreaWidth+ventDiam,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],d=ventDiam,cap="circle");
    channel([-ventDiam/2-ventAreaWidth+ventDiam,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],
            [-ventOutLength,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],d=ventDiam,cap="circle");
    
    channel([-ventAreaWidth/2,channelDiam/2],[-ventAreaWidth/2,ventAreaLength],d=ventAreaWidth);
    */
}


{
  sx=40;
  sy=40;
  oy=-20;
  screw_inset = 3;
  cover_screw_slop = 0.5;
  rescale = 1;

  translate([0,0,0])
  difference() { // Body
    scale(rescale)
      translate([-sx/2,oy, -3])
      cube([sx, sy, 10]);
    scale(rescale)
      linear_extrude(height=$FOREVER)
      passiveButton();
    
    for (o=[[-1,1],[1,1],[-1,-1],[1,-1]]) {
      r=rescale;
      translate([o[0]*(r*sx/2-screw_inset),o[1]*(r*sy/2-screw_inset) + r*sy/2 + r*oy,0])
        cylinder(d=3, h=$FOREVER, center=true);
    }
  }
  
  translate([rescale*sx*1.5, 0, 0])
  difference() { // Cover
    scale(rescale)
      translate([-sx/2,oy, -3])
      cube([sx, sy, 4]);
    for (o=[[-1,1],[1,1],[-1,-1],[1,-1]]) {
      r=rescale;
      translate([o[0]*(r*sx/2-screw_inset),o[1]*(r*sy/2-screw_inset) + r*sy/2 + r*oy,0])
        cylinder(d=3, h=$FOREVER, center=true);
    }
  }
}

//deflectionInverter();