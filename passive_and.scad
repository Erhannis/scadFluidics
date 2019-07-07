use <common.scad>

FOREVER = 1000;
$fn = 60;

module passiveAnd(
    channelDiam = 3,
    leadIn = 20,
    leadOut = 10,
    size = 1.5,
    ventDiam = undef,
    ventOutLength = 25
  ) {
    if (ventDiam == undef) {
      passiveAnd(channelDiam, leadIn, leadOut, size, ventDiam=channelDiam, ventOutLength=ventOutLength);
    } else {
      xOffset = size*7;
      
      cap = undef;
      
      // Inputs
      channel([-xOffset,-leadIn],[-xOffset,0],d=channelDiam,cap=cap);
      channel(from=[-xOffset,0],to=[0,xOffset*1.5],dir1=[0,1],dir2=[-1,-1],d=channelDiam,cap=undef);
      channel([xOffset,-leadIn],[xOffset,0],d=channelDiam,cap=cap);
      channel(from=[xOffset,0],to=[0,xOffset*1.5],dir1=[0,1],dir2=[1,-1],d=channelDiam,cap=undef);

      // Vents
      //TODO No use for ventDiam yet
      channel([0,xOffset*1.5], [ventOutLength,20], dir1=[1,1], dir2=[-1,0], d=channelDiam);
      channel([0,xOffset*1.5], [-ventOutLength,20], dir1=[-1,1], dir2=[1,0], d=channelDiam);

      // Output
      channel([0,xOffset*1.5+channelDiam/2], [0,2*xOffset*1.5], d=channelDiam);
      translate([0,2*xOffset*1.5])
        narrows(d1=channelDiam,d2=channelDiam);
      channel([0,2*xOffset*1.5+narrowsLength(d1=channelDiam,d2=channelDiam)],[0,2*xOffset*1.5+narrowsLength(d1=channelDiam*2,d2=channelDiam)+leadOut],d=channelDiam);
      
/*      
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
      
      
      */
      
      /*
      channel([0,xOffset*1.5],[0,xOffset*3],d=channelDiam*2);
      translate([0,xOffset*3])
        narrows(channelDiam*2,channelDiam);
      channel([0,xOffset*3+narrowsLength(channelDiam*2,channelDiam)],[0,xOffset*3+narrowsLength(channelDiam*2,channelDiam)+leadOut],d=channelDiam);
      */
      
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
      linear_extrude(height=FOREVER)
      passiveAnd();
    
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


//passiveAnd();