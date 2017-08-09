var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#PlanerTransformer.jl-1",
    "page": "Home",
    "title": "PlanerTransformer.jl",
    "category": "section",
    "text": "Use Julia to design planer transformers"
},

{
    "location": "install/#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "install/#Installation-1",
    "page": "Installation",
    "title": "Installation",
    "category": "section",
    "text": "PlanerTransformer is currently unregistered.  It can be installed using Pkg.clone.Pkg.clone(\"https://github.com/cstook/PlanerTransformer.jl.git\")The julia documentation section on installing unregistered packages provides more information.PlanerTransformer is compatible with julia v0.6."
},

{
    "location": "introduction/#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "introduction/#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": "This module is based on the design procedure described in Designing Planar Magnetics. The paper uses a 500kHz forward converter with 48V input and 2.5V output as an example of the design procedure.  This introduction will use the same example to introduce the PlanerTransformer API.Load the module.using PlanerTransformerDefine the operating frequency and maximum specific power loss for the transformerfrequency = 0.5e6 # Hz\nspl_max = 150e3 # W/m^3\nnothing # hideStandard core geometries are available in core_geometry_dict.   An ER25 core / plate set will be used.core = core_geometry_dict[\"er25/5.5_plt\"]\nnothing # hideThe properities of some ferrites are available in ferrite_dict.ferrite = ferrite_dict[\"3f35\"]\nnothing # hideThe functions specific_power_loss and flux_density interpolate the specific power loss curves from the data sheet.flux_density returns the maximum flux density for given specific power loss for two ferrites.flux_density_max_pp = flux_density(ferrite, spl_max, frequency) * 2.0 # TeslaCalculate volt seconds per turn.vspt = volt_seconds_per_turn(core, flux_density_max_pp)Maximum output voltage for forward converter with 1T secondary.duty = 0.5 # 50% maximum duty cycle\nt_on = duty/frequency\nv_peak_at_transformer_1t = vspt/t_on # always work with peak I,V at transformer\nv_out_forward_converter = v_peak_at_transformer_1t * duty #  vspt * frequency"
},

{
    "location": "introduction/#Transformer-with-Double-Sided-PCB-1",
    "page": "Introduction",
    "title": "Transformer with Double Sided PCB",
    "category": "section",
    "text": "Start by defining the  PCB with PCB_Specification.  This transformer will be built with a double sided PCB with 4oz copper.trace_edge_gap = 0.5e-3\ntrace_trace_gap = 0.4e-3\ncopper_thickness = copper_weight_to_meters(4.0) # 4.0oz copper\ndielectric_thickness = 0.125e-3\nstackup = Stackup((copper,           fr408,                copper),\n                  (copper_thickness, dielectric_thickness, copper_thickness))\npcb = PCB_Specification(trace_edge_gap,\n                        trace_trace_gap,\n                        stackup)\nnothing # hideSpecify the windings.  PlanerTransformer only allows transformers with two windings. All primary layers must have the same number of turns.  All secondary layers must have the same number of turns.  Primary and secondary layers may be in series or parallel.  For this transformer, the primary is a single layer with 6 turns. The secondary is a single layer with 1 turn.primary_turns_per_layer = 6\nsecondary_turns_per_layer = 1\nis_layer_primary = (true, false) # which layers belong to primary and secondary\nare_primary_layers_in_series = false\nare_secondary_layers_in_series = false\nmy_windings = windings(pcb, core,\n                       primary_turns_per_layer,\n                       secondary_turns_per_layer,\n                       is_layer_primary,\n                       are_primary_layers_in_series,\n                       are_secondary_layers_in_series)\nnothing # hidevolt_seconds returns a tuple of the maximum volt seconds on (primary, secondary) to stay within the core flux density peak-peak.Maximum voltage at the input output of the converter.max_volts_transformer_peak = volt_seconds(my_windings,flux_density_max_pp)./t_on\n(input, output) = (max_volts_transformer_peak[1], max_volts_transformer_peak[2]*duty)Create a transformer by combining a ferrite with windings.transformer_3f35_2layer = Transformer(ferrite, my_windings)\nnothing # hideVerify 6:1 turns ratio.turns(transformer_3f35_2layer) # (primary, secondary)Leakage inductance is referenced to primary.leakage_inductance(transformer_3f35_2layer)To calculate power dissipation, the operating conditions must be specified.Define parameters for the switching power supply using the transformer.  Power must flow from primary to secondary (v_in positive, i_out negative).v_in = 48.0\ni_out = -7.0\nduty = 0.50\nmy_converter = Forward(v_in, i_out, frequency, duty) # or PushPull\nnothing # hidenote: Note\nWithin PlanerTrnasformer Voltages and currents are peak at the transformer, and powers are averages. They are not the DC input and output of the switching power supply.Calculate power dissipation, and other stuff,  of a transformer in a  switching power supply.tpa = transformer_power_analysis(transformer_3f35_2layer, my_converter)\nnothing # hideMany parameters can be displayedvoltage(tpa) # (primary, secondary)current(tpa) # (primary, secondary)input_power(tpa)output_power(tpa)ac_winding_resistance(tpa) # (primary, secondary)dc_winding_resistance(tpa) # (primary, secondary)equilivent_resistance(tpa) # (primary, secondary)core_specific_power(tpa) # W/m^3core_total_power(tpa)winding_power(tpa) # (primary, secondary)total_power(tpa)Total power dissipation with 20A outputconverter_20 =  Forward(v_in,-20.0,frequency,duty) # same as above, except 20A\ntotal_power(transformer_power_analysis(transformer_3f35_2layer, converter_20))The next three sections Double and Interleave the Windings, Copper Strip Secondary, and Primary in Series are a series of improvements on this transformer."
},

