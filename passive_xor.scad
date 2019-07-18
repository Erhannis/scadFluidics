include <common.scad>
use <passive_inclusive_or.scad>

// See common.scad for explanation of endpoints
function passiveXorEndpoints(
    channelDiam = 3,
    leadIn = 5,
    leadOut = 10,
    size = 1.5,
    ventDiam = undef,
    ventOutLength = 25
  ) = [
  [[[-(size*7),-leadIn-35],[0,-1],channelDiam],
   [[(size*7),-leadIn-35],[0,-1],channelDiam]], // Ins
  passiveInclusiveOrEndpoints(channelDiam=channelDiam,leadIn=5,leadOut=leadOut,size=size,ventDiam=ventDiam)[1], // Outs
  concat([[[0,-35+2*(size*7)*1.5+narrowsLength(d1=channelDiam*1.3,d2=(ventDiam != undef ? ventDiam : channelDiam*1.3))+0],0,(ventDiam != undef ? ventDiam : channelDiam*1.3)]],passiveInclusiveOrEndpoints(channelDiam=channelDiam,leadIn=5,leadOut=leadOut,size=size,ventDiam=ventDiam)[2]), // Vents
  ];

/*
// See common.scad for explanation of bounds
function passiveButtonBounds(
    channelDiam = 3,
    leadIn = 5,
    leadOut = 10,
    size = 1.5,
    ventDiam = undef,
    ventOutLength = 25
  ) = [-channelDiam/2,sideOut,leadOut,-leadIn]; // Left, right, top, bottom
*/

module passiveXorSub1(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 10,
    size = 1.5,
    ventDiam = undef,
    ventOutLength = 25
  ) {
    if (ventDiam == undef) {
      passiveXorSub1(channelDiam, leadIn, leadOut, size, ventDiam=channelDiam*1.3, ventOutLength=ventOutLength);
    } else {
      xOffset = size*7;
      
      cap = undef;

      // Inputs
      channel([-xOffset,-leadIn],[-xOffset,0],d=channelDiam,cap=cap);
      channel(from=[-xOffset,0],to=[0,xOffset*1.5],dir1=[0,1],dir2=[-1,-0.5],d=channelDiam,cap=undef);
      channel([xOffset,-leadIn],[xOffset,0],d=channelDiam,cap=cap);
      channel(from=[xOffset,0],to=[0,xOffset*1.5],dir1=[0,1],dir2=[1,-0.5],d=channelDiam,cap=undef);

      // To OR
      channel([0,xOffset*1.5], [size*5,30], dir1=[1,1], dir2=[0,-1], d=channelDiam);
      channel([0,xOffset*1.5], [-size*5,30], dir1=[-1,1], dir2=[0,-1], d=channelDiam);

      // Vent
      channel([0,xOffset*1.5+channelDiam/2], [0,2*xOffset*1.5], d=channelDiam*1.3);
      translate([0,2*xOffset*1.5])
        narrows(d1=channelDiam*1.3,d2=ventDiam);
      channel([0,2*xOffset*1.5+narrowsLength(d1=channelDiam*1.3,d2=ventDiam)],[0,2*xOffset*1.5+narrowsLength(d1=channelDiam*1.3,d2=ventDiam)+leadOut],d=ventDiam,cap="circle");
    }
}

module passiveXor(
    channelDiam = 3,
    leadIn = 5,
    leadOut = 10,
    size = 1.5, //TODO Unstable
    ventDiam = undef, //TODO A little unstable
    ventOutLength = 25
  ) {
    translate([0,-35])
      passiveXorSub1(channelDiam=channelDiam,leadIn=leadIn,leadOut=0,size=size,ventDiam=ventDiam);
    passiveInclusiveOr(channelDiam=channelDiam,leadIn=5,leadOut=leadOut,size=size,ventDiam=ventDiam);
}


union() {
  sx=45;
  sy=80;
  oy=-40;
  screw_inset = 3;
  cover_screw_slop = 0.5;
  rescale = 0.5;
  ventDiam = 5;

  translate([0,0,0])
  difference() { // Body
    scale(rescale) {
      difference() {
        translate([-sx/2,oy, -3])
          cube([sx, sy, 10]);
        translate(passiveXorEndpoints(ventDiam=ventDiam)[2][0][0])
          cylinder(d=ventDiam, h=$FOREVER, center=true);
      }
    }
    scale(rescale)
      linear_extrude(height=$FOREVER)
      passiveXor(ventDiam=ventDiam);
    
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