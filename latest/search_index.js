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
    "text": "This module is based on the design procedure described in Designing Planar Magnetics.Load the module.using PlanerTransformerDefine the PCB.trace_edge_gap = 0.16e-3\ntrace_trace_gap = 0.13e-3\nouter_copper_thickness = copper_weight_to_meters(1.0)\ninner_copper_thickness = copper_weight_to_meters(1.0)\nnumber_of_layers = 4\npcb = PCB_Specification(trace_edge_gap,\n                        trace_trace_gap,\n                        outer_copper_thickness,\n                        inner_copper_thickness,\n                        number_of_layers)Operate at 500kHz with a maximum specific power loss of 150kW/m^3.frequency = 0.5e6 # Hz\nspl_max = 150e3 # W/m^3Define core geometry and type of ferrite, or use data from core_geometry_dict  and ferrite_dict.core = core_geometry_dict[\"er25/5.5_plt\"]material = ferrite_dict[\"3f35\"]Define the magnetics as a material and a core geometry.magnetics = Magnetics(material, core)Interpolate off of specific power loss data to maximum flux density.flux_density_max_pp = flux_density(magnetics, spl_max, frequency) * 2.0Calculate maximum volt seconds per turn.vspt = volt_seconds_per_turn(magnetics, flux_density_max_pp)Define the windings.  These windings are just given as an example use of the package.  They are not optimized for any input voltage and output current.   The primary will be 3 turns, 3 on each outer layer, both layers in parallel.   The secondary will be 4 turns, 2 turns on each inner layer, both layers in series.layer1 = winding_layer(pcb, true, core, 3)\nlayer2 = winding_layer(pcb, false, core, 2)\nlayer3 = winding_layer(pcb, false, core, 2)\nlayer4 = winding_layer(pcb, true, core, 3)\nprimary = Winding(pcb, [layer1, layer4], false)\nsecondary = Winding(pcb, [layer2, layer3], true)Define the transformer.  The first element in the winding array should be the input to the transformer.transformer = Transformer(magnetics, [primary, secondary])Now that the transformer is defined, we can estimate some circuit parameters.Maximum volt seconds on each winding.volt_seconds_max = volt_seconds(transformer, flux_density_max_pp)Power dissipation with 0.5Vpp 50% duty cycle square wave on the primary and 1App load on the secondary.primary_voltage_pp = 0.5\noutput_current_pp = 1.0\ntpd =TransformerPowerDissipation(transformer,\n              [primary_voltage_pp, output_current_pp], frequency)\ntp = total_power(tpd) # WParameters for a LTspice transformer model can also be computed.r1_r2 = winding_resistance(transformer)l1 = chan_inductor(transformer)r3 = equivalent_parallel_resistance(transformer, primary_voltage_pp, frequency)n1_n2 = turns(transformer)(Image: LTspice transformer model)"
},

{
    "location": "design_api/#",
    "page": "Design API",
    "title": "Design API",
    "category": "page",
    "text": ""
},

