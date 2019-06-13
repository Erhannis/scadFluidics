$fn = 100;

function narrowsLength(d1=10, d2=5) = 2*((max(d1, d2)-min(d1, d2))/(4*(1-(1/sqrt(2)))))/sqrt(2);

module narrows(d1=10, d2=5, doMirror=0) {
  if (d2 > d1) {
    narrows(d2, d1, 1);
  } else {
    r = (d1-d2)/(4*(1-(1/sqrt(2))));
    yoff = -r*sqrt(2);
    division = -r/sqrt(2);
    ss = d1+d2+r;

    mirror([0,doMirror,0]) {
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

module bistableSwitch() {
  
}

//linear_extrude(height=1, center=true) {
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
//}