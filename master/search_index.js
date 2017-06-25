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
    "text": "Use Julia to design planer transformersPages = [\"api.md\"]"
},

{
    "location": "api/#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api/#PlanerTransformer.PCB_Specification",
    "page": "API",
    "title": "PlanerTransformer.PCB_Specification",
    "category": "Type",
    "text": "PCB_Specification(trace_edge_gap,\n                  trace_trace_gap,\n                  outer_copper_thickness,\n                  inner_copper_thickness = 0.0,\n                  number_of_layers = 2,\n                  ρ_20=1.68e-8,\n                  temperature_coefficient=0.003862)\n\nStore PCB data.\n\n** Fields **\n\ntrace_edge_gap          – minimum distance from trace to PCB edge (m)\ntrace_trace_gap         – minimum distance between traces (m)\nouter_copper_thickness  – thickness of top and bottom copper layers (m)\ninner_copper_thickness  – thickness of inner copper layers (m)\nnumber_of_layers        – number of copper layers\nρ_20                    – conductivity, default to 1.68e-8 Ωm for Cu @ 20C\ntemperature_coefficient – default to 0.003862 1/K for Cu\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.copper_weight_to_meters",
    "page": "API",
    "title": "PlanerTransformer.copper_weight_to_meters",
    "category": "Function",
    "text": "copper_weight_to_meters(oz)\n\nPCB copper thickness is typicaly given in ounces.  This function multiplies by 0.48e-3 to give thickness in meters.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.CoreGeometry",
    "page": "API",
    "title": "PlanerTransformer.CoreGeometry",
    "category": "Type",
    "text": "CoreGeometry\n\nFields\n\nwinding_aperture    – m\nhalf_center_width   – m\ncenter_length       – m\neffective_volume    – m^3\neffective_area      – m^2\neffective_length    – m\nmass                – Kg\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.FerriteProperties",
    "page": "API",
    "title": "PlanerTransformer.FerriteProperties",
    "category": "Type",
    "text": "FerriteProperties(frequency_range, troom, thot, bh_room, bh_hot, spl_hot)\n\nStore material data.\n\nFields\n\nfmin              – minimum recommended operating frequency\nfmax              – maximum recommended operating frequency\ntroom             – typicaly 25C\nthot              – typicaly 100C\nbh_room           – BH loop at room temperature\nbh_hot            – BH loop at hot temperature\nspl_hot           – specfic power loss data at hot temperature\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.BHloop",
    "page": "API",
    "title": "PlanerTransformer.BHloop",
    "category": "Type",
    "text": "BHloop(hc,bs,br)\n\nDefine the BH loop of a magnetic material.\n\nFields\n\nhc      – Coercive force (A-turn/m)\nbs      – Remnant flux density (Tesla)\nbr      – Saturation flux density (Tesla)\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.SpecificPowerLossData",
    "page": "API",
    "title": "PlanerTransformer.SpecificPowerLossData",
    "category": "Type",
    "text": "SpecificPowerLossData(frequency::Tuple, mb::Tuple)\nSpecificPowerLossData(input::SplInput)\n\nCapture specific power loss data from datasheet.\n\nData is stored as a series of linear approximations on a log log plot, one for each frequency.\n\nFields\n\nfrequency   – frequency of linear approximation (Hz)\nmb          – Tuple (slope, offset) defining the linear approximation\n\nIn order to simplify manual data entry, data my also be passed as a SplInput   object.  All data is in MKS units (Hz, Tesla, W/m^3).\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.WindingLayer",
    "page": "API",
    "title": "PlanerTransformer.WindingLayer",
    "category": "Type",
    "text": "WindingLayer\n\nFields\n\nwidth           – width of trace (m)\nlength          – length of trace (m)\nthickness       – thickness of trace (m)\nnumber_of_turns – number of turns\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.Winding",
    "page": "API",
    "title": "PlanerTransformer.Winding",
    "category": "Type",
    "text": "Winding(pcb::PCB_Specification,\n        windinglayers,\n        isseries::Bool)\n\nCreate a Winding by combining several WindingLayers.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.Magnetics",
    "page": "API",
    "title": "PlanerTransformer.Magnetics",
    "category": "Type",
    "text": "Magnetics(fp::FerriteProperties, cores::Array{CoreGeometry,1})\n\nAll magnetic information for Transformer in one object.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.Transformer",
    "page": "API",
    "title": "PlanerTransformer.Transformer",
    "category": "Type",
    "text": "Transformer(m::Magnetics,w::Array{Winding,1})\n\nTransformer is a combination of Magnetics and two or more windings.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.turns",
    "page": "API",
    "title": "PlanerTransformer.turns",
    "category": "Function",
    "text": "turns(wl::WindingLayer)\nturns(w::Winding)\nturns(t::Transformer)\n\nNumber of turns, Array for Transformer.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.winding_resistance",
    "page": "API",
    "title": "PlanerTransformer.winding_resistance",
    "category": "Function",
    "text": "winding_resistance(wl::WindingLayer, ρ)\nwinding_resistance(wl::WindingLayer, pcb::PCB_Specification, temperature=100.0)\nwinding_resistance(w::Winding, temperature=100.0)\n\nReturns the resistance of a Winding or WindingLayer.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.TransformerPowerDissipation",
    "page": "API",
    "title": "PlanerTransformer.TransformerPowerDissipation",
    "category": "Type",
    "text": "TransformerPowerDissipation(t::Transformer, input::Array{Float64,1}, frequency)\n\nComputes power dissipation of transformer.\n\nThe first element of the input array is the peak to peak voltage applied to the first winding.  The following elements are the load currents in the output windings.  Returns a TransformerPowerDissipation object.\n\nFields\n\ntransformer             – from input\nfrequency               – from input\nflux_density            – peak flux density (Tesla)\nwinding_voltage         – peak to peak voltage on each winding\ncore_specific_power     – power dissipated in core (W/m^3)\ncore_total_power        – power dissipated in core (W)\nwinding_power           – power dissipated in each winding (W)\ntotal_power             – core_total_power +sum(winding_power)\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.volt_seconds_per_turn",
    "page": "API",
    "title": "PlanerTransformer.volt_seconds_per_turn",
    "category": "Function",
    "text": "volt_seconds_per_turn(effective_area, flux_density_pp)\nvolt_seconds_per_turn(cg::CoreGeometry, flux_density_pp)\nvolt_seconds_per_turn(m::Magnetics, flux_density_pp)\nvolt_seconds_per_turn(t::Transformer, flux_density_pp)\n\nVolt seconds per turn at flux_density_pp.  The first form is just an alias for multiply.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.volt_seconds",
    "page": "API",
    "title": "PlanerTransformer.volt_seconds",
    "category": "Function",
    "text": "volt_seconds(t::Transformer, flux_density_pp)\n\nVolt seconds at flux_density_pp.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.volts_per_turn",
    "page": "API",
    "title": "PlanerTransformer.volts_per_turn",
    "category": "Function",
    "text": "volts_per_turn(cg::CoreGeometry,\n               fp::FerriteProperties, loss_limit, frequency)\n\nReturns the maximum volts per turn.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.specificpowerloss",
    "page": "API",
    "title": "PlanerTransformer.specificpowerloss",
    "category": "Function",
    "text": "specificpowerloss(spl::SpecificPowerLossData, flux_density, frequency)\nspecificpowerloss(fp::FerriteProperties, flux_density, frequency)\nspecificpowerloss(m::Magnetics, flux_density, frequency)\nspecificpowerloss(t::Transformer, flux_density, frequency)\n\nReturns specific power loss.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.flux_density",
    "page": "API",
    "title": "PlanerTransformer.flux_density",
    "category": "Function",
    "text": "flux_density(spl::SpecificPowerLossData, coreloss, frequency)\nflux_density(fp::FerriteProperties, coreloss, frequency)\nflux_density(m::Magnetics, coreloss, frequency)\nflux_density(t::Transformer, coreloss, frequency)\n\nReturns magnetic field strength in Tesla.\n\n\n\n"
},

{
    "location": "api/#PlanerTransformer.SplInput",
    "page": "API",
    "title": "PlanerTransformer.SplInput",
    "category": "Type",
    "text": "SplInput(data::Tuple)\n\nSimplify manual input of specific power loss data.\n\nData format is as follows. (f1,(x1,y1),(x2,y2), f2,(x3,y3),(x4,y4), ...)\n\nElements of Tuple\n\nfn    – frequency (Hz)\nxn    – flux density (mT)\nyn    – specific power loss (Kw/m^3)\n\nThe only purpose of this object is to pass to SpecificPowerLossData.  Data is converted to MKS units there.\n\n\n\n"
},

{
    "location": "api/#Interface-1",
    "page": "API",
    "title": "Interface",
    "category": "section",
    "text": "PCB_Specification\ncopper_weight_to_meters\nCoreGeometry\nFerriteProperties\nBHloop\nSpecificPowerLossData\nWindingLayer\nWinding\nMagnetics\nTransformer\nturns\nwinding_resistance\nTransformerPowerDissipation\nvolt_seconds_per_turn\nvolt_seconds\nvolts_per_turn\nspecificpowerloss\nflux_density\nSplInput"
},

]}