{
    "location": "introduction/#Double-and-Interleave-the-Windings-1",
    "page": "Introduction",
    "title": "Double and Interleave the Windings",
    "category": "section",
    "text": "b_stage_thickness = 0.0762\ndouble_stackup = Stackup((copper,           fr408,                copper,           fr408,             copper,\n                         fr408,                copper),\n                         (copper_thickness, dielectric_thickness, copper_thickness, b_stage_thickness, copper_thickness, dielectric_thickness, copper_thickness))\ndouble_pcb = PCB_Specification(trace_edge_gap,\n                               trace_trace_gap,\n                               double_stackup)\ndouble_windings = windings(double_pcb, core,\n                           primary_turns_per_layer,\n                           secondary_turns_per_layer,\n                           prisec\"S-P-P-S\", # use prisec string to specify which layers are primary and secondary.\n                           are_primary_layers_in_series,\n                           are_secondary_layers_in_series)\n\ndouble_transformer_3f35 = Transformer(ferrite_dict[\"3f35\"], double_windings)\ndouble_tpa = transformer_power_analysis(double_transformer_3f35, my_converter)\ntotal_power(transformer_power_analysis(double_transformer_3f35, converter_20))"
},

{
    "location": "introduction/#Copper-Strip-Secondary-1",
    "page": "Introduction",
    "title": "Copper Strip Secondary",
    "category": "section",
    "text": "strip_stackup = Stackup((copper,                 fr408,                copper,           fr408,             copper,\n                         fr408,                copper),\n                         (copper_thickness+1e-3, dielectric_thickness, copper_thickness, b_stage_thickness, copper_thickness, dielectric_thickness, copper_thickness+1e-3))\nstrip_pcb = PCB_Specification(trace_edge_gap,\n                              trace_trace_gap,\n                              strip_stackup)\nstrip_windings = windings(strip_pcb, core,\n                          primary_turns_per_layer,\n                          secondary_turns_per_layer,\n                          prisec\"S-P-P-S\",\n                          are_primary_layers_in_series,\n                          are_secondary_layers_in_series)\n\nstrip_transformer_3f35 = Transformer(ferrite_dict[\"3f35\"], strip_windings)\nstrip_tpa = transformer_power_analysis(strip_transformer_3f35, my_converter)\ntotal_power(transformer_power_analysis(strip_transformer_3f35, converter_20))"
},

