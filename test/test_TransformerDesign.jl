@testset "TransformerDesign" begin
test_spldata = SplInput((
  25e3,(100,14),(300,270),
  100e3,(62,20,),(240,750),
  200e3,(38,8),(190,1100),
  400e3,(20,17),(140,1700),
  700e3,(12,20),(80,1750)
  ))
test_fp = FerriteProperties(0.2e6,0.5e6,25,100,
                            BHloop(15,.44,.15),
                            BHloop(10,.345,.120),
                            SpecificPowerLossData(test_spldata)) # 3f3
test_cg = CoreGeometry(4e-3,     1.5e-3,   5e-3, 300e-9, 14.5e-6, 0.6e-3) # e14
@test volt_seconds_per_turn(2.0,3.0)≈6.0
@test volt_seconds_per_turn(test_cg,2.0) ≈ 14.5e-6*2.0
@test volts_per_turn(test_fp, test_cg, 150e3, 500e3) ≈ 0.6005999150244018

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

e_core = core_geometry_dict["e14"]
plate = core_geometry_dict["plt14"]
material = ferrite_dict["3f4"]
layer1 = WindingLayer(pcb,true,e_core,3)
layer2 = WindingLayer(pcb,false,e_core,2)
layer3 = WindingLayer(pcb,false,e_core,2)
layer4 = WindingLayer(pcb,true,e_core,3)
primary = Winding(pcb,[layer1,layer4],false)
secondary = Winding(pcb,[layer2,layer3],true)
magnetics = Magnetics(material, [e_core,plate])
transformer = Transformer(magnetics,[primary,secondary])
v = volts(transformer,150e3,500e3)
@test v[1]≈2.2455612451812534
@test v[2]≈2.9940816602416715


end # testset
