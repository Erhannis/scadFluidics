include <common.scad>
use <passive_xor.scad>
use <passive_inclusive_or.scad>
use <passive_button.scad>

$fn = 80;

lh = 10;

module 4bit_adder(level) {
  if (level == 0) {
    ventDiam=3*1.3;
    
    for (i = [0:3]) {
      translate([(i-1.5)*35,0,0]) {
        passiveXor(leadOut=0,ventOutLength=7,ventDiam=ventDiam);
        for (ep = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[2]) {
          channel(ep[0],ep[0],d=ventDiam,cap="circle");
        }
      }
    }
    for (m = [0:1]) mirror([m,0])
    translate([1.5*35+20,-40,0]) {
      for (i = [0:3]) {
        translate([0,i*50,0]) {
          passiveButton();
        }
      }
    }
    
    // Xor carries
    for (i = [0:3]) {
      epIn = [-13,15]+passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[2][0][0] + [((3-i)-1.5)*35,0];
      epOut = [-13,0]+passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[1][0][0] + [((3-i)-1.5)*35,0];
      channel(epIn,epOut,d1=ventDiam,d2=3,cap="circle");
    }
    {
      i1 = 0;
      i2 = 2;
      epIn = [-13,0]+passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[1][0][0] + [((3-i1)-1.5)*35,0];
      epOut = [3.5,75]+[(i2-1.5)*35,0,0]+passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[0][1][0];
      channel(epIn,epOut,d=3,cap="circle");
    }
    
    // Second set of Xor
    translate([3.5,75])
    for (i = [0:2]) {
      translate([(i-1.5)*35,0,0]) {
        passiveXor(leadOut=0,ventOutLength=4,ventDiam=ventDiam);
        for (ep = passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[2]) {
          channel(ep[0],ep[0],d=ventDiam,cap="circle");
        }
      }
    }
    translate([-13,110])
    for (i = [0:2]) {
      translate([(i-1.5)*35,0,0]) {
        if (i != 0) {
          passiveInclusiveOr(leadIn=5,ventOutLength=4,ventDiam=ventDiam);
          for (ep = passiveInclusiveOrEndpoints(leadIn=5,ventOutLength=4,ventDiam=ventDiam)[2]) {
            channel(ep[0],ep[0],d=ventDiam,cap="circle");
          }
        } else {
          passiveInclusiveOr(leadIn=5,leadOut=0,ventOutLength=4,ventDiam=ventDiam);
          for (ep = passiveInclusiveOrEndpoints(leadIn=5,leadOut=0,ventOutLength=4,ventDiam=ventDiam)[2]) {
            channel(ep[0],ep[0],d=ventDiam,cap="circle");
          }
        }
      }
      if (i == 0) {
        epIn = [(i-1.5)*35,0]+passiveInclusiveOrEndpoints(leadIn=5,leadOut=0,ventOutLength=4,ventDiam=ventDiam)[1][0][0];
        epY = [3.5,75]+[(i-1.5)*35,0]+[0,50]-[-13,110]+passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[1][0][0];
        epMid = [epIn[0]-10,epY[1]-6];
        epOut = epMid+[0,6];
        channel(epIn,epMid,d=3,cap="circle");
        channel(epMid,epOut,d=3,cap="circle");
      }
    }
    for (i = [0:2]) {
      epIn = [(i-1.5)*35,0]+passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[1][0][0];
      epOut = [3.5,75]+[(i-1.5)*35,0]+passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[0][0][0];
      channel(epIn,epOut,d=3,cap="circle");
    }
    for (i = [1:3]) {
      ep1 = [-13,0]+passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[1][0][0] + [((3-i)-1.5)*35,0];
      ep2 = ep1 + [0,60];
      ep3 = [-13,110]+[((3-i)-1.5)*35,0,0]+passiveInclusiveOrEndpoints(leadIn=5,ventOutLength=4,ventDiam=ventDiam)[0][0][0];
      channel(ep1,ep2,d=3,cap="circle");
      channel(ep2,ep3,d=3,cap="circle");
    }
    for (i = [0:2]) {
      ep1 = [3.5,75]+[(i-1.5)*35,0,0]+[-10,15]+passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[2][0][0];
      ep2 = [-13,110]+[(i-1.5)*35,0,0]+passiveInclusiveOrEndpoints(leadIn=5,ventOutLength=4,ventDiam=ventDiam)[0][1][0];
      channel(ep1,ep2,d1=ventDiam,d2=3,cap="circle");
    }
    
    translate([3.5,75])
    for (i = [0:2]) {
      translate([(i-1.5)*35,0,0]) {
        for (ep = passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[1]) {
          channel(ep[0],ep[0]+[0,50],d=3,cap="circle");
        }
      }
    }
    
    {
      i = 3;      
      translate([(i-1.5)*35,0,0]) {
        epIn = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[1][0][0];
        epY = [3.5,75]+[(i-1.5)*35,0]+[0,50]+passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[1][0][0];
        epOut = [epIn[0],epY[1]];
        channel(epIn,epOut,d=3,cap="circle");
      }
    }
  } else if (level == 1) {
    ventDiam=3*1.3;
    mirror([-1,0])
    for (i = [0:3]) {
      epIn = passiveButtonEndpoints()[1][0][0] + [1.5*35+20,-40] + [0,i*50];
      epOut = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[0][0][0] + [((3-i)-1.5)*35,0];
      shift = (i >= 2) ? 1 : 0;
      epHalf1 = (epIn + epOut)/2 + [-5,0]*shift;
      epHalf2 = epHalf1 + [-10,0]*shift;
      channel(epIn,epHalf1,d=3,cap="circle");
      channel(epHalf1,epHalf2,d=3,cap="circle");
      channel(epHalf2,epOut,d=3,cap="circle");
    }
    
    // Xor carries
    for (i = [0:3]) {
      ep = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[2][0][0] + [((3-i)-1.5)*35,0];
      channel(ep,ep+[-13,15],d=ventDiam,cap="circle");
    }
    
    // Button source
    sourceDiam=3*4;
    channel([0,-90],[0,-70],d=sourceDiam*2);
    channel([-90,-70],[90,-70],d=sourceDiam);
    for (m = [0,-1]) mirror([m,0]) {
      channel([-90,-70]+[sourceDiam/2,0],[-90,100]+[sourceDiam/2,0],d=sourceDiam);
      mirror([-1,0])
      for (i = [0:3]) {
        ep = passiveButtonEndpoints()[0][0][0] + [1.5*35+20,-40] + [0,i*50];
        channel(ep+[sourceDiam,0],ep,d=3,cap="circle");
      }
    }
    
    // Second xor carries
    for (i = [0:2]) {
      ep = [3.5,75]+[(i-1.5)*35,0,0]+passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[2][0][0];
      channel(ep,ep+[-10,15],d=ventDiam,cap="circle");
    }
  } else if (level == 2) {
    ventDiam=3*1.3;
    for (i = [0:3]) {
      epIn = passiveButtonEndpoints()[1][0][0] + [1.5*35+20,-40] + [0,i*50];
      epOut = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[0][0][0] + [((3-i)-1.5)*35,0];
      shift = (i >= 3) ? 1 : 0;
      epHalf1 = (epIn + epOut)/2 + [-5,0]*shift;
      epHalf2 = epHalf1 + [-10,0]*shift;
      channel(epIn,epHalf1,d=3,cap="circle");
      channel(epHalf1,epHalf2,d=3,cap="circle");
      channel(epHalf2,epOut,d=3,cap="circle");
    }
  } else if (level == 3) {
    ventDiam=3*1.3;
    
    for (i = [1:2]) {
      epIn = [-13,110]+[(i-1.5)*35,0,0] + passiveInclusiveOrEndpoints(leadIn=5,ventOutLength=4,ventDiam=ventDiam)[1][0][0];
      epOut = [3.5,75]+[((i-1)-1.5)*35,0,0] + passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[0][1][0];
      channel(epIn,epOut,d=3,cap="circle");
    }
  }
}

