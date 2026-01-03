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
r_outer = 190/2;
// Radius of inner circle
r_inner =  90/2;
// Radius of core, i.e. size of the connection to the lamp holder
r_core = 42/2;
// Number of layers including the core
core_layers = 20;
// Amount to rotate each layer by
rotation_offset = 0.6;

// Minimum inner radius, so there's still some width.
f_min_inner = max(5, 1.5 * r_inner);

// Cosine waves from the inner radius to the outer radius.
total_layers = floor(height/layer_height);
f_cosine_complete_waves = 3;
f_cosine_amplitude = (r_outer - f_min_inner) / 2;
f_cosine_displacement = f_cosine_amplitude + f_min_inner;
f_cosine_wavelength = 360 * f_cosine_complete_waves / total_layers;
f_cosine = function (l) -f_cosine_amplitude*cos((l % (total_layers/f_cosine_complete_waves)) * f_cosine_wavelength) + f_cosine_displacement - (r_inner-f_sine(l));

// Sine waves from the inner radius to the radius of a small light bulb.
f_sine_complete_waves = 0.5;
f_sine_end_radius = 35;
f_sine_amplitude = (r_inner - f_sine_end_radius) / 2;
f_sine_displacement = f_sine_amplitude + f_sine_end_radius;
f_sine_wavelength = 360 * f_sine_complete_waves / total_layers;
f_sine = function (l) f_sine_amplitude*cos((l % (total_layers/f_sine_complete_waves)) * f_sine_wavelength) + f_sine_displacement;

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
                  r_outer_function = f_cosine,
                  r_inner_function = f_sine);
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
              r_outer_function = f_cosine,
              r_inner_function = f_sine);
    // Uncomment to slice in half for debugging
    *translate([0, -(total_layers*layer_height)/2, 0]) cube(total_layers * layer_height);
  }
}
