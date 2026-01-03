// Colours for display/debugging:
COLOUR_INNER_CORE_RINGS = "grey";
COLOUR_INNER_CORE_SPOKES_1 = "green";
COLOUR_INNER_CORE_SPOKES_2 = "lime";
COLOUR_OUTER_CORE_RINGS = "cyan";
COLOUR_OUTER_CORE_SPOKES_1 = "red";
COLOUR_OUTER_CORE_SPOKES_2 = "pink";
COLOUR_SEAMS = "black";

module regular_polygon(order, r, width) {
  angles=[ for (i = [0:order-1]) i*(360/order) ];
  coords=[ for (th=angles) [r*cos(th), r*sin(th)], for (th=angles) [(r-width)*cos(th), (r-width)*sin(th)] ];
  polygon(points=coords,paths=[[for(i=[0:1:(order-1)]) i],[for(i=[(2*order-1):-1:order]) i]]);
}

module cubes_around_circle(order, r, r_inner, width, layer_height) {
  line_angle = atan(width/r_inner);

  angles=[ for (i = [0:order-1]) i*(360/order) ];
  coords=[ for (th=angles) [r*cos(th), r*sin(th)], for (th=angles) [(r-width)*cos(th), (r-width)*sin(th)] ];

  for (p = [0:order])
    rotate([0,0,12*line_angle])
      translate([coords[p][0],coords[p][1],-0.5*layer_height])
        rotate([0,0,p*(360/order)])
          cube(size=[12*width,16*width,2*layer_height], center=true);
}

function flatten(l) = [ for (a = l) for (b = a) b ] ;

function interpolate4(v1, v2, v3, v4) = flatten( [ for (a = [0:len(v1)-1]) [v1[a], v2[a], v3[a], v4[a]] ] );

module line(start, end, layer_height, thickness = 1) {
  $fn=4;
  resize([0,0,layer_height], auto=[false,false,true])
    hull() {
      translate(start) sphere(thickness);
      translate(end) sphere(thickness);
    }
}

module star_polygon(order, r1, r2, w, layer_height, only_points) {
  // need the width of a line in degrees
  line_angle = atan(w/r2);

  angles=[ for (i = [0:order-1]) i*(360/order) ];

  big_spoke =     [ for (th=angles) [r2*cos(th),              r2*sin(th),              0] ];
  big_tangent =   [ for (th=angles) [r2*cos(th+2*line_angle), r2*sin(th+2*line_angle), 0] ];
  small =         [ for (th=angles) [r1*cos(th),              r1*sin(th),              0] ];
  small_tangent = [ for (th=angles) [r1*cos(th+5*line_angle), r1*sin(th+5*line_angle), 0] ];

  star_path = interpolate4(big_spoke, big_tangent, small, small_tangent);

  points = is_undef(only_points) ? [1:len(star_path)-1] : only_points;

  translate([0,0,layer_height/2])
    //for(i=[1:len(star_path) - 1])
      for(i=points)
        line(star_path[i-1], star_path[i], layer_height, thickness=w);

  if (is_undef(only_points)) {
    translate([0,0,layer_height/2])
      line(star_path[len(star_path)-1], star_path[0], layer_height, thickness=w);
    }
}

