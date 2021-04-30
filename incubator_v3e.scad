// main incubation chamber
$fs=0.5;
$fa=0.5;

use <text_on.scad>;

// all measurements are given in mm!

//font = "Monaco:style=Regular";
font="Optima:style=Bold";
letterHeight=1.5;
letterSize=6;
spacing=1.1;
msg = "LNCB";
vMsg = "v3E";

beakerD = 62; 			// beaker diameter
bradius = 6.5;
bwall = 2;
bledge = 4.5;
bBottom = 3;
cwall = 2;
cheight = 15;
ledgeWidth = 3;
legheight = 20;

meshHeight = 1.5;

supportArcR = 5;

cradius = beakerD/2;
legWidth = (cradius * 2) * (1 / 2);


// main arrangement of chamber and meshes
* translate([0, 0, legheight]) chamber();
// translate([2 * beakerD + beakerD/4, 0, 0]) chamber();
// translate([2 * beakerD + beakerD/4, beakerD + beakerD/8, 0]) rotate([0, 0, 180]) chamber();

// for (t = [ [-beakerD/2-8, beakerD-5, -legheight],
//           [beakerD/4+5, beakerD-5, -legheight],
//           [beakerD + 5, 0, -legheight],
//           [-(beakerD + 5), 0, -legheight], 
//           [1.3 * beakerD, beakerD-5, -legheight] ])
//     translate(t) grid(barThick, bDist, fBorder, tol, 1.5);

grid(barThick, bDist, fBorder, tol, 1.5);

// modules
module chamber() {
	difference() {
	// chamber with bubble holder
	union() {
		// main chamber
		difference() {
			color("aqua")
				translate([0,0,-legheight]) cylinder(r=cradius,h=cheight + legheight);
			translate([0,0,2]) cylinder(r=cradius-cwall, h=cheight);
			translate([0,0,-legheight - 1]) cylinder(r=cradius-cwall-ledgeWidth, h=cheight + legheight);
			translate([0,cradius-bradius,-legheight]) cylinder(r=bradius, h=cheight + legheight + 5);

			// creating a block to crated the legs with nice rounds
			translate([0,cradius-legWidth+supportArcR,-legheight-(supportArcR/2)+0.5]) {
				minkowski() {
					rotate([0,90,0]) cylinder(r=supportArcR,h=cradius + 2, center=true);
					translate([-cradius/2,0,0]) 
						cube([cradius,legWidth-supportArcR,legheight - supportArcR + 2]);
				}
			}
	
			// separating arc
			translate([-legWidth/2,-beakerD/2+((cwall+ledgeWidth) * 3),-legWidth-1+supportArcR])
				rotate([90,0,0])
					linear_extrude(height=(cwall+ledgeWidth+5) * 2)
						minkowski() {
							square([legWidth, legheight + 2]);
							circle(r=supportArcR);
						}
			
			text_on_cylinder(msg, r=cradius, h=13, font=font, size=letterSize, extrusion_height=letterHeight, eastwest=122, spacing=spacing);
			text_on_cylinder(vMsg, r=cradius, h=13, font=font, size=letterSize, extrusion_height=letterHeight, eastwest=-120, spacing=spacing);
		}

		difference() {
			union() {
				// now for the bubble holder
				translate([0,cradius-bradius,-legheight])	{
	    				difference() {
	        				cylinder(r=bradius + bwall, h=legheight+cheight);
							translate([0,0,bBottom])
 								cylinder(r=bradius, h=cheight+legheight+2);
     					}
				}
				
				// bubble connector -> make a bigger connection surface
				translate([-(bradius+bwall)*2,cradius-bradius,0]) {
					difference() {
						cube([(bradius+bwall)*4,bradius+bwall*2,cheight]);
						translate([0, cradius-bradius, 0])
							cyclinder(r=bradius, h=cheight+1);

					}
				}
			}

			translate([0,0,-legheight-1]) {
				linear_extrude(height=cheight+legheight+2) {
					difference() {
						offset(r=10)
							circle(r=cradius); 
						circle(r=cradius);
					
					}
			}
			}			
		}
	}
	
	// create the opening in the back wall of the holder
	translate([0, cradius-bwall, bBottom-bwall])
		cube([bwall * 6, bwall * 2, cheight+legheight + 0.95], center=true);
	// remove parts of the connector from the inside of the holder
	translate([0, cradius-bradius, -1])
		cylinder(r=bradius, h=cheight+2);
	
	// slant the legs
	scale([1,1.01,1]) {
		translate([0,-bradius-bwall/2,-legheight+supportArcR]) {
			difference() {
				translate([0,bradius+(bwall/2),-supportArcR-1])
					linear_extrude(height=supportArcR, convexity=10)
						circle(d=beakerD);

				difference() {
					translate([0,bradius+(bwall/2),0])
						rotate_extrude(convexity=10)
							translate([beakerD/2-supportArcR,0,0]) circle(r=supportArcR);

					translate([0,bradius+(bwall/2),0])
						linear_extrude(height=supportArcR, convexity=10) circle(d=beakerD);
				}

				translate([0,bradius+(bwall/2),-supportArcR-2])
					linear_extrude(height=2*supportArcR, convexity=10)
						circle(d=beakerD-(supportArcR*2));

			}
		}
	}
	}
}

