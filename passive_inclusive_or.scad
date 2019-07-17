include <common.scad>

// See common.scad for explanation of endpoints
function passiveInclusiveOrEndpoints(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 10,
    size = 1.5,
    ventDiam = undef,
    ventOutLength = 15
  ) = [
  [[[-(size*5),-leadIn],[0,-1],channelDiam], // Ins
   [[(size*5),-leadIn],[0,-1],channelDiam]],
  [[[0,(size*5)*4+leadOut],[0,1],channelDiam]], // Outs
  [[[-ventOutLength-(size*5),channelDiam/2],[-1,0],ventDiam != undef ? ventDiam : channelDiam], // Vents
   [[ventOutLength+(size*5),channelDiam/2],[1,0],ventDiam != undef ? ventDiam : channelDiam]],
  ];

// See common.scad for explanation of bounds
function passiveInclusiveOrBounds(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 10,
    size = 1.5,
    ventDiam = undef,
    ventOutLength = 15
  ) = [-ventOutLength-(size*5),ventOutLength+(size*5),(size*5)*4+leadOut,-leadIn]; // Left, right, top, bottom

module passiveInclusiveOr(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 10,
    size = 1.5,
    ventDiam = undef,
    ventOutLength = 15
  ) {
    if (ventDiam == undef) {
      passiveInclusiveOr(channelDiam, leadIn, leadOut, size, ventDiam=channelDiam, ventOutLength=ventOutLength);
    } else {
      xOffset = size*5;
      
      cap = undef;
      
      // Inputs
      channel([-xOffset,-leadIn],[-xOffset,0],d=channelDiam,cap=cap);
      channel([xOffset,-leadIn],[xOffset,0],d=channelDiam,cap=cap);
      
      // Vents
      channel([-ventOutLength-xOffset,channelDiam/2],[-xOffset+channelDiam/2,channelDiam/2],d=ventDiam,cap=cap);
      channel([ventOutLength+xOffset,channelDiam/2],[xOffset-channelDiam/2,channelDiam/2],d=ventDiam,cap=cap);
      
      // Joiners
      slantOffset = channelDiam/2;
      channel([-xOffset-slantOffset,channelDiam/2-slantOffset],[0,xOffset*1.5],d=channelDiam*2,cap=cap);
      channel([xOffset+slantOffset,channelDiam/2-slantOffset],[0,xOffset*1.5],d=channelDiam*2,cap=cap);
      
      // Output
      channel([0,xOffset*1.5],[0,xOffset*4],d1=channelDiam*2,d2=channelDiam);
      channel([0,xOffset*4],[0,xOffset*4+leadOut],d=channelDiam);
    }
}



{
  sx=45;
  sy=60;
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
      linear_extrude(height=$FOREVER)
      passiveInclusiveOr();
   
    for (o=[[-1,1],[1,1],[-1,-1],[1,-1]]) {
      r=rescale;
      translate([o[0]*(r*sx/2-screw_inset),o[1]*(r*sy/2-screw_inset) + r*sy/2 + r*oy,0])
        cylinder(d=3, h=$FOREVER, center=true);
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
        cylinder(d=3, h=$FOREVER, center=true);
    }
  }
}

//passiveInclusiveOr();