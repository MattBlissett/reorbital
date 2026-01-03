include <reorbital.scad>;

generate_seams = false;
generate_lamp = !generate_seams;

// Number of outer spoke points
points = 10;
// Total height of the lampshade
height = 180;
// Height of each layer, should be a multiple of the intended print layer height
layer_height = 0.28*2; // print layer will be 0.28
// Width, i.e. print extrusion width
width = 0.48;
// Overhang distance for tips of spokes
overhang = 2;
// Radius of outer circle
r_outer = 100/2;
// Radius of inner circle
r_inner =  80/2;
// Radius of core, i.e. size of the connection to the lamp holder
r_core = 33.5/2;
// Number of layers including the core
core_layers = 40;
// Amount to rotate each layer by
rotation_offset = 0.6;

bulge_amount = 15;

f_straight = function(r, l) r;

r_function = function (l) f_straight(r_outer, l);

// Minimum inner radius, so there's still some width.
f_min_inner = max(5, 1.5 * r_inner);

// Bulge
total_layers = floor(height/layer_height);
r_bulge_function = function(l) r_outer + bulge_amount*sin(180/total_layers*l);

r_inner_function = function (l) f_straight(r_inner, l);

if (generate_seams) {
  lampshade_seams(points = points,
                  height = height,
                  layer_height = layer_height,
                  width = width,
                  overhang = overhang,
                  r_outer = r_outer,
                  r_inner = r_inner,
                  r_core = r_core,
                  core_layers = core_layers,
                  rotation_offset = rotation_offset,
                  r_outer_function = r_bulge_function,
                  r_inner_function = r_inner_function);
}

if (generate_lamp) {
  intersection() {
    lampshade(points = points,
              height = height,
              layer_height = layer_height,
              width = width,
              overhang = overhang,
              r_outer = r_outer,
              r_inner = r_inner,
              r_core = r_core,
              core_layers = core_layers,
              rotation_offset = rotation_offset,
              r_outer_function = r_bulge_function,
              r_inner_function = r_inner_function);
    // Uncomment to slice in half for debugging
    *translate([0, -(total_layers*layer_height)/2, 0]) cube(total_layers * layer_height);
  }
}
