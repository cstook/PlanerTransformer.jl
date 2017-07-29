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
@test_throws ArgumentError PushPull(-v_in, i_out, frequency)
@test_throws ArgumentError PushPull(v_in, -i_out, frequency)
@test_throws ArgumentError PushPull(v_in, -i_out, -frequency)
duty = .25
c2 = Forward(v_in, i_out, frequency, duty)
@test_throws ArgumentError Forward(-v_in, i_out, frequency, duty)
@test_throws ArgumentError Forward(v_in, -i_out, frequency, duty)
@test_throws ArgumentError Forward(v_in, -i_out, -frequency, duty)

a_t1c1 = transformer_power_analysis(t1,c1)
@test flux_density(a_t1c1) ≈ 0.0031908618912421674
@test voltage(a_t1c1) == (15.0, 1.8223502434073622)
@test current(a_t1c1) == (0.8758650011589507, -7.0)
@test ac_winding_resistance(a_t1c1) == (0.2219529543698069, 0.004049950501870691)
@test dc_winding_resistance(a_t1c1) == (0.14966865160045842, 0.001365493494746748)
@test equilivent_resistance(a_t1c1) == (0.2219529543698069, 0.004049950501870691)
@test v_core(a_t1c1) ≈ 1.850699896920457
@test core_specific_power(a_t1c1) ≈ 42689.53481883259
@test core_total_power(a_t1c1) ≈ 0.012806860445649776
@test winding_power(a_t1c1) == (0.17026887849541192, 0.19844757459166384)
@test total_power(a_t1c1) ≈ 0.38152331353272556
@test r_core(a_t1c1) ≈ 267.44182331000746
@test input_power(a_t1c1) ≈ 13.13797501738426
@test output_power(a_t1c1) ≈ -12.756451703851535
@test abs(PlanerTransformer.power_error(a_t1c1))<1e-10

a_t1c2 = transformer_power_analysis(t1,c2)
@test flux_density(a_t1c2) ≈ 0.0015971423866341192
@test voltage(a_t1c2) == (15.0, 1.8290333147449505)
@test current(a_t1c2) == (0.875598425879627, -7.0)
@test ac_winding_resistance(a_t1c2) == (0.2219529543698069, 0.004049950501870691)
@test dc_winding_resistance(a_t1c2) == (0.14966865160045842, 0.001365493494746748)
@test equilivent_resistance(a_t1c2) == (0.20388187867746976, 0.003378836250089705)
@test v_core(a_t1c2) ≈ 1.8526851684955783
@test core_specific_power(a_t1c2) ≈ 7391.29834419259
@test core_total_power(a_t1c2) ≈ 0.0022173895032577768
@test winding_power(a_t1c2) == (0.0390776626780815, 0.04139074406359889)
@test total_power(a_t1c2) ≈ 0.08268579624493817
@test r_core(a_t1c2) ≈ 386.99136174774026
@test input_power(a_t1c2) ≈ 3.2834940970486013
@test output_power(a_t1c2) ≈ -3.200808300803663
@test abs(PlanerTransformer.power_error(a_t1c2))<1e-10

a_t2c1 = transformer_power_analysis(t2,c1)
@test flux_density(a_t2c1) ≈ 0.0031976841149601127
@test voltage(a_t2c1) == (15.0, 1.8318214383199423)
@test current(a_t2c1) == (0.8758678396008, -7.0)
@test ac_winding_resistance(a_t2c1) == (0.18581080298513264, 0.00326219262241758)
@test dc_winding_resistance(a_t2c1) == (0.11225148870034382, 0.001820657992995664)
@test equilivent_resistance(a_t2c1) == (0.18581080298513264, 0.00326219262241758)
@test v_core(a_t2c1) ≈ 1.8546567866768653
@test core_specific_power(a_t2c1) ≈ 42921.189476547006
@test core_total_power(a_t2c1) ≈ 0.012876356842964102
@test winding_power(a_t2c1) == (0.14254373043097793, 0.15984743849846142)
@test total_power(a_t2c1) ≈ 0.31526752577240347
@test r_core(a_t2c1) ≈  267.1370356007262
@test input_power(a_t2c1) ≈ 13.138017594011998
@test output_power(a_t2c1) ≈ -12.822750068239596
@test abs(PlanerTransformer.power_error(a_t2c1))<1e-10

