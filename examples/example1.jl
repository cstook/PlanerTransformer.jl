# example1.jl
#
# Vin = 20V
# Iout = 5A
# 1:1 turns ratio
# 4 layer pcb, 1oz copper
# Use PlanerTrnasformer.jl to find an efficient design.

using PlanerTransformer

# define pcb
trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
outer = copper_weight_to_meters(1.0)
inner = copper_weight_to_meters(1.0)
number_of_layers = 4
dielectric = (1.6e-3-2*outer-2*inner)/(number_of_layers-1)

stackup = Stackup([copper,fr408,copper,fr408,copper,fr408,copper],
                  [outer,dielectric,inner,dielectric,inner,dielectric,outer])
pcb = PCB_Specification(trace_edge_gap,
                        trace_trace_gap,
                        stackup)

# core geometries to analyze
my_geometry_list = ["e14_plt","e18_plt","e22_plt","e32_plt","e58_plt"]
my_cores = getindex.(core_geometry_dict,my_geometry_list)

# ferrites to analyze
my_ferrite_list = ["3f4","3f45","3f5","4f1"]
my_ferrites = getindex.(ferrite_dict,my_ferrite_list)

# 1 to 10 turns per layer
turns_per_layer = 1:10
my_windings = [windings(pcb,x,y,y,prisec"P-S-S-P",false,false) for x in my_cores, y in turns_per_layer]

# create transformers for all conbinations
my_transformers = [Transformer(f,w) for f in my_ferrites, w in my_windings]

v_in = 20.0
i_out = -5.0 # power flows out of secondary
frequency = 10e6
my_analysis = transformer_power_analysis.(my_transformers, PushPull(v_in, i_out, frequency))

(pmin,index) = findmin(total_power.(my_analysis))
best_analysis = my_analysis[index]
(ferrite_name(best_analysis), core_name(best_analysis), turns(best_analysis))
e = efficiency(best_analysis)
l = leakage_inductance(best_analysis)
c = capacitance(best_analysis)

# what is the efficiency of the smallest core
my_analysis_e14plt = transformer_power_analysis.(my_transformers[:,1,:], PushPull(v_in, i_out, frequency))

(pmin,index) = findmin(total_power.(my_analysis_e14plt))
best_analysis_e14plt = my_analysis_e14plt[index]
(ferrite_name(best_analysis_e14plt), core_name(best_analysis_e14plt), turns(best_analysis_e14plt))
e = efficiency(best_analysis_e14plt)
l = leakage_inductance(best_analysis_e14plt)
c = capacitance(best_analysis_e14plt)
