@testset "Winding" begin

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

core = core_geometry_dict["e14"]
layer1 = winding_layer(pcb,true,core,3)
layer2 = winding_layer(pcb,false,core,3)
layer3 = winding_layer(pcb,false,core,3)
layer4 = winding_layer(pcb,true,core,3)
primary = Winding(pcb,[layer1,layer4],false)
secondary = Winding(pcb,[layer2,layer3],true)

temperature = 100.0
@test winding_resistance(primary,temperature)≈0.0015265864267914595
@test winding_resistance(secondary,temperature)≈0.006106345707165838
@test turns(primary)==3
@test turns(secondary)==6

@test_throws ArgumentError Winding(pcb,[],false)
layer5 = winding_layer(pcb,true,core,2)
@test_throws ArgumentError Winding(pcb,[layer3, layer5],false)

end # testset
