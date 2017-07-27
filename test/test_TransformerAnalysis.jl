@testset "TransformerAnalysis" begin

trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
outer = copper_weight_to_meters(2.0)
inner = copper_weight_to_meters(1.0)
dielectric = (1.6e-3-2*outer-2*inner)/4
stackup = Stackup([copper,fr408,copper,fr408,copper,fr408,copper],
                  [outer,dielectric,inner,dielectric,inner,dielectric,outer])
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
ferrite = ferrite_dict["4f1"]
t1 = Transformer(ferrite, w1)
t2 = Transformer(ferrite, w2)
t3 = Transformer(ferrite, w3)
@test PlanerTransformer.layer_resistance_tuple(windings(t1)) ==
  (0.002730986989493496, 0.07483432580022921, 0.07483432580022921, 0.002730986989493496)
@test PlanerTransformer.layer_resistance_tuple(windings(t2)) ==
  (0.002730986989493496, 0.07483432580022921, 0.005461973978986992, 0.037417162900114605)
@test PlanerTransformer.layer_resistance_tuple(windings(t3)) ==
  (0.002730986989493496, 0.07483432580022921, 0.005461973978986992, 0.037417162900114605)

frequency = 10e6
v_in = 15.0
i_out = -7.0
c1 = PushPull(v_in, i_out, frequency)
duty = .25
reset_voltage = -1.5*v_in*duty/(1-duty)
c2 = Forward(v_in, i_out, frequency, duty, reset_voltage)
@test_throws ArgumentError Forward(v_in, i_out, frequency, duty, 0.0)

a_t1c1 = transformer_power_analysis(t1,c1)
@test flux_density(a_t1c1) ≈ 0.006381327323393287
@test voltage(a_t1c1) == (15.0, 1.8222352702709583)
@test current(a_t1c1) == (0.8800090554421738, -7.00)
@test ac_winding_resistance(a_t1c1) == (0.2219529543698069, 0.004049950501870691)
@test dc_winding_resistance(a_t1c1) == (0.14966865160045842, 0.001365493494746748)
@test equilivent_resistance(a_t1c1) == (0.2219529543698069, 0.004049950501870691)
@test v_core(a_t1c1) ≈ 1.8505849237840533
@test core_specific_power(a_t1c1) ≈ 247191.53289827605
@test core_total_power(a_t1c1) ≈ 0.07415745986948281
@test winding_power(a_t1c1) == (0.17188390527475156, 0.19844757459166384)
@test total_power(a_t1c1) ≈ 0.4444889397358982
@test r_core(a_t1c1) ≈ 46.18098524631564
@test input_power(a_t1c1) ≈ 13.200135831632608
@test output_power(a_t1c1) ≈ -12.755646891896708
@test abs(PlanerTransformer.power_error(a_t1c1))<1e-10

a_t1c2 = transformer_power_analysis(t1,c2)
@test flux_density(a_t1c2) ≈ 0.0024053080832590517
@test voltage(a_t1c2) == (15.0, 1.8290055228298725)
@test current(a_t1c2) == (0.8766889363363007, -7.00)
@test ac_winding_resistance(a_t1c2) == (0.2219529543698069, 0.004049950501870691)
@test dc_winding_resistance(a_t1c2) == (0.14966865160045842, 0.001365493494746748)
@test equilivent_resistance(a_t1c2) == (0.20388187867746976, 0.003378836250089705)
@test v_core(a_t1c2) ≈ 1.8526573765805003
@test core_specific_power(a_t1c2) ≈ 20860.135746816588
@test core_total_power(a_t1c2) ≈ 0.006258040724044976
@test winding_power(a_t1c2) == (0.03917506152120744, 0.04139074406359889)
@test total_power(a_t1c2) ≈ 0.08682384630885132
@test r_core(a_t1c2) ≈ 137.11717078678578
@test input_power(a_t1c2) ≈ 3.287583511261128
@test output_power(a_t1c2) ≈ -3.200759664952277
@test abs(PlanerTransformer.power_error(a_t1c2))<1e-10

