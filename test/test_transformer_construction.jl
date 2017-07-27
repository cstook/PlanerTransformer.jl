@testset "transformer_construction" begin

# a few tests not dependent on dictionary
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
test_cg = CoreGeometry("e14_set", 4e-3, 4e-3,     1.5e-3,   5e-3, 300e-9, 14.5e-6, 16.7e-3, 0.6e-3) # e14
@test volt_seconds_per_turn(2.0,3.0)≈6.0
@test volt_seconds_per_turn(test_cg,2.0) ≈ 14.5e-6*2.0

# just use the dictionary's from here on
trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
outer = copper_weight_to_meters(2.0)
inner = copper_weight_to_meters(1.0)
@test inner ≈ 0.000035
dielectric = (1.6e-3-2*outer-2*inner)/4
stackup = Stackup([copper,fr408,copper,fr408,copper,fr408,copper],
                  [outer,dielectric,inner,dielectric,inner,dielectric,outer])
@test_throws(ArgumentError,  Stackup([copper,fr408,copper,fr408,copper,fr408,copper],
                  [dielectric,inner,dielectric,inner,dielectric,outer]))
@test_throws(ArgumentError,  Stackup([copper,fr408], [outer, dielectric]))
@test_throws(ArgumentError,  Stackup([copper,fr408,copper,fr408,copper,fr408],
                  [outer, dielectric,inner,dielectric,inner,dielectric]))
@test_throws(ArgumentError,  Stackup([copper,copper,fr408,fr408,copper,fr408,copper],
                  [outer, inner,dielectric,dielectric,inner,dielectric,outer]))
@test_throws(ArgumentError,  Stackup([fr408,fr408,fr408],
                  [dielectric,dielectric,dielectric]))


pcb = PCB_Specification(trace_edge_gap,
                        trace_trace_gap,
                        stackup)
core_geometry = core_geometry_dict["e14_set"]
primaryturnsperlayer=4
secondaryturnsperlayer=1
isprimaryeries = true
issecondaryseries = false
w1 = windings(pcb, core_geometry, primaryturnsperlayer, secondaryturnsperlayer,
             prisec"S-P-P-S", isprimaryeries, issecondaryseries)
w2 = windings(pcb, core_geometry, primaryturnsperlayer, secondaryturnsperlayer,
            prisec"S-P-S-P", isprimaryeries, issecondaryseries)
w3 = windings(pcb, core_geometry, primaryturnsperlayer, secondaryturnsperlayer,
            prisec"S-P-S-P", false, true)

@test_throws ArgumentError windings(pcb, core_geometry, primaryturnsperlayer, secondaryturnsperlayer,
            prisec"S-P-S", false, true)
@test_throws ArgumentError windings(pcb, core_geometry, primaryturnsperlayer, secondaryturnsperlayer,
            prisec"P-P-S-S", false, true)
@test_warn("WARNING: 30 on e14_set will result in negative trace width.  Setting to NaN.",
            windings(pcb, core_geometry, 30, secondaryturnsperlayer,prisec"S-P-P-S", false, true))
@test sides(w1) == (1.00, 1.00, 1.00, 1.00)
@test sides(w2) == (1.00, 2.00, 2.00, 1.00)
@test effective_volume(w1) == effective_volume(core(w1))
@test effective_area(w1) == effective_area(core(w1))
@test effective_length(w1) == effective_length(core(w1))
@test winding_aperture_height(w1) == winding_aperture_height(core(w1))
@test winding_aperture(w1) == winding_aperture(core(w1))

ferrite = ferrite_dict["3f4"]
t1 = Transformer(ferrite, w1)
t2 = Transformer(ferrite, w2)
t3 = Transformer(ferrite, w3)
@test volt_seconds_per_turn(t1, 150e3)≈2.175
@test volt_seconds_per_turn(t2, 150e3)≈2.175
@test volt_seconds_per_turn(t3, 150e3)≈2.175
@test turns(t1) == (8,1)
@test turns(t2) == (8,1)
@test turns(t3) == (4,2)
@test volt_seconds(t1, 150e3) == (17.4, 2.175)
@test volt_seconds(t2, 150e3) == (17.4, 2.175)
@test volt_seconds(t3, 150e3) == (8.7, 4.35)
@test PlanerTransformer.skin_depth(1.0,1e6)≈0.5032921210448703
@test winding_resistance(t1, 10e6, 100.0) == (0.2219529543698069, 0.004049950501870691)
@test winding_resistance(t2, 10e6, 100.0) == (0.18581080298513264, 0.00326219262241758)
@test winding_resistance(t3, 10e6, 100.0) == (0.044695193801413506, 0.013561874982728374)
@test winding_resistance(t1, 10e6, 0.0) == (0.18635546048254428, 0.003400407049550375)
@test winding_resistance(t1, 0.0, 0.0) == (0.10550990477236814, 0.0009626136606256183)
@test winding_resistance(t2, 0.0, 0.0) == (0.0791324285792761, 0.0012834848808341579)
@test PlanerTransformer.center_frequency(t1) == 1.5e6
testshow(chan_inductor(t1),"Hc=50.0, Bs=0.345, Br=0.14, A=1.45e-5, Lm=0.0207, Lg=0.0, N=1.0\n")
@test leakage_inductance(t1) ≈ 1.1175951096599809e-7
@test leakage_inductance(t2) ≈ 7.450634064399872e-8
@test leakage_inductance(t3) ≈ 1.862658516099968e-8
end # testset