{
    "location": "introduction/#Primary-in-Series-1",
    "page": "Introduction",
    "title": "Primary in Series",
    "category": "section",
    "text": "series_windings = windings(strip_pcb, core,\n                          3, # turns per layer, primary\n                          secondary_turns_per_layer,\n                          prisec\"S-P-P-S\",\n                          true, # primary layers are in series\n                          are_secondary_layers_in_series)\n\nseries_transformer_3f35 = Transformer(ferrite_dict[\"3f35\"], series_windings)\nseries_tpa = transformer_power_analysis(series_transformer_3f35, my_converter)\ntotal_power(transformer_power_analysis(series_transformer_3f35, converter_20))"
},

{
    "location": "introduction/#LTspice-Model-1",
    "page": "Introduction",
    "title": "LTspice Model",
    "category": "section",
    "text": "Parameters for a circuit simulation can be extracted.(n1, n2) = turns(series_transformer_3f35)l2 = leakage_inductance(series_transformer_3f35)l1 = chan_inductor(series_transformer_3f35)c1 = c2 = 0.5*capacitance(series_transformer_3f35)(r1, r2) = equilivent_resistance(series_tpa)r3 = r_core(series_tpa)(Image: LTspice transformer model)"
},

{
    "location": "design_api/#",
    "page": "Design API",
    "title": "Design API",
    "category": "page",
    "text": ""
},

{
    "location": "design_api/#Design-1",
    "page": "Design API",
    "title": "Design",
    "category": "section",
    "text": "note: Note\nAll fields of structs can be accessed as functions."
},

{
    "location": "design_api/#PlanerTransformer.Stackup",
    "page": "Design API",
    "title": "PlanerTransformer.Stackup",
    "category": "Type",
    "text": "Stackup(material,thickness)\n\nSpecify the PCB stackup.\n\nexample: for double sided FR408 PCB with 1oz copper 63mil thick. Stackup([copper,fr408,copper],[0.48e-3,1.6e-3 - (2*0.48e-3),0.48e-3])\n\ncopper and fr408 are exported constants.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.LayerMaterial",
    "page": "Design API",
    "title": "PlanerTransformer.LayerMaterial",
    "category": "Type",
    "text": "LayerMaterial\n\nSubtypes of LayerMaterial hold the material properties for the layers of the PCB.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.Dielectric",
    "page": "Design API",
    "title": "PlanerTransformer.Dielectric",
    "category": "Type",
    "text": "Dielectric(name, ϵ)\n\nFields\n\nname    – name of the material\nϵ       – permittivity\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.Conductor",
    "page": "Design API",
    "title": "PlanerTransformer.Conductor",
    "category": "Type",
    "text": "Conductor(name, ρ, tc)\n\nFields\n\nname  – name of the material\nρ_20  – conductivity at 20C\ntc    – temperature coefficient\n\nsee constant copper as example.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.copper_weight_to_meters",
    "page": "Design API",
    "title": "PlanerTransformer.copper_weight_to_meters",
    "category": "Function",
    "text": "copper_weight_to_meters(oz)\n\nPCB copper thickness is typicaly given in ounces.  This function multiplies by 35e-6 to give thickness in meters.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.PCB_Specification",
    "page": "Design API",
    "title": "PlanerTransformer.PCB_Specification",
    "category": "Type",
    "text": "PCB_Specification(trace_edge_gap  :: Float64,\n                  trace_trace_gap :: Float64,\n                  stackup         :: Stackup)\n\nStore PCB data.\n\nFields\n\ntrace_edge_gap          – minimum distance from trace to PCB edge (m)\ntrace_trace_gap         – minimum distance between traces (m)\nstackup                 – defines material and thickness of the layers\n\n\n\n"
},

{
    "location": "design_api/#PCB-1",
    "page": "Design API",
    "title": "PCB",
    "category": "section",
    "text": "Stackup\nLayerMaterial\nDielectric\nConductor\ncopper_weight_to_meters\nPCB_Specification"
},

