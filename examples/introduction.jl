
#=
This module is based on the design procedure described in Designing Planar Magnetics.
The introduction approximatly follows the examples in this paper.


Load the module.
=#
using PlanerTransformer

#=
Define the operating frequency and maximum specific power loss for the transformer
=#
frequency = 0.5e6 # Hz
spl_max = 150e3 # W/m^3

#=
Standard core geometries are available in `core_geometry_dict`.
  An ER25 core / plate set will be used.
=#
core = core_geometry_dict["er25/5.5_plt"]

#=
The properities of some ferrites are available in `ferrite_dict`.  The functions
`specific_power_loss` and `flux_density` interpolate the specific power loss curves
from the data sheet.

Use `flux_density` to calculate the maximum flux density for given specific power loss
for two ferrites.
=#
flux_density_max_pp_3f35 = flux_density(ferrite_dict["3f35"], spl_max, frequency) * 2.0
flux_density_max_pp_r = flux_density(ferrite_dict["r"], spl_max, frequency) * 2.0

#=

Calculate volt seconds per turn.
=#
vspt_3f35 = volt_seconds_per_turn(core, flux_density_max_pp_3f35)
vspt_r = volt_seconds_per_turn(core, flux_density_max_pp_r)

#=

Maximum output voltage for forward converter with 1T secondary @ 50% duty cycle
=#
max_vo_3f35 = vspt_3f35 * frequency
max_vo_r = vspt_r * frequency
#=
Define the windings.

`PlanerTrnasformer` only allows transformers with two windings.  First the PCB
to be used for the windings is defined with `PCB_Specification`.  `windings` then
creats a `Windings` object.  All primary layers must have the same number of turns.
All secondary layers must have the same number of turns.  Primary and secondary layers
may be in series or parallel.  This transformer will be built with a double sided PCB
with 4oz copper.
=#
trace_edge_gap = 0.5e-3
trace_trace_gap = 0.4e-3
copper_thickness = copper_weight_to_meters(4.0) # 4.0oz copper
dielectric_thickness = 0.125e-3
stackup = Stackup((copper, fr408, copper),(copper_thickness, dielectric_thickness, copper_thickness))
pcb = PCB_Specification(trace_edge_gap,
                        trace_trace_gap,
                        stackup)
primary_turns_per_layer = 6
secondary_turns_per_layer = 1
is_layer_primary = (true, false) # which layers belong to primary and secondary
are_primary_layers_in_series = false
are_secondary_layers_in_series = false
my_windings = windings(pcb, core,
                    primary_turns_per_layer,
                    secondary_turns_per_layer,
                    is_layer_primary,
                    are_primary_layers_in_series,
                    are_secondary_layers_in_series)
#=
Maximum voltage at the output of the converter (not the peak voltage at the transformer output)
=#
max_volts = frequency.*volt_seconds(my_windings,flux_density_max_pp_3f35)
#=
Create a transformer by combining a ferrite with windings.
=#
transformer_3f35_2layer = Transformer(ferrite_dict["3f35"], my_windings)
#=
Verify 6:1 turns ratio.
=#
turns(transformer_3f35_2layer) # (primary, secondary)
#=
Laekage inductance is referenced to primary.
=#
leakage_inductance(transformer_3f35_2layer)
#=
Define parameters for the switching power supply using the transformer.  Power must flow
from primary to secondary (v_in positive, i_out negative).  Voltages and currents are
peak+ at the transformer, not the input and output of the switching power supply.
=#
v_in = 48.0
i_out = -7.0
duty = 0.50
my_converter = Forward(v_in, i_out, frequency, duty) # or PushPull
#=
Calculate power dissipation, and other stuff,  of a transformer in a
 switching power supply.    Voltages and currents are peak at the transformer,