gridR = cradius-cwall-0.5;
barThick = 1.5;		// thickness of the bar in mm
bDist = 1.5;			// distance between bars in mm
tol = 1;			// tolerance, i.e. how far away from the border
fBorder = 2;		// frameborder in mm


module grid(barThick, barDist, frameBorder, tolerance, height) {
	barThick = barThick < 1 ? 1 : barThick;
	barDist = barDist < 1 ? 1 : barDist;
	frameBorder = frameBorder < 1 ? 1 : frameBorder;
	tolerance = tolerance <= 0 ? 1 : tolerance;
	height = height <= 0 ? 1.5 : height;

	linear_extrude(height=height) {
		union() {
			gridInsertFrame(frameBorder, tolerance);
			gridStructure(barThick, barDist, frameBorder, tolerance);
		}
	}
	linear_extrude(height=cheight/2, convexity=10) {
		circle(r=(barThick * 2));
		translate([-barThick/2,-gridR+(tolerance/2),0])
			square([barThick,2 * (gridR - (tolerance/2) - bradius)]);
		translate([gridR-(tolerance/2),-barThick/2,0])
			rotate([0,0,90])
				square([barThick,2 * (gridR - (tolerance/2))]);
	}
}


module gridStructure(barThick, barDist, frameBorder, tolerance) {
	barThick = barThick < 1 ? 1 : barThick;
	barDist = barDist < 1 ? 1 : barDist;
	frameBorder = frameBorder < 1 ? 1 : frameBorder;
	tolerance = tolerance <= 0 ? 1 : tolerance;
	
	numBars = ceil((gridR * 2) / (barThick + barDist));
	
	difference() {
		union() { 
			rotate([0,0,45]) {
				for (n = [0:numBars]) {
					translate([(n * (barThick + barDist)) - gridR, 0, 0])
						square([barThick,2 * gridR], center=true);
				}
			}	
			rotate([0,0,-45]) {
				for (n = [0:numBars]) {
					translate([gridR - (n * (barThick + barDist)), 0, 0])
						square([barThick,2 * gridR], center=true);
				}
			}
		}
		
		difference() {
			rotate([0,0,45]) square((2*gridR) + 2 * (barThick + barDist), center=true);
			difference() {
				circle(r=(beakerD/2) - cwall-tolerance);
				translate([0, beakerD/2 - bradius, 0]) circle(r=bradius+bwall+cwall+tolerance);
				offset(r=1)
					translate([-(bradius + bwall) * 2,cradius-bradius-tolerance,0])
					square([(bradius + bwall) * 4, bradius + bwall * 2]);
				
			}
		}
	}
}


module gridInsertFrame(frameBorder, tolerance) {
	frameBorder = frameBorder < 1 ? 1 : frameBorder;
	tolerance = tolerance <= 0 ? 1 : tolerance;

	difference() {
		union() {
			difference() {
				circle(r=(beakerD/2)-cwall-tolerance);
				offset(r=-2)
					circle(r=(beakerD/2)-cwall-tolerance);
				translate([0, cradius-cwall-bradius/2, 0])
					circle(r=bradius+bwall+tolerance+1);
			}
			difference() {
				offset(r=3) {
					translate([0,cradius-bradius,0])
						circle(r=bradius+bwall);
				}
				offset(r=1) {
					translate([-bradius,cradius-cwall-bradius,0])
						square([(bradius)*2, bradius+bwall]);
					translate([0,cradius-bradius,0])
						circle(r=bradius+bwall);
				}
				difference() {
					circle(r=(beakerD/2)+cwall+bwall+5);
					circle(r=(beakerD/2)-cwall-1);
				}
			}
			translate([bradius+bwall*2, cradius-bradius-tolerance-bwall, 0])
				square(size=[bwall*2, bwall]);
	
			mirror([1,0,0])
				translate([bradius+bwall*2, cradius-bradius-tolerance-bwall, 0])
				square(size=[bwall*2, bwall]);
				
		}
		
	translate([-(bradius+bwall) * 2, cradius-bradius-tolerance, 0])
		square(size=[(bradius+bwall) * 4, bradius+bwall*2]);
	}
}
