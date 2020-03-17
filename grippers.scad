use <common.scad>

BIG = 1000;
EPS = 1e-100;

SHAFT_D = 10;
SHAFT_L = 50;
WALL_T = 2.5;
ENDSTOP_SIZE = SHAFT_D/9;
SPINDLE_D = SHAFT_D/4;
STOPPER_T = SPINDLE_D;
TUBE_D = 5;

HEIGHT = SHAFT_D;

module piston() {
  difference() {
    union() {
      channel([0,0],[SHAFT_L,0],d=SHAFT_D,cap="square");
      channel([0,-BIG],[0,0],d=TUBE_D,cap="square");
      channel([SHAFT_L,-BIG],[SHAFT_L,0],d=TUBE_D,cap="square");
      channel([-BIG,0],[BIG,0],d=SPINDLE_D);
    }
    channel([TUBE_D/2+ENDSTOP_SIZE/2,-SHAFT_D/2],[TUBE_D/2+ENDSTOP_SIZE/2,-SHAFT_D/2+ENDSTOP_SIZE],d=ENDSTOP_SIZE,cap="none");
    channel([SHAFT_L-TUBE_D/2-ENDSTOP_SIZE/2,-SHAFT_D/2],[SHAFT_L-TUBE_D/2-ENDSTOP_SIZE/2,-SHAFT_D/2+ENDSTOP_SIZE],d=ENDSTOP_SIZE,cap="none");
  }
}

* intersection() { // Body
  difference() {
    minkowski() {
      linear_extrude(height=HEIGHT) piston();
      translate([0,0,-WALL_T/2]) cube(WALL_T,center=true);
    }
    linear_extrude(height=HEIGHT) piston();
  }
  linear_extrude(height=BIG,center=true) translate([-SHAFT_L*0.2,-SHAFT_D*1.5]) square([SHAFT_L*1.4, SHAFT_D*2.5]);
  * translate([0,0,-BIG/2]) cube([BIG,BIG,BIG],center=true);
}

// Piston
translate([TUBE_D/2+ENDSTOP_SIZE/2+STOPPER_T/2,0,0]) difference() {
  linear_extrude(height=HEIGHT) {
    channel([-SHAFT_L*1.2,0],[SHAFT_L*1.2,0],d=SPINDLE_D);
    channel([0,-SHAFT_D/2],[0,SHAFT_D/2],d=STOPPER_T);
  }
  translate([-STOPPER_T/2-SPINDLE_D*sqrt(1/2),0,HEIGHT/2]) rotate([0,45,0]) cube([SPINDLE_D,BIG,SPINDLE_D],center=true);
  translate([STOPPER_T/2+SPINDLE_D*sqrt(1/2),0,HEIGHT/2]) rotate([0,45,0]) cube([SPINDLE_D,BIG,SPINDLE_D],center=true);
}