{
    "location": "design_api/#PlanerTransformer.Windings",
    "page": "Design API",
    "title": "PlanerTransformer.Windings",
    "category": "Type",
    "text": "Windings\n\nFields\n\npcb                     – PCB_Specification\ncore                    – CoreGeometry\nprimarywindinggeometry  – WindingGeometry for all layers of primary\nsecondarywindinggeometry– WindingGeometry for all layers of secondary\nisprimary               – tuple of Bool for each conductor layer\nsides                   – for internal use\nisprimaryseries         – true if primary is connected in series\nissecondaryseries       – true if secondary is connected in series\n\nCreate Windings objects with windings.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.windings",
    "page": "Design API",
    "title": "PlanerTransformer.windings",
    "category": "Function",
    "text": "windings(pcb, core,\n        primaryturnsperlayer, secondaryturnsperlayer,\n        isprimary,\n        isprimaryeries, issecondaryseries)\n\nCreate a Windings object.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.WindingGeometry",
    "page": "Design API",
    "title": "PlanerTransformer.WindingGeometry",
    "category": "Type",
    "text": "WindingGeometry\n\n2D representation of one layer of a winding.\n\nFields\n\nwidth   – width of trace (m)\nlength  – length of trace (m)\nturns   – number of turns\n\nWindingGeometry objects are typicaly created with winding_geometry\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.winding_resistance",
    "page": "Design API",
    "title": "PlanerTransformer.winding_resistance",
    "category": "Function",
    "text": "winding_resistance(x :: Windings, frequency=0.0, temperature=100.0)\nwinding_resistance(x :: Transformer, frequency=0.0, temperature=100.0)\nwinding_resistance(x :: TransformerPowerAnalysis, frequency=0.0)\n\nReturns tuple (primary_resistance, secondary_resistance)\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.turns",
    "page": "Design API",
    "title": "PlanerTransformer.turns",
    "category": "Function",
    "text": "turns(x :: WindingGeometry)\nturns(x :: Windings)\nturns(x :: Transformer)\nturns(x :: TransformerPowerAnalysis)\n\nNumber of turns, Tuple for objects with two windings.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.capacitance",
    "page": "Design API",
    "title": "PlanerTransformer.capacitance",
    "category": "Function",
    "text": "capacitance(x)\n\nCapacitance between primary and secondary.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.leakage_inductance",
    "page": "Design API",
    "title": "PlanerTransformer.leakage_inductance",
    "category": "Function",
    "text": "leakage_inductance(x)\n\nLeakage inductance from volume between primary and secondary, referenced to primary.  Fringing fields are not taken into account.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.does_pcb_fit",
    "page": "Design API",
    "title": "PlanerTransformer.does_pcb_fit",
    "category": "Function",
    "text": "does_pcb_fit(t)\n\ntrue if PCB thickness is <= winding aperature height.\n\n\n\n"
},

{
    "location": "design_api/#Windings-1",
    "page": "Design API",
    "title": "Windings",
    "category": "section",
    "text": "Windings\nwindings\nWindingGeometry\nwinding_resistance\nturns\ncapacitance\nleakage_inductance\ndoes_pcb_fit"
},

{
    "location": "design_api/#PlanerTransformer.Transformer",
    "page": "Design API",
    "title": "PlanerTransformer.Transformer",
    "category": "Type",
    "text": "Transformer(ferrite, windings)\n\nFields\n\nferrite   – FerriteProperties object\nwindings  – Windings object\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.volt_seconds_per_turn",
    "page": "Design API",
    "title": "PlanerTransformer.volt_seconds_per_turn",
    "category": "Function",
    "text": "volt_seconds_per_turn(effective_area, flux_density_pp)\nvolt_seconds_per_turn(x ::CoreGeometry, flux_density_pp)\nvolt_seconds_per_turn(x ::Windings, flux_density_pp)\nvolt_seconds_per_turn(x ::Transformer, flux_density_pp)\nvolt_seconds_per_turn(x ::TransformerPowerAnalysis, flux_density_pp)\nvolt_seconds_per_turn(x ::TransformerPowerAnalysis)\n\nVolt seconds per turn at flux_density_pp.  The first form is just an alias for multiply.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.volt_seconds",
    "page": "Design API",
    "title": "PlanerTransformer.volt_seconds",
    "category": "Function",
    "text": "volt_seconds(x :: Windings, flux_density_pp)\nvolt_seconds(x :: Transformer, flux_density_pp)\nvolt_seconds(x :: TransformerPowerAnalysis, flux_density_pp)\nvolt_seconds(x :: TransformerPowerAnalysis)\n\nVolt seconds at flux_density_pp.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.flux_density",
    "page": "Design API",
    "title": "PlanerTransformer.flux_density",
    "category": "Function",
    "text": "flux_density(spl::SpecificPowerLossData, coreloss, frequency)\nflux_density(fp::FerriteProperties, coreloss, frequency)\nflux_density(t::Transformer, coreloss, frequency)\nflux_density(tpa::TransformerPowerAnalysis)\n\nReturns magnetic field strength in Tesla.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.specific_power_loss",
    "page": "Design API",
    "title": "PlanerTransformer.specific_power_loss",
    "category": "Function",
    "text": "specific_power_loss(spl::SpecificPowerLossData, flux_density, frequency)\nspecific_power_loss(fp::FerriteProperties, flux_density, frequency)\nspecific_power_loss(t::Transformer, flux_density, frequency)\nspecific_power_loss(tpa::TransformerPowerAnalysis)\n\nReturns specific power loss.\n\n\n\n"
},

