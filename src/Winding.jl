export PCB_Specification, WindingLayer, turns
export Winding, copper_weight_to_meters, resistance

immutable PCB_Specification
  trace_edge_gap :: Float64
  trace_trace_gap :: Float64
  outer_copper_thickness :: Float64
  inner_copper_thickness :: Float64
  number_of_layers :: Int
  ρ_20 :: Float64 # Ωm @ 20C
  temperature_coefficient :: Float64 # 1/K
  function PCB_Specification(trace_edge_gap,
                     trace_trace_gap,
                     outer_copper_thickness,
                     inner_copper_thickness = 0.0,
                     number_of_layers = 2,
                     ρ_20=1.68e-8, # Ωm for Cu @ 20C
                     temperature_coefficient=0.003862) # 1/K for Cu
    new(trace_edge_gap,
        trace_trace_gap,
        outer_copper_thickness,
        inner_copper_thickness,
        number_of_layers,
        ρ_20,
        temperature_coefficient)
  end
end

"""julia
    copper_weight_to_meters(oz)

PCB copper thickness is typicaly given in ounces.  This function multiplies
by 0.48e-3 to give thickness in meters.
"""
copper_weight_to_meters(oz) = 0.48e-3*oz

immutable WindingLayer
  width :: Float64
  length :: Float64
  thickness :: Float64
  number_of_turns :: Int
end
function WindingLayer(pcb :: PCB_Specification,
                      isouter :: Bool,
                      core :: CoreGeometry,
                      number_of_turns :: Int)
  trace_width = (core.winding_aperture-2*pcb.trace_edge_gap-
    (number_of_turns-1)*pcb.trace_trace_gap)/number_of_turns
  trace_length = 0.0
  for i in 0:number_of_turns-1
    r = core.half_center_width+pcb.trace_edge_gap+
        0.5*trace_width+i*(trace_width+pcb.trace_trace_gap)
    trace_length += 2π*r
  end
  trace_length += 2*core.center_length
  trace_thickness =
    isouter ? pcb.outer_copper_thickness : pcb.inner_copper_thickness
  WindingLayer(trace_width, trace_length, trace_thickness, number_of_turns)
end

immutable Winding
  pcb :: PCB_Specification
  windinglayers :: Array{WindingLayer,1}
  isseries :: Bool
  turns :: Int
  function Winding(pcb::PCB_Specification,windinglayers,isseries::Bool)
    if length(windinglayers)==0
      throw(ArgumentError("must have at least one winding"))
    end
    turns_1 = windinglayers[1].number_of_turns
    turns = turns_1
    for i in 2:length(windinglayers)
      truns_i = windinglayers[i].number_of_turns
      if ~isseries && turns_i != turns_1
        throw(ArgumentError("parallel windings must have same number of turns"))
      end
      turns += turns_i
    end
    new(pcb,windinglayers,isseries,turns)
  end
end

function conductivity(ρ_20::Float64, temperature_coefficient::Float64, temperature::Float64)
  ρ_20*(1 + temperature_coefficient*(temperature-20.0))
end
# todo: add skin effect
resistance(wl::WindingLayer, ρ::Float64) = ρ*wl.length/(wl.width*wl.thickness)
function resistance(wl::WindingLayer, pcb::PCB_Specification, temperature::Float64)
  ρ = conductivity(pcb.ρ_20, pcb.temperature_coefficient, temperature)
  resistance(wl,ρ)
end
function resistance(w::Winding, temperature=100.0)
  x = 0.0
  for i in eachindex(w.windinglayers)
    r = resistance(w.windinglayers[i],w.pcb,temperature)
    x += w.isseries ?  r : 1/r
  end
  return w.isseries ?  x : 1/x
end

turns(wl::WindingLayer) = wl.number_of_turns
function turns(w::Winding)
  if w.isseries
    t = 0
    for i in eachindex(w.windinglayers)
      t += turns(w.windinglayers[i])
    end
    return t
  end
  return w.windinglayers[1].number_of_turns
end