module rcolor(seed, auxSeed=1000) {
  if (auxSeed == undef) {
    r = rands(0.5,1,3,seed+auxSeed);
    color([r[0],r[1],r[2]]) {
      children();
    }
  } else {
    r = rands(0.5,1,3,seed);
    color([r[0],r[1],r[2]]) {
      children();
    }
  }
}

module outline(w=1) {
  difference() {
    minkowski() {
      children();
      cylinder(d=w*2,h=w*2);
    }
    children();
  }
}

module encube(bounds, w=1) {
  difference() {
    union() {
      difference() {
        translate([bounds[0],bounds[3],bounds[4]]) cube([bounds[1]-bounds[0],bounds[2]-bounds[3],bounds[4]-bounds[5]]);
        ws = w*6;
        fs = w*2;
        translate([bounds[0]+ws,bounds[3]+ws,bounds[4]+fs]) cube([bounds[1]-bounds[0]-ws*2,bounds[2]-bounds[3]-ws*2,bounds[4]-bounds[5]-fs]);
      }
      intersection() {
        minkowski() {
          intersection() {
            children();
            translate([bounds[0],bounds[3],bounds[4]]) cube([bounds[1]-bounds[0],bounds[2]-bounds[3],bounds[4]-bounds[5]]);
          }
          cylinder(d=w*2,h=w*2,center=true);
        }
        translate([bounds[0],bounds[3],bounds[4]]) cube([bounds[1]-bounds[0],bounds[2]-bounds[3],bounds[4]-bounds[5]]);
      }
    }
    children();
  }
}

