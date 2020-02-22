FOREVER = 1000;
$fn = 100;

function narrowsLength(d1=10, d2=5) = 2*((max(d1, d2)-min(d1, d2))/(4*(1-(1/sqrt(2)))))/sqrt(2);

module narrows(d1=10, d2=5, doMirror=0, center=false) {
  if (d2 > d1) {
    narrows(d2, d1, 1, center);
  } else {
    r = (d1-d2)/(4*(1-(1/sqrt(2))));
    yoff = -r*sqrt(2);
    division = -r/sqrt(2);
    ss = d1+d2+r;

    translate([0, center ? 0 : narrowsLength(d1, d2)/2])
    mirror([0,doMirror]) {
      translate([0,-division]) {
        difference() {
          union() {
            difference() {
              translate([-d1/2, -d1])
                square([d1, d1]);
              translate([0,-ss/2+division])
                square(ss, center=true);
            }
            translate([-d2/2, -d1])
              square([d2, d1]);
            union() {
              translate([r-d1/2,yoff])
                difference() {
                  circle(r=r);
                  translate([r,0])
                    square(2*r, center=true);
                }
              translate([d1/2-r,yoff])
                difference() {
                  circle(r=r);
                  translate([-r,0])
                    square(2*r, center=true);
                }
            }
          }
          union() {
            translate([r-d1/2-(r*sqrt(2)),yoff+(r*sqrt(2))])
              circle(r=r);
            translate([d1/2-r+(r*sqrt(2)),yoff+(r*sqrt(2))])
              circle(r=r);
          }
          translate([0,-ss/2+2*division])
            square(ss, center=true);
        }
      }
    }
  }
}

/**
//TODO Also accepts d2
*/
module channel(from=[5,0], to=[10,-10], d=1, d1=undef, d2=undef, cap="none") {
  if (d1 == undef) {
    channel(from=from, to=to, d=d, d1=d, d2=d2, cap=cap);
  } else if (d2 == undef) {
    channel(from=from, to=to, d=d, d2=d, cap=cap);
  } else {
    length = norm(to-from);
    translate(from)
      rotate([0,0,atan2(to[1]-from[1],to[0]-from[0])-90])
      union() {
        polygon([[-d1/2,0],[d1/2,0],[d2/2,length],[-d2/2,length]], paths=[[0,1,2,3]]);
        if (cap == "circle") {
          //TODO Consider shifting circles so that the angles line up nicely.
          // Cons: that'd make predicting the true length of the line difficult.
          // You could change how the *walls* angled, but that'd make the walls a little unpredictable.
          difference() {
            circle(d=d1);
            translate([0,d1/2])
              square(d1,center=true);
          }
          translate([0,length])
            difference() {
              circle(d=d2);
              translate([0,-d2/2])
                square(d2,center=true);
            }
        } else if (cap == "square") { //TODO Not sure abt when d2 != d1
          translate(from)
            rotate([0,0,atan2(to[1]-from[1],to[0]-from[0])-90])
            union() {
              square(d1, center=true);
              translate([0, norm(to-from)])
                square(d2, center=true);
            }
        } else { // "none"
        }
      }
  }
}

module bistableSwitch(
    channelDiam = 3,
    leadIn = 20,
    size = 1.5,
    sideLengths = 25,
    ventDiam = undef,
    ventReach = 40
  ) {
    if (ventDiam == undef) {
      bistableSwitch(channelDiam, leadIn, size, sideLengths, ventDiam=channelDiam*4, ventReach=ventReach);
    } else {
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
    }
}

/*
union() {
  d1=10;
  d2=2;
  l = 50;
  narrows(d1, d2);
  
  translate([0,-l/2-narrowsLength(d1, d2)/2])
    square([d1, l], center=true);
  translate([0,l/2+narrowsLength(d1, d2)/2])
    square([d2, l], center=true);
  
}
*/

//channel([0,0],[10,0], cap="circle");
//channel([10,0],[0,10], cap="circle");
//channel([0,10],[0,0], cap="circle");

{
  sx=80;
  sy=80;
  oy=-20;
  screw_inset = 4;
  cover_screw_slop = 0.5;

  channelDiam = 3;
  sideLengths = 35;
  ventReach = 26;

  difference() { // Body
    translate([-sx/2,oy, -3])
      cube([sx, sy, 10]);
    linear_extrude(height=FOREVER)
      union() {
        bistableSwitch(channelDiam=channelDiam, sideLengths=sideLengths, ventReach=ventReach);
        
        for (i=[0,1]) {
          mirror([i,0,0]) {
            channel([-sideLengths,-channelDiam/2],[-sideLengths, 50], d=channelDiam, cap="circle");
            channel([-sideLengths, 50],[-13.25, 52], d=channelDiam, cap="circle");
          }
        }
      }
    for (i=[0,1])
      mirror([i,0,0])
      translate([ventReach,25.5,0])
      cylinder(d=channelDiam*4, h=FOREVER, center=true);
    for (o=[[-1,1],[1,1],[-1,-1],[1,-1]]) {
      translate([o[0]*(sx/2-screw_inset),o[1]*(sy/2-screw_inset) + sy/2 + oy,0])
        cylinder(d=3, h=FOREVER, center=true);
    }
  }
  
  translate([sx*1.1, 0, 0])
  difference() { // Cover
    translate([-sx/2,oy, -3])
      cube([sx, sy, 4]);
    for (o=[[-1,1],[1,1],[-1,-1],[1,-1]]) {
      translate([o[0]*(sx/2-screw_inset),o[1]*(sy/2-screw_inset) + sy/2 + oy,0])
        cylinder(d=3+cover_screw_slop, h=FOREVER, center=true);
    }
  }
}