{
    "location": "design_api/#PlanerTransformer.PCB_Specification",
    "page": "Design API",
    "title": "PlanerTransformer.PCB_Specification",
    "category": "Type",
    "text": "PCB_Specification(trace_edge_gap,\n                  trace_trace_gap,\n                  outer_copper_thickness,\n                  inner_copper_thickness = 0.0,\n                  number_of_layers = 2,\n                  ρ_20=1.68e-8,\n                  temperature_coefficient=0.003862)\n\nStore PCB data.\n\nFields\n\ntrace_edge_gap          – minimum distance from trace to PCB edge (m)\ntrace_trace_gap         – minimum distance between traces (m)\nouter_copper_thickness  – thickness of top and bottom copper layers (m)\ninner_copper_thickness  – thickness of inner copper layers (m)\nnumber_of_layers        – number of copper layers\nρ_20                    – conductivity, default to 1.68e-8 Ωm for Cu @ 20C\ntemperature_coefficient – default to 0.003862 1/K for Cu\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.copper_weight_to_meters",
    "page": "Design API",
    "title": "PlanerTransformer.copper_weight_to_meters",
    "category": "Function",
    "text": "copper_weight_to_meters(oz)\n\nPCB copper thickness is typicaly given in ounces.  This function multiplies by 0.48e-3 to give thickness in meters.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.WindingLayer",
    "page": "Design API",
    "title": "PlanerTransformer.WindingLayer",
    "category": "Type",
    "text": "WindingLayer\n\nFields\n\nwidth           – width of trace (m)\nlength          – length of trace (m)\nthickness       – thickness of trace (m)\nturns – number of turns\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.winding_layer",
    "page": "Design API",
    "title": "PlanerTransformer.winding_layer",
    "category": "Function",
    "text": "winding_layer(pcb :: PCB_Specification,\n             isouter :: Bool,\n             core :: CoreGeometry,\n             turns :: Int)\n\nCreate a WindingLayer for a specific core and PCB.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.Winding",
    "page": "Design API",
    "title": "PlanerTransformer.Winding",
    "category": "Type",
    "text": "Winding(pcb::PCB_Specification,\n        windinglayers,\n        isseries::Bool)\n\nCreate a Winding by combining several WindingLayers.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.Magnetics",
    "page": "Design API",
    "title": "PlanerTransformer.Magnetics",
    "category": "Type",
    "text": "Magnetics(fp::FerriteProperties, cores::Array{CoreGeometry,1})\n\nAll magnetic information for Transformer in one object.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.Transformer",
    "page": "Design API",
    "title": "PlanerTransformer.Transformer",
    "category": "Type",
    "text": "Transformer(m::Magnetics,w::Array{Winding,1})\n\nTransformer is a combination of Magnetics and two or more Windings.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.turns",
    "page": "Design API",
    "title": "PlanerTransformer.turns",
    "category": "Function",
    "text": "turns(windinglayer::WindingLayer)\nturns(winding::Winding)\nturns(transformer::Transformer)\n\nNumber of turns, Array for Transformer.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.winding_resistance",
    "page": "Design API",
    "title": "PlanerTransformer.winding_resistance",
    "category": "Function",
    "text": "winding_resistance(wl::WindingLayer, ρ)\nwinding_resistance(wl::WindingLayer, pcb::PCB_Specification, temperature=100.0)\nwinding_resistance(w::Winding, temperature=100.0)\n\nReturns the resistance of a Winding or WindingLayer.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.TransformerPowerDissipation",
    "page": "Design API",
    "title": "PlanerTransformer.TransformerPowerDissipation",
    "category": "Type",
    "text": "TransformerPowerDissipation(t::Transformer, input::Array{Float64,1}, frequency)\n\nComputes power dissipation of transformer.\n\nThe first element of the input array is the peak to peak voltage applied to the first winding.  The following elements are the load currents in the output windings.  Returns a TransformerPowerDissipation object.\n\nFields\n\ntransformer             – from input\nfrequency               – from input\nflux_density            – peak flux density (Tesla)\nwinding_voltage         – peak to peak voltage on each winding\ncore_specific_power     – power dissipated in core (W/m^3)\ncore_total_power        – power dissipated in core (W)\nwinding_power           – power dissipated in each winding (W)\ntotal_power             – core_total_power +sum(winding_power)\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.volt_seconds_per_turn",
    "page": "Design API",
    "title": "PlanerTransformer.volt_seconds_per_turn",
    "category": "Function",
    "text": "volt_seconds_per_turn(effective_area, flux_density_pp)\nvolt_seconds_per_turn(cg::CoreGeometry, flux_density_pp)\nvolt_seconds_per_turn(m::Magnetics, flux_density_pp)\nvolt_seconds_per_turn(t::Transformer, flux_density_pp)\n\nVolt seconds per turn at flux_density_pp.  The first form is just an alias for multiply.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.volt_seconds",
    "page": "Design API",
    "title": "PlanerTransformer.volt_seconds",
    "category": "Function",
    "text": "volt_seconds(t::Transformer, flux_density_pp)\n\nVolt seconds at flux_density_pp.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.equivalent_parallel_resistance",
    "page": "Design API",
    "title": "PlanerTransformer.equivalent_parallel_resistance",
    "category": "Function",
    "text": "equivalent_parallel_resistance(tansformer::Transformer,\n                               volts,\n                               frequency=center_frequency(transformer),\n                               turns=1,\n                               ishot::Bool=true)\n\nParallel resistance for spice model for correct power dissipation.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.chan_inductor",
    "page": "Design API",
    "title": "PlanerTransformer.chan_inductor",
    "category": "Function",
    "text": "chan_inductor(ferriteproperties, effective_area, effective_length,ishot=true)\nchan_inductor(magnetics, ishot=true)\nchan_inductor(transformer, ishot=true)\n\nParameters for LTspice Chan inductor to be used for magnetizing inductance.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.volts_per_turn",
    "page": "Design API",
    "title": "PlanerTransformer.volts_per_turn",
    "category": "Function",
    "text": "volts_per_turn(cg::CoreGeometry,\n               fp::FerriteProperties, loss_limit, frequency)\n\nReturns the maximum volts per turn.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.specific_power_loss",
    "page": "Design API",
    "title": "PlanerTransformer.specific_power_loss",
    "category": "Function",
    "text": "specific_power_loss(spl::SpecificPowerLossData, flux_density, frequency)\nspecific_power_loss(fp::FerriteProperties, flux_density, frequency)\nspecific_power_loss(m::Magnetics, flux_density, frequency)\nspecific_power_loss(t::Transformer, flux_density, frequency)\n\nReturns specific power loss.\n\n\n\n"
},

