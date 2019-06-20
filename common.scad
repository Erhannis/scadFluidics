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

function mod(x, n) = (x % n + n) % n;
// Caution: I suspect interpolateRotate can freeze openscad when, say, certain variables are undefined.
function interpolateRotate(x, y, a, dir=1, g=undef) = (g == undef) ? interpolateRotate(x, y, a, g=-dir*mod(dir*(atan2(x[1],x[0])-atan2(y[1],y[0])),360)) : [[cos(a*g), -sin(a*g)],[sin(a*g),  cos(a*g)]]*x;
function clamp(a, v, b) = max(a,min(b,v));
function rot(x, g) = [[cos(g), -sin(g)],[sin(g),  cos(g)]]*x;
//function interpolateRotate(x, y, a, g=undef) = (g == undef) ? interpolateRotate(x, y, a, g=angle(x,y)*sign(angle(rot(y,angle(x,y)),x)-angle(rot(x,angle(x,y)),y))) : [[cos(a*g), -sin(a*g)],[sin(a*g),  cos(a*g)]]*x;
function segments(r) = ($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5)));
function angle(a, b) = acos(clamp(-1,(a*b)/(norm(a)*norm(b)),1));
function perpendicular(v) = [v[1], -v[0]];
function normalize(v) = v/norm(v);
function isParallel(from=[5,0], to=[0,5], dir1=[0,1], dir2=[1,0]) = ((dir1[1]*dir2[0]-dir2[1]*dir1[0]) == 0);
function getCrossing(from=[5,0], to=[0,5], dir1=[0,1], dir2=[1,0]) = dir1*((dir2[1]*from[0]-dir2[1]*to[0]+dir2[0]*to[1]-from[1]*dir2[0])/(dir1[1]*dir2[0]-dir2[1]*dir1[0]))+from;

/**
dir: 1=cw, -1=ccw
*/
module arc(from=[5,0], to=[0,5], center=[0,0], r=undef, dir=1) {
  if (r == undef) {
    arc(from, to, center, norm(from-center), dir);
  } else {
    ss = segments(r); //TODO Probably ought to be divided by size of arc

    points = [center,
        for(a = [0:1/ss:1]) interpolateRotate(r*normalize(from-center), r*normalize(to-center), a, dir)+center,
        r*normalize(to-center)+center
    ];
    polygon(points);
  }
}