a_t2c1 = transformer_power_analysis(t2,c1)
@test flux_density(a_t2c1) ≈ 0.0063950352337161995
@test voltage(a_t2c1) == (15.0, 1.8317248694207748)
@test current(a_t2c1) == (0.8800255698346087, -7.0)
@test ac_winding_resistance(a_t2c1) == (0.18581080298513264, 0.00326219262241758)
@test dc_winding_resistance(a_t2c1) == (0.11225148870034382, 0.001820657992995664)
@test equilivent_resistance(a_t2c1) == (0.18581080298513264, 0.00326219262241758)
@test v_core(a_t2c1) ≈ 1.8545602177776979
@test core_specific_power(a_t2c1) ≈ 248539.25031810263
@test core_total_power(a_t2c1) ≈ 0.07456177509543079
@test winding_power(a_t2c1) == (0.14390024797981435, 0.15984743849846142)
@test total_power(a_t2c1) ≈ 0.37830946157370654
@test r_core(a_t2c1) ≈  46.12810782685391
@test input_power(a_t2c1) ≈ 13.200383547519131
@test output_power(a_t2c1) ≈ -12.822074085945424
@test abs(PlanerTransformer.power_error(a_t2c1))<1e-10

a_t2c2 = transformer_power_analysis(t2,c2)
@test flux_density(a_t2c2) ≈ 0.0024087525288343926
@test voltage(a_t2c2) == (15.0, 1.8363402706924612)
@test current(a_t2c2) == (0.8766914237038164, -7.0)
@test ac_winding_resistance(a_t2c2) == (0.18581080298513264, 0.00326219262241758)
@test dc_winding_resistance(a_t2c2) == (0.11225148870034382, 0.001820657992995664)
@test equilivent_resistance(a_t2c2) == (0.16742097441393544, 0.002901808965062101)
@test v_core(a_t2c2) ≈ 1.8566529334478958
@test core_specific_power(a_t2c2) ≈ 20935.91187595939
@test core_total_power(a_t2c2) ≈ 0.006280773562787817
@test winding_power(a_t2c2) == (0.03216943179270573, 0.03554715982201074)
@test total_power(a_t2c2) ≈ 0.07399736517750428
@test r_core(a_t2c2) ≈ 137.2108101342935
@test input_power(a_t2c2) ≈ 3.2875928388893114
@test output_power(a_t2c2) ≈ -3.2135954737118073
@test abs(PlanerTransformer.power_error(a_t2c2))<1e-10

a_t3c1 = transformer_power_analysis(t3,c1)
@test flux_density(a_t3c1) ≈ 0.012795056202961275
@test voltage(a_t3c1) == (15.0, 7.326199472838441)
@test current(a_t3c1) == (3.5291222869679704, -7.0)
@test ac_winding_resistance(a_t3c1) == (0.044695193801413506, 0.013561874982728374)
@test dc_winding_resistance(a_t3c1) == (0.024944775266743067, 0.00819296096848049)
@test equilivent_resistance(a_t3c1) == (0.044695193801413506, 0.013561874982728374)
@test v_core(a_t3c1) ≈ 3.7105662988587698
@test core_specific_power(a_t3c1) ≈ 1.4408023542539394e6
@test core_total_power(a_t3c1) ≈ 0.4322407062761818
@test winding_power(a_t3c1) == (0.5566654142206001, 0.6645318741536903)
@test total_power(a_t3c1) ≈  1.653437994650472
@test r_core(a_t3c1) ≈  31.853321675421203
@test input_power(a_t3c1) ≈ 52.93683430451956
@test output_power(a_t3c1) ≈ -51.28339630986909
@test abs(PlanerTransformer.power_error(a_t3c1))<1e-10

a_t3c2 = transformer_power_analysis(t3,c2)
@test flux_density(a_t3c2) ≈ 0.004819064408844281
@test voltage(a_t3c2) == (15.0, 7.344691903164567)
@test current(a_t3c2) == (3.509798905909042, -7.0)
@test ac_winding_resistance(a_t3c2) == (0.044695193801413506, 0.013561874982728374)
@test dc_winding_resistance(a_t3c2) == (0.024944775266743067, 0.00819296096848049)
@test equilivent_resistance(a_t3c2) == (0.039757589167745896, 0.012219646479166403)
@test v_core(a_t3c2) ≈ 3.715114714259366
@test core_specific_power(a_t3c2) ≈ 121346.86508774928
@test core_total_power(a_t3c2) ≈ 0.03640405952632478
@test winding_power(a_t3c2) == (0.12244033772480128, 0.14969066936978845)
@test total_power(a_t3c2) ≈ 0.30853506662091446
@test r_core(a_t3c2) ≈ 94.78391640721956
@test input_power(a_t3c2) ≈ 13.161745897158907
@test output_power(a_t3c2) ≈ -12.853210830537993
@test abs(PlanerTransformer.power_error(a_t3c2))<1e-10
end # testset
