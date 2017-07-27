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

frequency = 10e6
v_in = 15.0
i_out = -7.0
c1 = PushPull(v_in, i_out, frequency)
duty = .25
reset_voltage = -1.5*v_in*duty/(1-duty)
c2 = Forward(v_in, i_out, frequency, duty, reset_voltage)

a_t1c1 = transformer_power_analysis(t1,c1)
@test flux_density(a_t1c1) ≈ 0.006381327323393287
@test voltage(a_t1c1) == (15.0, 1.7938856167578636)
@test current(a_t1c1) == (0.8800090554421738, -7.00)
@test ac_winding_resistance(a_t1c1) == (0.2219529543698069, 0.008099901003741382)
@test dc_winding_resistance(a_t1c1) == (0.14966865160045842, 0.002730986989493496)
@test equilivent_resistance(a_t1c1) == (0.2219529543698069, 0.008099901003741382)
@test v_core(a_t1c1) ≈ 1.8505849237840533
@test core_specific_power(a_t1c1) ≈ 247191.53289827605
@test core_total_power(a_t1c1) ≈ 0.07415745986948281
@test winding_power(a_t1c1) == (0.17188390527475156, 0.3968951491833277)
@test total_power(a_t1c1) ≈ 0.6429365143275622
@test r_core(a_t1c1) ≈ 46.18098524631564
@test input_power(a_t1c1) ≈ 13.200135831632608
@test output_power(a_t1c1) ≈ -12.557199317305045
@test abs(PlanerTransformer.power_error(a_t1c1))<1e-15

a_t1c2 = transformer_power_analysis(t1,c2)
@test flux_density(a_t1c2) ≈ 0.0024053080832590517
@test voltage(a_t1c2) == (15.0, 1.8053536690792444)
@test current(a_t1c2) == (0.8766889363363007, -7.00)
@test ac_winding_resistance(a_t1c2) == (0.2219529543698069, 0.008099901003741382)
@test dc_winding_resistance(a_t1c2) == (0.14966865160045842, 0.002730986989493496)
@test equilivent_resistance(a_t1c2) == (0.20388187867746976, 0.00675767250017941)
@test v_core(a_t1c2) ≈ 1.8526573765805003
@test core_specific_power(a_t1c2) ≈ 20860.135746816588
@test core_total_power(a_t1c2) ≈ 0.006258040724044976
@test winding_power(a_t1c2) == (0.03917506152120744, 0.08278148812719778)
@test total_power(a_t1c2) ≈ 0.1282145903724502
@test r_core(a_t1c2) ≈ 137.11717078678578
@test input_power(a_t1c2) ≈ 3.287583511261128
@test output_power(a_t1c2) ≈ -3.159368920888678
@test abs(PlanerTransformer.power_error(a_t1c2))<1e-15

end # testset