{
    "location": "design_api/#Transformer-1",
    "page": "Design API",
    "title": "Transformer",
    "category": "section",
    "text": "Transformer\nvolt_seconds_per_turn\nvolt_seconds\nflux_density\nspecific_power_loss"
},

{
    "location": "design_api/#PlanerTransformer.TransformerPowerAnalysis",
    "page": "Design API",
    "title": "PlanerTransformer.TransformerPowerAnalysis",
    "category": "Type",
    "text": "TransformerPowerAnalysis\n\nObject to store the result of a transformer_power_analysis().\n\nFields\n\ntransformer             – from input\nconverter               – type of converter.\nflux_density            – peak flux density in Tesla\nvoltage                 – (primary, secondary) Vpp\ncurrent                 – (promary, secondary) Ipp\nac_winding_resistance   – (primary, secondary) Ω\ndc_winding_resistance   – (primary, secondary) Ω\nequilivent_resistance   – (primary, secondary) Ω\nv_core                  – voltage, after drop accross input resistance, referenced to 1 turn\ncore_specific_power     – power dissipated in core in W/m^3\ncore_total_power        – power dissipated in core in W\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.transformer_power_analysis",
    "page": "Design API",
    "title": "PlanerTransformer.transformer_power_analysis",
    "category": "Function",
    "text": "TransformerPowerAnalysis(t::Transformer,\n                         c::Converter)\n\nDetermine the losses of a transformer.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.winding_power",
    "page": "Design API",
    "title": "PlanerTransformer.winding_power",
    "category": "Function",
    "text": "winding_power(tpa::TransformerPowerAnalysis)\n\nPower dissipation due to windign resistance.  Tuple (primary, secondary).\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.total_power",
    "page": "Design API",
    "title": "PlanerTransformer.total_power",
    "category": "Function",
    "text": "total_power(tpa::TransformerPowerAnalysis)\n\nTotal power dissipation of transformer.  Sum of winding and core losses.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.input_power",
    "page": "Design API",
    "title": "PlanerTransformer.input_power",
    "category": "Function",
    "text": "input_power(tpa::TransformerPowerAnalysis)\n\nAverage power delivered to the primary of the transformer.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.output_power",
    "page": "Design API",
    "title": "PlanerTransformer.output_power",
    "category": "Function",
    "text": "output_power(tpa::TransformerPowerAnalysis)\n\nAverage power from the secondary of the transformer.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.efficiency",
    "page": "Design API",
    "title": "PlanerTransformer.efficiency",
    "category": "Function",
    "text": "efficiency(tpa::TransformerPowerAnalysis)\n\nEfficiency (-Pout/Pin) of transformer.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.r_core",
    "page": "Design API",
    "title": "PlanerTransformer.r_core",
    "category": "Function",
    "text": "r_core(tpa::TransformerPowerAnalysis)\n\nResistance, referenced to 1 turn, for spice model to match core power dissipation.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.chan_inductor",
    "page": "Design API",
    "title": "PlanerTransformer.chan_inductor",
    "category": "Function",
    "text": "chan_inductor(ferriteproperties, effective_area, effective_length,ishot=true)\nchan_inductor(transformer, ishot=true)\nchan_inductor(transformer_power_analysis, ishot=true)\n\nParameters for LTspice Chan inductor to be used for magnetizing inductance.\n\n\n\n"
},

