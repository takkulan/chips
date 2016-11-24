// Used and heavily modified original code from 
//      OpenSCAD 3D surface plotter, z(x,y)
//      Dan Newman, dan newman @ mtbaldy us
//      8 April 2011
//      10 June 2012 (revised)

// Chips-v2 model Pasi Takala Nov 2016
// My edits in  short: Plotter had only top surface, now both top&bottom are functions
//                  Had to extract function code to actual program, as I could not figure out
//                  how to pass a function to function as parameter, thus my resulting code is a bit
//                  of a mess here.


// top and bottom level function for leaves
function z(x,y,b) = x*y*(b/500)+b*9+12;  // this be top of each leave
function z2(x,y,b) = x*y*(b/500)+b*9-2+12; //this be bottom ("-2" = 2mm thickness)

// top cutter funtion to cut everything above top leave (to make center tube match curvy top)
function c(x,y,b) = x*y*(b/500)+b*9+120; // put the cutter top surface high enough
function c2(x,y,b) = x*y*(b/500)+b*9+12; // cutter bottom surface matches top leaf upper surface

// Below:
// 1) As iterrators produce square shaped leaves, a cylinder cuts them to round
// 2) bottom cylinder iss added
// 3) center pole cylinder is added
// 4) center pylon is cut with top cutter (first iterator part)
// 5) Leaves are added (latter longer iteration part)
// 6) center hole is cut
// done.
// All units in millimeters. Note that this is impossible to print vertically without supports,
// horizontally with PLA this is in limits (most overhangs are <60 degree some over)

intersection()      //this allows cylinder to limit the space of everything else
{
    cylinder (h = 180, r=45, center = false, $fn=100);  // cuts the shape to spherical form
    difference()
    {
        union() //everything inside cylinder
        {
       //     color("red") translate([0,0,180])  cylinder (h=10,r=50, center=false); //visual debug
            color("green") cylinder (h=10, r=45, center=false);                      //bottom piece

            difference()  // center pylon cut with top
            {
                color("blue") cylinder (h=170, r=21, center = false, $fn=100); // center pylon
                union() //union of top cutter polyhedrons
                {
                    rotate ([0,0,75]) color("green") 
                    {
                        base=15;  //cut the tube
                        dx=20;  // use 5 for production quality
                        dy=20;  // use 20 for testing for speed 
                        for ( x = [-50 : dx: 50] )
                        {   
                            for ( y = [-50 : dy : 50] )
                            {
                                polyhedron(points=[[x,y,c2(x,y,base)], [x+dx,y,c2(x+dx,y,base)], 
                                               [x,y,c(x,y,base)], [x+dx,y,c(x+dx,y,base)],
                                               [x+dx,y+dy,c2(x+dx,y+dy,base)], 
                                               [x+dx,y+dy,c(x+dx,y+dy,base)]], triangles=prism_faces_1);
                                polyhedron(points=[[x,y,c2(x,y,base)], [x,y,c(x,y,base)], 
                                               [x,y+dy,c2(x,y+dy,base)], [x+dx,y+dy,c2(x+dx,y+dy,base)],
                                               [x,y+dy,c(x,y+dy,base)], [x+dx,y+dy,c(x+dx,y+dy,base)]],
                                               triangles=prism_faces_2);
                            }
                        }
                    }
                }
            }

            for ( base = [0:1:15] )  // iterator for leaves in the form
             {
                rotate ([0,0,base*5]) //putting a small twist there
                union()
                {
                    dx=20; // similar as above, defines the number of elements in one leave
                    dy=20;
                    for ( x = [-50 : dx: 50] )
                    {
                        for ( y = [-50 : dy : 50] )
                        {
                            polyhedron(points=[[x,y,z2(x,y,base)], [x+dx,y,z2(x+dx,y,base)], 
                                               [x,y,z(x,y,base)], [x+dx,y,z(x+dx,y,base)],
                                               [x+dx,y+dy,z2(x+dx,y+dy,base)], 
                                               [x+dx,y+dy,z(x+dx,y+dy,base)]], triangles=prism_faces_1);
                            polyhedron(points=[[x,y,z2(x,y,base)], [x,y,z(x,y,base)], 
                                               [x,y+dy,z2(x,y+dy,base)], [x+dx,y+dy,z2(x+dx,y+dy,base)],
                                               [x,y+dy,z(x,y+dy,base)], [x+dx,y+dy,z(x+dx,y+dy,base)]],
                                               triangles=prism_faces_2);
                        }
                    }
                }
            }
        }
        translate ([0,0,-1]) color("blue") cylinder (h=172, r=20, center = false); // center pylon hole
    }
}

// Our NxM grid is NxM cubes, each cube split into 2 upright prisms
prism_faces_1 = [ [3,2,5],[4,0,1], [0,2,1],[2,3,1], [1,3,4],[3,5,4], [5,2,4],[2,0,4] ];
prism_faces_2 = [[4,5,1],[2,0,3], [5,4,2],[2,3,5], [4,1,0],[0,2,4], [1,5,3],[3,0,1]];

