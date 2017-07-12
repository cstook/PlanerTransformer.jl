using PlanerTransformer
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
core_geometry_dict
#my_geometry_list = ["er12.5_plt","er18_plt","er20_plt","er25/5.5_plt","er30_plt","er32_plt"]
my_geometry_list = ["e14_plt","e18_plt","e22_plt","e32_plt","e58_plt","e64_plt"]
my_ferrite_list = ["3f4"]#["3f4","3f45","3f5"];
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
frequency = 3e6  # Hz
spl_max = 450e3
primary_voltage_pp = 20.0
output_current_pp = 5.0 # W/m^3
function power_inf(tpd::TransformerPowerDissipation,spl_max)
  tpd.core_specific_power<spl_max ? tpd.total_power : Inf
end
function core_power_inf(tpd::TransformerPowerDissipation,spl_max)
  tpd.core_specific_power<spl_max ? tpd.core_total_power : Inf
end
tdp = [TransformerPowerDissipation(transformer[x,y,z],[primary_voltage_pp, output_current_pp], frequency)
  for x in eachindex(my_cores),
      y in eachindex(my_ferrites),
      z in eachindex(turns_per_layer)]
total_power = power_inf.(tdp,spl_max)
core_total_power = core_power_inf.(tdp,spl_max)

(v,i) = findmin(core_total_power)
(v,i) = findmin(total_power)
println(transformer[i].magnetics.ferriteproperties.name)
println(transformer[i].magnetics.core.name)
println(transformer[i].windings[1].turns)
println(transformer[i].windings[2].turns)
println(tdp[i].total_power)
tdp[i]
total_power[:,1,:]







core_total_power[:,1,:]







# fjfjfjfjfj