{
    "location": "design_api/#Analysis-1",
    "page": "Design API",
    "title": "Analysis",
    "category": "section",
    "text": "TransformerPowerAnalysis\ntransformer_power_analysis\nwinding_power\ntotal_power\ninput_power\noutput_power\nefficiency\nr_core\nchan_inductor"
},

{
    "location": "data_entry_api/#",
    "page": "Data Entry API",
    "title": "Data Entry API",
    "category": "page",
    "text": ""
},

{
    "location": "data_entry_api/#PlanerTransformer.CoreGeometry",
    "page": "Data Entry API",
    "title": "PlanerTransformer.CoreGeometry",
    "category": "Type",
    "text": "CoreGeometry\n\nFields\n\nname                      – string identifying the core winding_aperture_height  – m\nwinding_aperture          – m\nhalf_center_width         – m\ncenter_length             – m\neffective_volume          – m^3\neffective_area            – m^2\neffective_length          – m\nmass                      – Kg\n\n\n\n"
},

{
    "location": "data_entry_api/#PlanerTransformer.FerriteProperties",
    "page": "Data Entry API",
    "title": "PlanerTransformer.FerriteProperties",
    "category": "Type",
    "text": "FerriteProperties(frequency_range, troom, thot, bh_room, bh_hot, spl_hot)\n\nStore material data.\n\nFields\n\nname              – string identifying the ferrite\nfmin              – minimum recommended operating frequency\nfmax              – maximum recommended operating frequency\ntroom             – typicaly 25C\nthot              – typicaly 100C\nbh_room           – BH loop at room temperature\nbh_hot            – BH loop at hot temperature\nspl_hot           – specfic power loss data at hot temperature\n\n\n\n"
},

{
    "location": "data_entry_api/#PlanerTransformer.BHloop",
    "page": "Data Entry API",
    "title": "PlanerTransformer.BHloop",
    "category": "Type",
    "text": "BHloop(hc,bs,br)\n\nDefine the BH loop of a magnetic material.\n\nFields\n\nhc      – Coercive force (A-turn/m)\nbs      – Remnant flux density (Tesla)\nbr      – Saturation flux density (Tesla)\n\n\n\n"
},

{
    "location": "data_entry_api/#PlanerTransformer.SpecificPowerLossData",
    "page": "Data Entry API",
    "title": "PlanerTransformer.SpecificPowerLossData",
    "category": "Type",
    "text": "SpecificPowerLossData(frequency::Tuple, mb::Tuple)\nSpecificPowerLossData(input::SplInput)\n\nCapture specific power loss data from datasheet.\n\nData is stored as a series of linear approximations on a log log plot, one for each frequency.\n\nFields\n\nfrequency   – frequency of linear approximation (Hz)\nmb          – Tuple (slope, offset) defining the linear approximation\n\nIn order to simplify manual data entry, data my also be passed as a SplInput   object.  All data is in MKS units (Hz, Tesla, W/m^3).\n\n\n\n"
},

{
    "location": "data_entry_api/#PlanerTransformer.SplInput",
    "page": "Data Entry API",
    "title": "PlanerTransformer.SplInput",
    "category": "Type",
    "text": "SplInput(data::Tuple)\n\nSimplify manual input of specific power loss data.\n\nData format is as follows. (f1,(x1,y1),(x2,y2), f2,(x3,y3),(x4,y4), ...)\n\nElements of Tuple\n\nfn    – frequency (Hz)\nxn    – flux density (mT)\nyn    – specific power loss (Kw/m^3)\n\nThe only purpose of this object is to pass to SpecificPowerLossData.  Data is converted to MKS units there.\n\n\n\n"
},