module lampshade(
  // Number of outer spoke points
  points = 16,
  // Total height of the lampshade
  height = 210,
  // Height of each layer, should be a multiple of the intended print layer height
  layer_height = 0.6, // print layer will be 0.3
  // Width, i.e. print extrusion width
  width = 0.45,
  // Overhang distance for tips of spokes
  overhang = 2,
  // Radius of outer circle
  r_outer = 200/2,
  // Radius of inner circle
  r_inner =  120/2,
  // Radius of core, i.e. size of the connection to the lamp holder
  r_core = 42/2,
  // Number of layers including the core
  core_layers = 20,
  // Amount to rotate each layer by
  rotation_offset = 0.6,
  // Outside slope function
  r_outer_function = function(r, l) r,
  // Inside slope function
  r_inner_function = function(r, l) r
) {
  // Total number of layers
  total_layers = floor(height/layer_height);

  // Inner core polygon rings
  color(COLOUR_INNER_CORE_RINGS)
  for (l = [0:2:core_layers])
    translate([0,0,l*layer_height])
      difference() {
        union() {
          linear_extrude(height=layer_height)
          circle(r=r_core+4*width);
        }
        translate([0,0,-0.5])
          linear_extrude(height=layer_height+1)
            circle(r=r_core);
      }

  color(COLOUR_INNER_CORE_RINGS)
  for (l = [1:4:core_layers-1])
    translate([0,0,l*layer_height])
      difference() {
        union() {
          linear_extrude(height=layer_height)
          circle(r=r_core+4*width);
        }
        union() {
          translate([0,0,-0.5])
            linear_extrude(height=layer_height+1)
              circle(r=r_core);
          rotate([0,0,l*rotation_offset])
            rotate([0,0,180/points])
              translate([0,0,layer_height])
                cubes_around_circle(points/2, r=r_core, r_inner=r_inner, width=width, layer_height=layer_height);
        }
      }
  color(COLOUR_INNER_CORE_RINGS)
  for (l = [3:4:core_layers-1])
    translate([0,0,l*layer_height])
      difference() {
        union() {
          linear_extrude(height=layer_height)
          circle(r=r_core+4*width);
        }
        union() {
          translate([0,0,-0.5])
            linear_extrude(height=layer_height+1)
              circle(r=r_core);
          rotate([0,0,l*rotation_offset])
            rotate([0,0,-24*atan(width/r_inner)])
              mirror([1,0,0])
                translate([0,0,layer_height])
                  cubes_around_circle(points/2, r_core, r_inner=r_inner, width=width, layer_height=layer_height);
        }
      }

  // Inner core spokes
  color(COLOUR_INNER_CORE_SPOKES_1)
  for (l = [0:4:core_layers-1])
    translate([0,0,(l+1)*layer_height])
      rotate([0,0,l*rotation_offset])
        rotate([0,0,180/points])
          difference() {
            union() {
              star_polygon(order=points/2, r1=r_core-width, r2=r_inner+overhang/2, w=width, layer_height=layer_height);
            }
            translate([0,0,-layer_height])
              linear_extrude(height=layer_height*3)
            circle(r=r_core);
          };

  color(COLOUR_INNER_CORE_SPOKES_2)
  for (l = [2:4:core_layers-1])
    translate([0,0,(l+1)*layer_height])
      rotate([0,0,l*rotation_offset])
        rotate([0,0,-180/points])
          mirror([1,0,0])
            difference() {
              union() {
                star_polygon(order=points/2, r1=r_core-width, r2=r_inner+overhang/2, w=width, layer_height=layer_height);
              }
              translate([0,0,-layer_height])
                linear_extrude(height=layer_height*3)
                  circle(r=r_core);
            };

  // Outer core polygon rings
  color(COLOUR_OUTER_CORE_RINGS)
  for (l = [0:2:total_layers-1])
    rotate([0,0,l*rotation_offset])
      translate([0,0,l*layer_height])
        linear_extrude(height=layer_height) {
          r_inner_2 = r_inner_function(l);
          r_outer_2 = r_outer_function(l);
          regular_polygon(order=points, r=r_outer_2, width=width);
          regular_polygon(order=points, r=r_inner_2, width=width);
        }

  // Outer core spokes
  color(COLOUR_OUTER_CORE_SPOKES_1)
  for (l = [2:4:total_layers-1])
    rotate([0,0,l*rotation_offset])
      translate([0,0,(l+1)*layer_height])
        difference() {
          r_inner_2 = r_inner_function(l);
          r_outer_2 = r_outer_function(l);
          star_polygon(order=points, r1=r_inner_2-1.25*overhang, r2=r_outer_2+overhang, w=width, layer_height=layer_height);
          //cylinder(r=r_inner_2-width*4,h=layer_height*3, center=true);
        }

  color(COLOUR_OUTER_CORE_SPOKES_2)
  for (l = [0:4:total_layers-1])
    rotate([0,0,(l+0.4)*rotation_offset])
      translate([0,0,(l+1)*layer_height])
        mirror([1,0,0])
          difference() {
            r_inner_2 = r_inner_function(l);
            r_outer_2 = r_outer_function(l);
            star_polygon(order=points, r1=r_inner_2-1.25*overhang, r2=r_outer_2+overhang, w=width, layer_height=layer_height);
            //cylinder(r=r_inner_2-width*4,h=layer_height*3, center=true);
          }
  }

module lampshade_seams(
  points = 16,
  height = 210,
  layer_height = 0.6, // print layer will be 0.3
  width = 0.45,
  overhang = 2,
  r_outer = 200/2,
  r_inner =  120/2,
  r_core = 42/2,
  core_layers = 20,
  rotation_offset = 0.6,
  r_outer_function = function(r, l) r,
  r_inner_function = function(r, l) r
) {
  // Total number of layers
  total_layers = floor(height/layer_height);

  // Seam positions:
  color(COLOUR_SEAMS)
  for (l = [2:4:total_layers-1])
    rotate([0,0,l*rotation_offset])
      translate([0,0,(l+1)*layer_height])
        intersection() {
          r_inner_2 = r_inner_function(l);
          r_outer_2 = r_outer_function(l);
          star_polygon(order=points, r1=r_inner_2-1.25*overhang, r2=r_outer_2+overhang, w=width, layer_height=layer_height, only_points=[2:1:3]);
          cylinder(r=r_inner_2-width*4,h=layer_height*3, center=true);
        }

  color(COLOUR_SEAMS)
  for (l = [0:4:total_layers-1])
    rotate([0,0,(l+0.4)*rotation_offset])
      translate([0,0,(l+1)*layer_height])
        intersection() {
          r_inner_2 = r_inner_function(l);
          r_outer_2 = r_outer_function(l);
          mirror([1,0,0])
            star_polygon(order=points, r1=r_inner_2-1.25*overhang, r2=r_outer_2+overhang, w=width, layer_height=layer_height, only_points=[26:1:27]);
          cylinder(r=r_inner_2-width*4,h=layer_height*3, center=true);
        }
}
