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

frequency = 0.5e6 # Hz
spl_max = 150e3 # W/m^3
core = core_geometry_dict["er25/5.5_plt"]
material = ferrite_dict["3f35"]
magnetics = Magnetics(material, core)
fd_max_pp = flux_density(magnetics,spl_max,frequency) * 2.0
vspt = volt_seconds_per_turn(magnetics,fd_max_pp)

layer1 = winding_layer(pcb,true,core,3)
layer2 = winding_layer(pcb,false,core,2)
layer3 = winding_layer(pcb,false,core,2)
layer4 = winding_layer(pcb,true,core,3)
primary = Winding(pcb,[layer1,layer4],false)
secondary = Winding(pcb,[layer2,layer3],true)

transformer = Transformer(magnetics, [primary, secondary])

flux_density_max_pp = flux_density(transformer, spl_max, frequency) # Tesla
volt_seconds_max = volt_seconds(transformer, flux_density_max_pp)
primary_voltage_pp = 0.5
output_current_pp = 1.0
tpd =TransformerPowerDissipation(transformer,
              [primary_voltage_pp, output_current_pp], frequency)
total_power = tpd.total_power # W
r1_r2 = winding_resistance(transformer)
l1 = chan_inductor(transformer)
r3 = equivalent_parallel_resistance(transformer, primary_voltage_pp, frequency)
n1_n2 = turns(transformer)