{
    "location": "design_api/#PlanerTransformer.flux_density",
    "page": "Design API",
    "title": "PlanerTransformer.flux_density",
    "category": "Function",
    "text": "flux_density(spl::SpecificPowerLossData, coreloss, frequency)\nflux_density(fp::FerriteProperties, coreloss, frequency)\nflux_density(m::Magnetics, coreloss, frequency)\nflux_density(t::Transformer, coreloss, frequency)\n\nReturns magnetic field strength in Tesla.\n\n\n\n"
},

{
    "location": "design_api/#Design-1",
    "page": "Design API",
    "title": "Design",
    "category": "section",
    "text": "PCB_Specification\ncopper_weight_to_meters\nWindingLayer\nwinding_layer\nWinding\nMagnetics\nTransformer\nturns\nwinding_resistance\nTransformerPowerDissipation\nvolt_seconds_per_turn\nvolt_seconds\nequivalent_parallel_resistance\nchan_inductor\nvolts_per_turn\nspecific_power_loss\nflux_density"
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
    "text": "CoreGeometry\n\nFields\n\nname                – string identifying the core\nwinding_aperture    – m\nhalf_center_width   – m\ncenter_length       – m\neffective_volume    – m^3\neffective_area      – m^2\neffective_length    – m\nmass                – Kg\n\n\n\n"
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
    "text": "Magnetics_ER_Input\n\nDirect entry of Magnetics ER core values from datasheet.\n\nFields\n\neffective_length    – mm\neffective_area      – mm^2\neffective_volume    – mm^3\nmass                – g\ne                   – mm\nf                   – mm\n\n\n\n"
},

{
    "location": "data_entry_api/#PlanerTransformer.Magnetics_I_Input",
    "page": "Data Entry API",
    "title": "PlanerTransformer.Magnetics_I_Input",
    "category": "Type",
    "text": "Magnetics_I_Input\n\nDirect entry of Magnetics I core values from datasheet.\n\nFields\n\neffective_length    – mm\neffective_area      – mm^2\neffective_volume    – mm^3\nmass                – g\n\n\n\n"
},

{
    "location": "data_entry_api/#Data-Entry-API-1",
    "page": "Data Entry API",
    "title": "Data Entry API",
    "category": "section",
    "text": "Use these if core_geometry_dict and ferrite_dict do not have the parts you need.CoreGeometry\nFerriteProperties\nBHloop\nSpecificPowerLossData\nPlanerTransformer.SplInput\nPlanerTransformer.Magnetics_ER_Input\nPlanerTransformer.Magnetics_I_Input"
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
    "text": "Pages = [\"design_api.md\", \"data_entry_api.md\"]"
},

]}
