use <common.scad>

FOREVER = 1000;
$fn = 60;

module deflectionInverter(
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
      deflectionInverter(channelDiam, leadIn, leadOut, size, inputLengths, ventDiam=channelDiam*2, ventOutLength=ventOutLength, ventAreaWidth=ventAreaWidth, ventAreaLength=ventAreaLength);
    } else {
      channel([0,-leadIn],[0,ventAreaLength+leadOut],d=channelDiam);
      
      channel([inputLengths,channelDiam/2],[0,channelDiam/2],d=channelDiam);
      
      channel([0,ventAreaLength-ventDiam/2],[ventOutLength,ventAreaLength-ventDiam/2],d=ventDiam);
      
      channel([-ventDiam/2,ventAreaLength-ventDiam/2],
              [-ventDiam/2-ventAreaWidth+ventDiam,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],d=ventDiam,cap="circle");
      channel([-ventDiam/2-ventAreaWidth+ventDiam,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],
              [-ventOutLength,ventAreaLength-ventDiam/2+ventAreaWidth-ventDiam],d=ventDiam,cap="circle");
      
      channel([-ventAreaWidth/2,0],[-ventAreaWidth/2,ventAreaLength],d=ventAreaWidth);
      
      channel([-ventAreaWidth+ventDiam/2,0],[-ventOutLength,0],d=ventDiam,cap="circle");
      
      /*
      d1 = channelDiam;
      d2 = size*channelDiam*5;
      h = size*channelDiam*7;
      { // Inputs
        channel([0,-leadIn],[0,0],d=channelDiam);
        channel([-sideLengths, -channelDiam/2], [sideLengths, -channelDiam/2], d=channelDiam);
      }
      { // Vents
        //TODO Should the mouth be slightly wider?
        channel([0,0],[0,h],d1=d1,d2=d2);
        
        contact_x = d1/2 + (h-ventDiam/2)*((d2/2-d1/2)/h);
        channel([-ventReach,h-ventDiam/4],[ventReach,h-ventDiam/4],d=ventDiam/2);
        channel([-contact_x-ventDiam/2, h-ventDiam/2], [-ventReach,h-ventDiam/2], d=ventDiam, cap="circle");
        channel([contact_x+ventDiam/2, h-ventDiam/2], [ventReach,h-ventDiam/2], d=ventDiam, cap="circle");
      }
      { // Outputs
        output_diam = 2.75*channelDiam;
        output_length = 4*channelDiam;
        output_safety_inset = channelDiam;
        angle = atan2(h, d2/2-d1/2)-90;
        for (i=[-1,1]) {
          translate([i*d1/2,0])
            rotate([0,0,i*angle])
            translate([-i*output_diam/2,0])
            union() {
              channel([0,h-output_safety_inset],[0,h-output_safety_inset+output_length],d=output_diam);
              translate([0, h-output_safety_inset+output_length])
                narrows(d1=output_diam, d2=channelDiam);
              channel([0, h-output_safety_inset+output_length], [0, h-output_safety_inset+output_length+narrowsLength(d1=output_diam, d2=channelDiam)+2*channelDiam],d=channelDiam);
            }
        }
      }
      */
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
      deflectionInverter();
    
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