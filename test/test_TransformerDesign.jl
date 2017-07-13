@testset "TransformerDesign" begin
test_spldata = PlanerTransformer.SplInput((
  25e3,(100,14),(300,270),
  100e3,(62,20,),(240,750),
  200e3,(38,8),(190,1100),
  400e3,(20,17),(140,1700),
  700e3,(12,20),(80,1750)
  ))
test_fp = FerriteProperties("3f3",0.2e6,0.5e6,25,100,
                            BHloop(15,.44,.15),
                            BHloop(10,.345,.120),
                            SpecificPowerLossData(test_spldata)) # 3f3
test_cg = CoreGeometry("e14_set", 4e-3,     1.5e-3,   5e-3, 300e-9, 14.5e-6, 16.7e-3, 0.6e-3) # e14
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

e_core = core_geometry_dict["e14_set"]
plate = core_geometry_dict["e14_plt"]
material = ferrite_dict["3f4"]
layer1 = winding_layer(pcb,true,e_core,3)
layer2 = winding_layer(pcb,false,e_core,2)
layer3 = winding_layer(pcb,false,e_core,2)
layer4 = winding_layer(pcb,true,e_core,3)
primary = Winding(pcb,[layer1,layer4],false)
secondary = Winding(pcb,[layer2,layer3],true)
magnetics = Magnetics(material, e_core)
transformer = Transformer(magnetics,[primary,secondary])
v = volts(transformer,150e3,500e3)
@test v[1]≈2.2455612451812534
@test v[2]≈2.9940816602416715
ci = chan_inductor(transformer)
@test ci.hc ≈ 50.0
@test ci.bs ≈ 0.345
@test ci.br ≈ 0.14
@test ci.a ≈ 1.45e-5
@test ci.lm ≈ 0.0207
@test ci.lg ≈ 0.0
@test ci.n ≈ 1.0
testshow(ci,"Hc=50.0, Bs=0.345, Br=0.14, A=1.45e-5, Lm=0.0207, Lg=0.0, N=1.0\n")

winding_resistance_array = winding_resistance(transformer)
@test winding_resistance_array[1] ≈ 0.0015265864267914595
@test winding_resistance_array[2] ≈ 0.0027866178802512884
power = TransformerPowerDissipation(transformer, [2.0,5.0], 1e6)
@test power.flux_density ≈ 0.011494252873563218
@test power.total_power ≈ 0.14184113733295778
@test flux_density(magnetics,150e3,1e6) ≈ 0.031109516217764782
@test volt_seconds_per_turn(magnetics, 0.03) ≈ 4.3499999999999996e-7
@test volts_per_turn(magnetics, 150e3, 1e6) ≈ 0.9021759703151787
@test volts(primary,magnetics,150e3,1e6) ≈ 2.7065279109455362
@test equivalent_parallel_resistance(transformer,2.5) ≈ 11.205434539189257

end # testset
