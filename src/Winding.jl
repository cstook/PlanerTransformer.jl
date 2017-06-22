export PCB_Specification, WindingLayer, turns
export Winding, copper_weight_to_meters, winding_resistance


"""julia
    PCB_Specification(trace_edge_gap,
                      trace_trace_gap,
                      outer_copper_thickness,
                      inner_copper_thickness = 0.0,
                      number_of_layers = 2,
                      ρ_20=1.68e-8,
                      temperature_coefficient=0.003862)

Store PCB data.

** Fields **
- `trace_edge_gap`          -- minimum distance from trace to PCB edge (m)
- `trace_trace_gap`         -- minimum distance between traces (m)
- `outer_copper_thickness`  -- thickness of top and bottom copper layers (m)
- `inner_copper_thickness`  -- thickness of inner copper layers (m)
- `number_of_layers`        -- number of copper layers
- `ρ_20`                    -- conductivity, default to 1.68e-8 Ωm for Cu @ 20C
- `temperature_coefficient` -- default to 0.003862 1/K for Cu
"""
struct PCB_Specification
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

"""julia
    WindingLayer

**Fields**
- `width`           -- width of trace (m)
- `length`          -- length of trace (m)
- `thickness'       -- thickness of trace (m)
- `number_of_turns' -- number of turns
"""
struct WindingLayer
  width :: Float64
  length :: Float64
  thickness :: Float64
  number_of_turns :: Int
end
"""julia
    WindingLayer(pcb :: PCB_Specification,
                 isouter :: Bool,
                 core :: CoreGeometry,
                 number_of_turns :: Int)

Create a `WindingLayer` for a specific core and PCB.
"""
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

"""julia
    Winding(pcb::PCB_Specification,
            windinglayers,
            isseries::Bool)

Create a `Winding` by combining several `WindingLayers`.
"""
struct Winding
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
      turns_i = windinglayers[i].number_of_turns
      if isseries
        turns += turns_i
      elseif turns_i != turns_1
        throw(ArgumentError("parallel windings must have same number of turns"))
      end
    end
    new(pcb,windinglayers,isseries,turns)
  end
end

function conductivity(ρ_20, temperature_coefficient, temperature)
  ρ_20*(1 + temperature_coefficient*(temperature-20.0))
end
# todo: add skin effect

"""julia
    winding_resistance(wl::WindingLayer, ρ)
    winding_resistance(wl::WindingLayer, pcb::PCB_Specification, temperature=100.0)
    winding_resistance(w::Winding, temperature=100.0)

Returns the resistance of a `Winding` or `WindingLayer`.
"""
winding_resistance(wl::WindingLayer, ρ) = ρ*wl.length/(wl.width*wl.thickness)
function winding_resistance(wl::WindingLayer, pcb::PCB_Specification, temperature=100.0)
  ρ = conductivity(pcb.ρ_20, pcb.temperature_coefficient, temperature)
  winding_resistance(wl,ρ)
end
function winding_resistance(w::Winding, temperature=100.0)
  x = 0.0
  for i in eachindex(w.windinglayers)
    r = winding_resistance(w.windinglayers[i],w.pcb,temperature)
    x += w.isseries ?  r : 1/r
  end
  return w.isseries ?  x : 1/x
end

"""julia
    turns(wl::WindingLayer)
    turns(w::Winding)
    turns(t::Transformer)

Number of turns, Array for `Transformer`.
"""
turns

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