/**
dir1, dir2 give vectors for direction from and to, respectively.  Only works if both are defined.
If dir1 and dir2, then r can also be applied, which gives the radius of the turn.  If undefined, r defaults to the largest r that can fit.

*/
module channel(from=[5,0], to=[10,-10], dir1=undef, dir2=undef, r=undef, d=1, d1=undef, d2=undef, cap="none") {
  if (d1 == undef) {
    channel(from=from, to=to, dir1=dir1, dir2=dir2, r=r, d=d, d1=d, d2=d2, cap=cap);
  } else if (d2 == undef) {
    channel(from=from, to=to, dir1=dir1, dir2=dir2, r=r, d=d, d1=d1, d2=d, cap=cap);
  } else if (dir1 != undef && dir2 != undef) {
    if (r == undef) {
      if (isParallel(from=from, to=to, dir1=dir1, dir2=dir2)) {
        echo("TODO: Deal with parallel channels");
        //radius = ;
        //channel(from=from, to=to, dir1=dir1, dir2=dir2, r=radius, d=d, d1=d1, d2=d2, cap=cap);
      } else {
        crossing = getCrossing(from=from, to=to, dir1=dir1, dir2=dir2);
        dist1 = norm(crossing-from)*(angle(dir1, crossing-from) > 90 ? -1 : 1);
        dist2 = norm(crossing-to)*(angle(dir2, crossing-to) > 90 ? -1 : 1);
        radius = min(dist1, dist2);
        channel(from=from, to=to, dir1=dir1, dir2=dir2, r=radius, d=d, d1=d1, d2=d2, cap=cap);
      }
    } else {
      // We have dist1, dist2, and r
      //TODO What's with the glitch at *nearly* parallel?
      crossing = getCrossing(from=from, to=to, dir1=dir1, dir2=dir2);
      dist1 = norm(crossing-from)*(angle(dir1, crossing-from) > 90 ? -1 : 1);
      dist2 = norm(crossing-to)*(angle(dir2, crossing-to) > 90 ? -1 : 1);
      radius = min(r, min(dist1, dist2)); // Can't reasonably override radius to be bigger
      extraLead = min(dist1, dist2) - radius;
      lead1 = extraLead + ((dist1 > dist2) ? max(dist1, dist2)-min(dist1, dist2) : 0);
      lead2 = extraLead + ((dist1 > dist2) ? 0 : max(dist1, dist2)-min(dist1, dist2));
      
      centerDir = normalize(dir1+dir2) * ((dist1 < 0 || dist2 < 0) ? 1 : -1);
      center = getCrossing(from=from+lead1*normalize(dir1), to=to+lead2*normalize(dir2), dir1=perpendicular(dir1), dir2=perpendicular(dir2));
      arcRadius = norm(from+lead1*normalize(dir1) - center);
      
      //TODO Channel width
      echo(centerDir);
      echo(center);
      channel(from=from, to=from+lead1*normalize(dir1));
      channel(from=to, to=to+lead2*normalize(dir2));
      translate(center) {
          //translate(-center)
//            arc(from=from+lead1*normalize(dir1), to=to+lead2*normalize(dir2), center=center, dir=sign(cross(from-center,dir1)), r=abs(radius*4));
        difference() {
          circle(r=abs(arcRadius)+0.5);
          circle(r=abs(arcRadius)-0.5);
          translate(-center)
            arc(from=from+lead1*normalize(dir1), to=to+lead2*normalize(dir2), center=center, dir=sign(cross(from-center,dir1)), r=(arcRadius+5)*2);
        }
      }
      
      
      /*
      // Debugging, for visual aid; remove
      translate(from+lead1*normalize(dir1))
        circle(r=2);
      translate(to+lead2*normalize(dir2))
        circle(r=2);
      translate(center)
        circle(r=3);
      translate(crossing)
        difference() {
          circle(r=abs(radius));
          circle(r=abs(radius)-0.5);
        }
      */
    }
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


linear_extrude(1) {
  t = $t;//100;
  rs = rands(-10,10,100,t);

  from=[rs[0],rs[1]];
  to=[rs[2],rs[3]];
  dir1=[rs[4],rs[5]];
  dir2=[rs[6],rs[7]];
  echo(from=from);echo(to=to);echo(dir1=dir1);echo(dir2=dir2);
  echo();

  channel(from-10*normalize(dir1),from,d1=5,d2=1);
  channel(to-10*normalize(dir2),to,d1=5,d2=1);
  channel(from,to,dir1,dir2);
}


/*
{
  to=[0,10];
  from=[0,0];
  dir2=[1,10];
  dir1=[-1,0.5];

  channel(from-10*normalize(dir1),from,d1=5,d2=1);
  channel(to-10*normalize(dir2),to,d1=5,d2=1);
  channel(from,to,dir1,dir2,r=5);
}
*/

/*
{
  from=[0,10];
  dir1=[-1,0];
  echo(crs=cross(from,dir1));
}
*/


/*
a = 360 * $t;
rot = [[cos(a), -sin(a)],[sin(a), cos(a)]];
x = rot*[-4,0];
y = rot*[0,4];
z = interpolateRotate(x, y, $t)*1.5;

translate(x)
  circle();
translate(y)
  circle();
translate(z)
  circle();
*/


//t = $t;
//a = 360 * t;
//rot = [[cos(a), -sin(a)],[sin(a), cos(a)]];
//x = rot*[15,0];
//y = rot*[0,15];
//echo(x=x,y=y);
//
//circle();
//translate(x)
//  circle();
//translate(y)
//  circle();
//
//translate(interpolateRotate(x, y, 0, dir=1)*1.5)
//  circle();
//for (i = [0:1:100]) {
//  translate(interpolateRotate(x, y, pow(0.8,i), dir=1)*1.5)
//    circle();
//}
//
//translate(interpolateRotate(x, y, 0, dir=-1)*1.8)
//  circle();
//for (i = [0:1:100]) {
//  translate(interpolateRotate(x, y, pow(0.8,i), dir=-1)*1.8)
//    circle();
//}
//
///*
//for (i = [0:1:100]) {
//  a = pow(0.8,i);
//  g = angle(x,y)*sign(angle(rot(y,angle(x,y)),x)-angle(rot(x,angle(x,y)),y));
//  //echo(angle(x,y)*sign(angle(rot(y,angle(x,y)),x)-angle(rot(x,angle(x,y)),y)));
//  //echo(angle(rot(y,angle(x,y)),x)-angle(rot(x,angle(x,y)),y));
//  //echo(angle(rot(y,angle(x,y)),x));
//  //echo(angle(rot(y,angle(x,y)),x));
//  p = rot(y,angle(x,y));
//  q = x;
//  echo(max(-1,(p*q)/(norm(p)*norm(q))));
//  //echo(angle(rot(x,angle(x,y)),y));
//  //echo(r=rot(x,angle(x,y)),y=y);
//  //p = rot(x,angle(x,y));
//  //q = y;
//  //echo(acos((p*q)/(norm(p)*norm(q))));
//  //echo((p*q)/(norm(p)*norm(q)));
//  tr = [[cos(a*g), -sin(a*g)],[sin(a*g),  cos(a*g)]]*x;
//  translate(tr*1.5)
//    circle();
//}
//*/
////acos(max(-1,(a*b)/(norm(a)*norm(b))))