chosenLevel = 0;
bounds = [-92.5,92.5,155,-90,(chosenLevel+1)*lh-lh*0.25,chosenLevel*lh-lh*0.25];
encube(bounds) {
//  translate([bounds[0],bounds[3],chosenLevel*lh-lh*0.25])
//    cube([bounds[1]-bounds[0],bounds[2]-bounds[3],10]);
  screwSize = 3/0.8; // Prescaled for later scaling
  inset = screwSize*1.5;
  translate([bounds[0]+inset,bounds[2]-inset,0])
    cylinder(d=screwSize,h=$FOREVER,center=true);
  translate([bounds[1]-inset,bounds[2]-inset,0])
    cylinder(d=screwSize,h=$FOREVER,center=true);
  translate([bounds[0]+inset,bounds[3]+inset,0])
    cylinder(d=screwSize,h=$FOREVER,center=true);
  translate([bounds[1]-inset,bounds[3]+inset,0])
    cylinder(d=screwSize,h=$FOREVER,center=true);
  //for (level = [chosenLevel-1:chosenLevel]) {
  for (level = [-1:3]) {
    rcolor(level)
    translate([0,0,level*lh]) {
      {
        flat3d($EPS=lh*0.75) {
          4bit_adder(level=level);
        }
      }
    }
    rcolor(level)
    { // Level joins
      translate([0,0,level*lh])
      linear_extrude(height=lh) {
        if (level == -1) {
          // Bottom vents
          ventDiam=3*1.3;
          for (i = [0:3]) {
            translate([(i-1.5)*35,0,0]) {
              eps = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[2];
              translate(eps[1][0])
                circle(d=ventDiam);
              translate(eps[2][0])
                circle(d=ventDiam);
            }
          }
          translate([3.5,75])
          for (i = [0:2]) {
            translate([(i-1.5)*35,0,0]) {
              eps = passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[2];
              translate(eps[1][0])
                circle(d=ventDiam);
              translate(eps[2][0])
                circle(d=ventDiam);
            }
          }
          translate([-13,110])
          for (i = [0:2]) {
            translate([(i-1.5)*35,0,0]) {
              for (ep = passiveInclusiveOrEndpoints(leadIn=5,ventOutLength=4,ventDiam=ventDiam)[2]) {
                channel(ep[0],ep[0],d=ventDiam,cap="circle");
              }
            }
          }

          // Button vents
          for (m = [0,-1]) mirror([m,0]) {
            for (i = [0:3]) {
              ep = passiveButtonEndpoints()[1][0][0] + [1.5*35+20,-40] + [0,i*50];
              translate(ep)
                circle(d=3);
            }
          }
        } else if (level == 0) {
          // Button source
          sourceDiam=3*4;
          for (m = [0,-1]) mirror([m,0]) {
            for (i = [0:3]) {
              ep = passiveButtonEndpoints()[0][0][0] + [1.5*35+20,-40] + [0,i*50];
              translate(ep)
                circle(d=3);
              
              //channel(ep+[sourceDiam,0],ep,d=3,cap="circle");
            }
          }
          
          // First XOR set
          ventDiam=3*1.3;
          mirror([-1,0])
          for (i = [0:3]) {
            epIn = passiveButtonEndpoints()[1][0][0] + [1.5*35+20,-40] + [0,i*50];
            epOut = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[0][0][0] + [((3-i)-1.5)*35,0];
            translate(epIn)
              circle(d=3);
            translate(epOut)
              circle(d=3);
          }

          for (i = [0:3]) {
            epIn = passiveButtonEndpoints()[1][0][0] + [1.5*35+20,-40] + [0,i*50];
            epOut = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[0][0][0] + [((3-i)-1.5)*35,0];
            translate(epIn)
              circle(d=3);
            translate(epOut)
              circle(d=3);
          }

          // Xor carries
          for (i = [0:3]) {
            epIn = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[2][0][0] + [((3-i)-1.5)*35,0];
            epOut = epIn+[-13,15];
            translate(epIn)
              circle(d=ventDiam);
            translate(epOut)
              circle(d=ventDiam);
          }  
    
          // Second xor carries
          for (i = [0:2]) {
            epIn = [3.5,75]+[(i-1.5)*35,0,0]+passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[2][0][0];
            epOut = epIn+[-10,15];
            translate(epIn)
              circle(d=ventDiam);
            translate(epOut)
              circle(d=ventDiam);
          }  

          for (i = [1:2]) { // Level 3->0 connections
            epIn = [-13,110]+[(i-1.5)*35,0,0] + passiveInclusiveOrEndpoints(leadIn=5,ventOutLength=4,ventDiam=ventDiam)[1][0][0];
            epOut = [3.5,75]+[((i-1)-1.5)*35,0,0] + passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[0][1][0];
            translate(epIn)
              circle(d=3);
            translate(epOut)
              circle(d=3);
          }
        } else if (level == 1) {
          ventDiam=3*1.3;
          for (i = [0:3]) {
            epIn = passiveButtonEndpoints()[1][0][0] + [1.5*35+20,-40] + [0,i*50];
            epOut = passiveXorEndpoints(leadOut=0,ventOutLength=7,ventDiam=ventDiam)[0][0][0] + [((3-i)-1.5)*35,0];
            translate(epIn)
              circle(d=3);
            translate(epOut)
              circle(d=3);
          }

          for (i = [1:2]) { // Level 3->0 connections
            epIn = [-13,110]+[(i-1.5)*35,0,0] + passiveInclusiveOrEndpoints(leadIn=5,ventOutLength=4,ventDiam=ventDiam)[1][0][0];
            epOut = [3.5,75]+[((i-1)-1.5)*35,0,0] + passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[0][1][0];
            translate(epIn)
              circle(d=3);
            translate(epOut)
              circle(d=3);
          }
        } else if (level == 2) {
          ventDiam=3*1.3;
          
          for (i = [1:2]) { // Level 3->0 connections
            epIn = [-13,110]+[(i-1.5)*35,0,0] + passiveInclusiveOrEndpoints(leadIn=5,ventOutLength=4,ventDiam=ventDiam)[1][0][0];
            epOut = [3.5,75]+[((i-1)-1.5)*35,0,0] + passiveXorEndpoints(leadOut=0,ventOutLength=4,ventDiam=ventDiam)[0][1][0];
            translate(epIn)
              circle(d=3);
            translate(epOut)
              circle(d=3);
          }
        }
      }
    }
  }
}