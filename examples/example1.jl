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
my_geometry_list = [
    ["e14","plt14"],
    ["e18","plt18"],
    ["e22","plt22"],
    ["e32","plt32"],
    ["e58","plt58"]
]
my_ferrite_list = ["3f4","3f45","3f5"];
my_ferrites = getindex.(ferrite_dict,my_ferrite_list)
my_cores = [getindex.(core_geometry_dict,x) for x in my_geometry_list]
my_magnetics = [Magnetics(y,x) for x in my_cores, y in my_ferrites]

turns_per_layer = 1:10
outer_winding_layer = [winding_layer(pcb,true,x[1],y) for x in my_cores, y in turns_per_layer]
inner_winding_layer = [winding_layer(pcb,false,x[1],y) for x in my_cores, y in turns_per_layer]
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
frequency = 1e6  # Hz
spl_max = 150e3
primary_voltage_pp = 20.0
output_current_pp = 5.0 # W/m^3
function powerNA(tpd::TransformerPowerDissipation,spl_max)
  tpd.flux_density<spl_max ? tpd.total_power : Inf
end
tdp = [powerNA(TransformerPowerDissipation(transformer[x,y,z],[primary_voltage_pp, output_current_pp], frequency),spl_max)
  for x in eachindex(my_cores),
      y in eachindex(my_ferrites),
      z in eachindex(turns_per_layer)]

(v,i) = findmin(tdp)
transformer[i].magnetics.ferriteproperties.name
transformer[i].magnetics.cores[1].name
transformer[i].magnetics.cores[2].name
transformer[i].windings[1].turns
transformer[i].windings[2].turns