a_t2c2 = transformer_power_analysis(t2,c2)
@test flux_density(a_t2c2) ≈ 0.0016005825568032011
@test voltage(a_t2c2) == (15.0, 1.8363631031362788)
@test current(a_t2c2) == (0.8756004041874144, -7.0)
@test ac_winding_resistance(a_t2c2) == (0.18581080298513264, 0.00326219262241758)
@test dc_winding_resistance(a_t2c2) == (0.11225148870034382, 0.001820657992995664)
@test equilivent_resistance(a_t2c2) == (0.16742097441393544, 0.002901808965062101)
@test v_core(a_t2c2) ≈ 1.8566757658917135
@test core_specific_power(a_t2c2) ≈ 7431.706030080913
@test core_total_power(a_t2c2) ≈ 0.0022295118090242738
@test winding_power(a_t2c2) == (0.032089413583281066, 0.03554715982201074)
@test total_power(a_t2c2) ≈ 0.06986608521431607
@test r_core(a_t2c2) ≈ 386.54705546931336
@test input_power(a_t2c2) ≈ 3.283501515702804
@test output_power(a_t2c2) ≈ -3.213635430488488
@test abs(PlanerTransformer.power_error(a_t2c2))<1e-10

a_t3c1 = transformer_power_analysis(t3,c1)
@test flux_density(a_t3c1) ≈ 0.006397992260147801
@test voltage(a_t3c1) == (15.0, 7.326737896892351)
@test current(a_t3c1) == (3.5050291347466387, -7.0)
@test ac_winding_resistance(a_t3c1) == (0.044695193801413506, 0.013561874982728374)
@test dc_winding_resistance(a_t3c1) == (0.024944775266743067, 0.00819296096848049)
@test equilivent_resistance(a_t3c1) == (0.044695193801413506, 0.013561874982728374)
@test v_core(a_t3c1) ≈ 3.7108355108857247
@test core_specific_power(a_t3c1) ≈ 248830.55742474739
@test core_total_power(a_t3c1) ≈ 0.0746491672274242
@test winding_power(a_t3c1) == (0.5490907015720118, 0.6645318741536903)
@test total_power(a_t3c1) ≈  1.2882717429531265
@test r_core(a_t3c1) ≈  184.46689628697774
@test input_power(a_t3c1) ≈ 52.57543702119958
@test output_power(a_t3c1) ≈ -51.287165278246455
@test abs(PlanerTransformer.power_error(a_t3c1))<1e-10

a_t3c2 = transformer_power_analysis(t3,c2)
@test flux_density(a_t3c2) ≈ 0.0032027392435911095
@test voltage(a_t3c2) == (15.0, 7.34481751977721)
@test current(a_t3c2) == (3.503479779660588, -7.0)
@test ac_winding_resistance(a_t3c2) == (0.044695193801413506, 0.013561874982728374)
@test dc_winding_resistance(a_t3c2) == (0.024944775266743067, 0.00819296096848049)
@test equilivent_resistance(a_t3c2) == (0.039757589167745896, 0.012219646479166403)
@test v_core(a_t3c2) ≈ 3.7151775225656873
@test core_specific_power(a_t3c2) ≈ 43093.33059499487
@test core_total_power(a_t3c2) ≈ 0.01292799917849846
@test winding_power(a_t3c2) == (0.12199984556880146, 0.14969066936978845)
@test total_power(a_t3c2) ≈ 0.2846185141170884
@test r_core(a_t3c2) ≈ 266.9118367352115
@test input_power(a_t3c2) ≈ 13.138049173727206
@test output_power(a_t3c2) ≈ -12.853430659610117
@test abs(PlanerTransformer.power_error(a_t3c2))<1e-10
end # testset