{
    "location": "data_entry_api/#PlanerTransformer.Magnetics_ER_Input",
    "page": "Data Entry API",
    "title": "PlanerTransformer.Magnetics_ER_Input",
    "category": "Type",
    "text": "Magnetics_ER_Input\n\nDirect entry of Magnetics ER core values from datasheet.\n\nFields\n\nname                –\neffective_length    – mm\neffective_area      – mm^2\neffective_volume    – mm^3\nmass                – g\ne                   – mm\nf                   – mm\naperture height     – mm\n\n\n\n"
},

{
    "location": "data_entry_api/#Data-Entry-API-1",
    "page": "Data Entry API",
    "title": "Data Entry API",
    "category": "section",
    "text": "Use these if core_geometry_dict and ferrite_dict do not have the parts you need.CoreGeometry\nFerriteProperties\nBHloop\nSpecificPowerLossData\nPlanerTransformer.SplInput\nPlanerTransformer.Magnetics_ER_Input"
},

{
    "location": "internal_api/#",
    "page": "Internal API",
    "title": "Internal API",
    "category": "page",
    "text": ""
},

{
    "location": "internal_api/#PlanerTransformer.center_frequency",
    "page": "Internal API",
    "title": "PlanerTransformer.center_frequency",
    "category": "Function",
    "text": "center_frequency(x :: FerriteProperties)\ncenter_frequency(x :: Transformer)\n\nMiddle of the minimum and maximum recomended operating frequencys from datasheet.\n\n\n\n"
},

{
    "location": "internal_api/#PlanerTransformer.winding_breadth_volume",
    "page": "Internal API",
    "title": "PlanerTransformer.winding_breadth_volume",
    "category": "Function",
    "text": "winding_breadth_volume(windings)\n\nTuple (breadth, volume).  For internal use calculating leakage inductance.\n\n\n\n"
},

{
    "location": "internal_api/#PlanerTransformer.winding_geometry",
    "page": "Internal API",
    "title": "PlanerTransformer.winding_geometry",
    "category": "Function",
    "text": "winding_geometry(pcb, core, turns)\n\nCreate a WindingGeometry object.\n\n\n\n"
},

{
    "location": "internal_api/#PlanerTransformer.winding_area",
    "page": "Internal API",
    "title": "PlanerTransformer.winding_area",
    "category": "Function",
    "text": "winding_area(x)\n\nArea the windings occupy.  For internal use.\n\n\n\n"
},

{
    "location": "internal_api/#PlanerTransformer.power_error",
    "page": "Internal API",
    "title": "PlanerTransformer.power_error",
    "category": "Function",
    "text": "power_error(ta::TransformerPowerAnalysis)\n\nreturns the difference between total_power and the power loss computed from the voltages and currents.\n\n\n\n"
},

{
    "location": "internal_api/#PlanerTransformer.pcb_thickness",
    "page": "Internal API",
    "title": "PlanerTransformer.pcb_thickness",
    "category": "Function",
    "text": "pcb_thickness(x)\n\nOverall thickness of PCB.\n\n\n\n"
},

{
    "location": "internal_api/#PlanerTransformer.sides",
    "page": "Internal API",
    "title": "PlanerTransformer.sides",
    "category": "Function",
    "text": "sides(isprimary,index)\n\nFor a given layer (index), returns the number (1 or 2) of sides which are part of the same winding.\n\nThis function is for internal use calculating effective_resistance and  leakage_inductance.\n\n\n\n"
},

{
    "location": "internal_api/#Internal-1",
    "page": "Internal API",
    "title": "Internal",
    "category": "section",
    "text": "PlanerTransformer.center_frequency\nPlanerTransformer.winding_breadth_volume\nwinding_geometry\nPlanerTransformer.winding_area\nPlanerTransformer.power_error\nPlanerTransformer.pcb_thickness\nsides"
},

{
    "location": "APIindex/#",
    "page": "API index",
    "title": "API index",
    "category": "page",
    "text": ""
},

{
    "location": "APIindex/#API-Index-1",
    "page": "API index",
    "title": "API Index",
    "category": "section",
    "text": "Pages = [\"design_api.md\", \"data_entry_api.md\",\"internal_api.md\"]"
},

]}
