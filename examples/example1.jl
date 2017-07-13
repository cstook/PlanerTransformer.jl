# example1.jl
#
# Vin = 20V
# Iout = 5A
# 1:1 turns ratio
# 4 layer pcb, 1oz copper
# Use PlanerTrnasformer.jl to find an efficient design.

using PlanerTransformer

# Define PCB
trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
outer_copper_thickness = copper_weight_to_meters(1.0)
inner_copper_thickness = copper_weight_to_meters(1.0)
number_of_layers = 4
pcb = PCB_Specification(trace_edge_gap,
                        trace_trace_gap,
                        outer_copper_thickness,
                        inner_copper_thickness,
                        number_of_layers)

# Create an array of transformers
# my_geometry_list = ["er12.5_plt","er18_plt","er20_plt","er25/5.5_plt","er30_plt","er32_plt"]
my_geometry_list = ["e14_plt","e18_plt","e22_plt","e32_plt","e58_plt","e64_plt"]
my_ferrite_list = ["3f4","3f45","3f5"];
my_ferrites = getindex.(ferrite_dict,my_ferrite_list)
my_cores = [getindex.(core_geometry_dict,x) for x in my_geometry_list]
my_magnetics = [Magnetics(y,x) for x in my_cores, y in my_ferrites]
turns_per_layer = 1:6
outer_winding_layer = [winding_layer(pcb,true,x,y) for x in my_cores, y in turns_per_layer]
inner_winding_layer = [winding_layer(pcb,false,x,y) for x in my_cores, y in turns_per_layer]
primary = [Winding(pcb,[x,x],true) for x in outer_winding_layer]
secondary = [Winding(pcb,[y,y],true) for y in inner_winding_layer]
transformer = Array{Transformer}(length(my_cores),length(my_ferrites),length(turns_per_layer))
for x in eachindex(my_cores)
  for y in eachindex(my_ferrites)
    for z in eachindex(turns_per_layer)
      transformer[x,y,z] = Transformer(my_magnetics[x,y],[primary[x,z],secondary[x,z]])
    end
  end
end

# Conditions to compute power dissipation
frequency = 3e6  # Hz
spl_max = 450e3
primary_voltage_pp = 20.0
output_current_pp = 5.0 # W/m^3

# Compute power dissipstion for each transformer
tpd_array = [TransformerPowerDissipation(transformer[x,y,z],[primary_voltage_pp, output_current_pp], frequency)
  for x in eachindex(my_cores),
      y in eachindex(my_ferrites),
      z in eachindex(turns_per_layer)]

# just the power dissipation
tp = total_power.(tpd_array)
# power dissipation replaced by NaN if specific power loss exceeds maximum.
tp_nan = (x->core_specific_power(x)<spl_max?total_power(x):NaN).(tpd_array)
(v,i) = findmin(tp_nan) # find the most efficient design

# print some info for the most efficient design
println(name(ferriteproperties(magnetics(transformer[i]))))
println(name(core(magnetics(transformer[i]))))
println(turns(windings(transformer[i])[1]))
println(turns(windings(transformer[i])[2]))
println(tp[i])

# looking at stuff in Atom
tpd_array[i]
tp[:,1,:]







tp_nan[:,1,:]







#