not the input and output of the switching power supply.  Powers are averge.
=#
tpa = transformer_power_analysis(transformer_3f35_2layer, my_converter);
#=
Many parameters can be displayed
=#
voltage(tpa) # (primary, secondary)
current(tpa) # (primary, secondary)
input_power(tpa)
output_power(tpa)
ac_winding_resistance(tpa) # (primary, secondary)
dc_winding_resistance(tpa) # (primary, secondary)
equilivent_resistance(tpa) # (primary, secondary)
core_specific_power(tpa) # W/m^3
core_total_power(tpa)
winding_power(tpa) # (primary, secondary)
total_power(tpa)
#=
Total power dissipation with 20A output
=#
total_power(transformer_power_analysis(transformer_3f35_2layer, Forward(v_in,-20.0,frequency,duty)))
#=
The next three sections Double and interleave the Windings,
Copper strip secondary, and Primary in series are a series of improvments on
this transformer.
=#
#=
Double and interleave the Windings
=#

b_stage_thickness = 0.0762
double_stackup = Stackup((copper,           fr408,                copper,           fr408,             copper,           fr408,                copper),
                         (copper_thickness, dielectric_thickness, copper_thickness, b_stage_thickness, copper_thickness, dielectric_thickness, copper_thickness))
double_pcb = PCB_Specification(trace_edge_gap,
                               trace_trace_gap,
                               double_stackup)
double_windings = windings(double_pcb, core,
                           primary_turns_per_layer,
                           secondary_turns_per_layer,
                           prisec"S-P-P-S", # use prisec string to specify which layers are primary and secondary.
                           are_primary_layers_in_series,
                           are_secondary_layers_in_series)

double_transformer_3f35 = Transformer(ferrite_dict["3f35"], double_windings)
turns(double_transformer_3f35)
leakage_inductance(double_transformer_3f35)
double_tpa = transformer_power_analysis(double_transformer_3f35, my_converter)
equilivent_resistance(double_tpa) # (primary, secondary)
core_total_power(double_tpa)
winding_power(double_tpa) # (primary, secondary)
total_power(double_tpa)
total_power(transformer_power_analysis(double_transformer_3f35, Forward(v_in,-20.0,frequency,duty)))
#=
Copper strip secondary
=#
strip_stackup = Stackup((copper,           fr408,                copper,           fr408,             copper,           fr408,                copper),
                         (copper_thickness+1e-3, dielectric_thickness, copper_thickness, b_stage_thickness, copper_thickness, dielectric_thickness, copper_thickness+1e-3))
strip_pcb = PCB_Specification(trace_edge_gap,
                              trace_trace_gap,
                              strip_stackup)
strip_windings = windings(strip_pcb, core,
                          primary_turns_per_layer,
                          secondary_turns_per_layer,
                          prisec"S-P-P-S",
                          are_primary_layers_in_series,
                          are_secondary_layers_in_series)

strip_transformer_3f35 = Transformer(ferrite_dict["3f35"], strip_windings)
turns(strip_transformer_3f35)
leakage_inductance(strip_transformer_3f35)
strip_tpa = transformer_power_analysis(strip_transformer_3f35, my_converter)
equilivent_resistance(strip_tpa) # (primary, secondary)
core_total_power(strip_tpa)
winding_power(strip_tpa) # (primary, secondary)
total_power(strip_tpa)
total_power(transformer_power_analysis(strip_transformer_3f35, Forward(v_in,-20.0,frequency,duty)))
#=
Primary in series
=#
series_windings = windings(strip_pcb, core,
                          3, # turns per layer, primary
                          secondary_turns_per_layer,
                          prisec"S-P-P-S",
                          true, # primary layers are in series
                          are_secondary_layers_in_series)

series_transformer_3f35 = Transformer(ferrite_dict["3f35"], series_windings)
series_tpa = transformer_power_analysis(series_transformer_3f35, my_converter)
equilivent_resistance(series_tpa) # (primary, secondary)
core_total_power(series_tpa)
winding_power(series_tpa) # (primary, secondary)
total_power(series_tpa)
total_power(transformer_power_analysis(series_transformer_3f35, Forward(v_in,-20.0,frequency,duty)))
#=
LTspice model

Parameters for a cicuit simulation can be extracted.
=#
turns(series_transformer_3f35)
leakage_inductance(series_transformer_3f35)
chan_inductor(series_transformer_3f35)
equilivent_resistance(series_tpa)
