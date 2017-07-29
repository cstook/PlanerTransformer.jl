using PlanerTransformer

frequency = 0.5e6 # Hz
spl_max = 150e3 # W/m^3

core = core_geometry_dict["er25/5.5_plt"] #ER25 core / plate set

flux_density_max_pp_3f35 = flux_density(ferrite_dict["3f35"], spl_max, frequency) * 2.0
flux_density_max_pp_r = flux_density(ferrite_dict["r"], spl_max, frequency) * 2.0

vspt_3f35 = volt_seconds_per_turn(core, flux_density_max_pp_3f35)
vspt_r = volt_seconds_per_turn(core, flux_density_max_pp_r)

# max output voltage for forward converter with 1T secondary
max_vo_3f35 = vspt_3f35 * frequency
max_vo_r = vspt_r * frequency

# Forward converter windings

trace_edge_gap = 0.5e-3
trace_trace_gap = 0.4e-3
copper_thickness = copper_weight_to_meters(4.0)
dielectric_thickness = 0.125e-3
stackup = Stackup((copper, fr408, copper),(copper_thickness, dielectric_thickness, copper_thickness))
pcb = PCB_Specification(trace_edge_gap,
                        trace_trace_gap,
                        stackup)
primary_turns_per_layer = 6
secondary_turns_per_layer = 1
is_layer_primary = (true, false)
are_primary_layers_in_series = false
are_secondary_layers_in_series = false
my_windings = windings(pcb, core,
                    primary_turns_per_layer,
                    secondary_turns_per_layer,
                    is_layer_primary,
                    are_primary_layers_in_series,
                    are_secondary_layers_in_series)
max_volts = frequency.*volt_seconds(my_windings,flux_density_max_pp_3f35)

transformer_3f35_2layer = Transformer(ferrite_dict["3f35"], my_windings)

v_in = 48.0
i_out = -7.0
duty = 0.75
reset_voltage = v_in*duty/(1.0-duty)
# need to fix copper loss for forward converter
tpa = transformer_power_analysis(transformer_3f35_2layer, Forward(v_in, i_out, frequency, duty))
turns(tpa)
voltage(tpa)
current(tpa)
input_power(tpa)
output_power(tpa)
equilivent_resistance(tpa)
core_total_power(tpa)
winding_power(tpa)


# Double the Windings

b_stage_thickness = 0.0762
double_stackup = Stackup((copper,           fr408,                copper,           fr408,             copper,           fr408,                copper),
                         (copper_thickness, dielectric_thickness, copper_thickness, b_stage_thickness, copper_thickness, dielectric_thickness, copper_thickness))
double_pcb = PCB_Specification(trace_edge_gap,
                               trace_trace_gap,
                               double_stackup)
double_windings = windings(double_pcb, core,
                           primary_turns_per_layer,
                           secondary_turns_per_layer,
                           (true, true, false, false),
                           are_primary_layers_in_series,
                           are_secondary_layers_in_series)

double_transformer_3f35 = Transformer(ferrite_dict["3f35"], double_windings)
double_transformer_r = Transformer(ferrite_dict["r"], double_windings)
double_tpa = transformer_power_analysis(double_transformer_3f35, Forward(), v_in, i_out, frequency)

# Interleave the windings
interleave_windings = windings(double_pcb, core,
                              primary_turns_per_layer,
                              secondary_turns_per_layer,
                              (false, true, true, false),
                              are_primary_layers_in_series,
                              are_secondary_layers_in_series)

interleave_transformer_3f35 = Transformer(ferrite_dict["3f35"], double_windings)
interleave_transformer_r = Transformer(ferrite_dict["r"], double_windings)
interleave_tpa = transformer_power_analysis(interleave_transformer_3f35, Forward(), v_in, i_out, frequency)

# copper strip secondary
strip_stackup = Stackup((copper,           fr408,                copper,           fr408,             copper,           fr408,                copper),
                         (copper_thickness+1e-3, dielectric_thickness, copper_thickness, b_stage_thickness, copper_thickness, dielectric_thickness, copper_thickness+1e-3))
strip_pcb = PCB_Specification(trace_edge_gap,
                              trace_trace_gap,
                              strip_stackup)
strip_windings = windings(strip_pcb, core,
                          primary_turns_per_layer,
                          secondary_turns_per_layer,
                          (false, true, true, false),
                          are_primary_layers_in_series,
                          are_secondary_layers_in_series)

strip_transformer_3f35 = Transformer(ferrite_dict["3f35"], strip_windings)
strip_transformer_r = Transformer(ferrite_dict["r"], strip_windings)
strip_tpa = transformer_power_analysis(strip_transformer_3f35, Forward(), v_in, i_out, frequency)

# primary in series
series_windings = windings(strip_pcb, core,
                          3,
                          secondary_turns_per_layer,
                          (false, true, true, false),
                          true,
                          are_secondary_layers_in_series)

series_transformer_3f35 = Transformer(ferrite_dict["3f35"], series_windings)
series_transformer_r = Transformer(ferrite_dict["r"], series_windings)
series_tpa = transformer_power_analysis(series_transformer_3f35, Forward(), v_in, i_out, frequency)



turns(series_transformer_3f35)
