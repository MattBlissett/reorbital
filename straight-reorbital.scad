include <reorbital.scad>;

generate_seams = false;
generate_lamp = !generate_seams;

// Number of outer spoke points
points = 16;
// Total height of the lampshade
height = 210;
// Height of each layer, should be a multiple of the intended print layer height
layer_height = 0.6; // print layer will be 0.3
// Width, i.e. print extrusion width
width = 0.45;
// Overhang distance for tips of spokes
overhang = 2;
// Radius of outer circle
r_outer = 200/2;
// Radius of inner circle
r_inner =  120/2;
// Radius of core, i.e. size of the connection to the lamp holder
r_core = 42/2;
// Number of layers including the core
core_layers = 20;
// Amount to rotate each layer by
rotation_offset = 0.6;

f_straight = function(r, l) r;
r_outer_function = function (l) f_straight(r_outer, l);
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
                  r_outer_function = r_outer_function,
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
              r_outer_function = r_outer_function,
              r_inner_function = r_inner_function);
    // Uncomment to slice in half for debugging
    *translate([0, -(total_layers*layer_height)/2, 0]) cube(total_layers * layer_height);
  }
}
