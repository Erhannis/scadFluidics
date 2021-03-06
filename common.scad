$FOREVER = 1000;
//$fn = 100;

/**
A word about the *Endpoints() functions.
They each return a nested array representing the placement of the inputs/vents/outputs
of the component, given the parameters.  They are arranged like so:
[
  [ // Inputs
    [<Input1Position>, <Input1Direction>, <Input1ChannelDiam>],
    [<Input2Position>, <Input2Direction>, <Input2ChannelDiam>],
    ...
  ],
  [ // Outputs
    [<Output1Position>, <Output1Direction>, <Output1ChannelDiam>],
    [<Output2Position>, <Output2Direction>, <Output2ChannelDiam>],
    ...
  ],
  [ // Vents
    [<Vent1Position>, <Vent1Direction>, <Vent1ChannelDiam>],
    [<Vent2Position>, <Vent2Direction>, <Vent2ChannelDiam>],
    ...
  ]
]

For each endpoint:
Position: an array of 2 numbers marking the position of the endpoint
Direction: EITHER:
  an array of 2 numbers - if air flowed out of this endpoint, it would be flowing in this direction
  a scalar: 0, meaning it changes levels.  (Goes up or down, in z.)
ChannelDiam: one scalar (aka number) representing the channel diameter at the endpoint

With this information, it should be possible to cleanly and smoothly connect channels
to a given component.

So, for instance,

passiveButtonEndpoints(channelDiam = 3, leadIn = 20, leadOut = 20, sideOut = 20)[1][0][0]

would give you the position of the first (and only) output of the given passiveButton.
*/

//function calcBoundsFromEndpoints(endpoints) = ;

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
dir1, dir2 give vectors for directions facing INTO from and to, respectively.  Only works if both are defined.
If dir1 and dir2, then r can also be applied, which gives the radius of the turn.  If undefined, r defaults to the largest r that can fit.
If dir1 and dir2 run near-parallel, in some cases you may need to turn $fn WAY up to make the edges line up.  On the other hand, I think the path rendered would be infeasible, anyway.
Caps include "square", "circle", triangle", "sharp", and "none" (default).
*/
module channel(from=[5,0], to=[10,-10], dir1=undef, dir2=undef, r=undef, d=1, d1=undef, d2=undef, cap="none", overlap=0.01) {
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
      d3 = (d1+d2)/2; //TODO This will not usually work, but at least it's the prettiest of a variety of ineffective compromises
      channel(from=from, to=from+(lead1+overlap)*normalize(dir1), d1=d1, d2=d3);
      channel(from=to, to=to+(lead2+overlap)*normalize(dir2), d1=d2, d2=d3);
      translate(center) {
        difference() {
          circle(r=abs(arcRadius)+(d3/2));
          circle(r=abs(arcRadius)-(d3/2));
          translate(-center)
            arc(from=from+lead1*normalize(dir1), to=to+lead2*normalize(dir2), center=center, dir=sign(cross(from-center,dir1)), r=(arcRadius+5+abs(d1)+abs(d2))*2); // The radius is just a bunch of junk thrown in for just-in-case; just make it bigger than needed, that's all.
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
        } else if (cap == "square") { //TODO If d1!=d2, the edges don't quite line up to the caps
          union() {
            square(d1, center=true);
            translate([0, norm(to-from)])
              square(d2, center=true);
          }
        } else if (cap == "triangle") {
          union() {
            difference() {
              rotate(45) square(d1*sqrt(1/2), center=true);
              translate([0,d1]) square(d1*2,center=true);
            }
            translate([0, norm(to-from)])
              difference() {
                rotate(45) square(d2*sqrt(1/2), center=true);
                translate([0,-d2]) square(d2*2,center=true);
              }
          }
        } else if (cap == "sharp") {
          union() {
            difference() {
              scale([1,3]) rotate(45) square(d1*sqrt(1/2), center=true);
              translate([0,d1]) square(d1*2,center=true);
            }
            translate([0, norm(to-from)])
              difference() {
                scale([1,3]) rotate(45) square(d2*sqrt(1/2), center=true);
                translate([0,-d2]) square(d2*2,center=true);
              }
          }
        } else { // "none"
        }
      }
  }
}

//TODO Copied from misc.scad - just use the dep?
// Useful for minkowski 2D and 3D shapes together
$EPS=1e-300;
module flat3d() {
  linear_extrude(height=$EPS)
    children();
}

* union() { // Example
  {
    channel([0,0],[10,0], cap="circle");
    channel([10,0],[0,10], cap="circle");
    channel([0,10],[0,0], cap="circle");
  }

  {
    from=[0,15];
    to=[15,0];
    dir1=[1,0];
    dir2=[0,1];

    channel(from-10*normalize(dir1),from,d1=5,d2=3);
    channel(to-10*normalize(dir2),to,d1=5,d2=2);
    channel(from,to,dir1,dir2,d1=3,d2=2,r=4);
  }
}