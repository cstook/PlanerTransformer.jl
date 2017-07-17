
"""
    WindingGeometry

2D representation of winding.

**Fields**
- `width`   -- width of trace (m)
- `length`  -- length of trace (m)
- `turns`   -- number of turns
"""
struct WindingGeometry
  width :: Float64
  length :: Float64
  turns :: Int
end
function winding_geometry(pcb :: PCB_Specification,
                          core :: CoreGeometry,
                          turns :: Int)
  trace_width = (core.winding_aperture-2*pcb.trace_edge_gap-
    (turns-1)*pcb.trace_trace_gap)/turns
  trace_length = 0.0
  for i in 0:turns-1
    r = core.half_center_width+pcb.trace_edge_gap+
        0.5*trace_width+i*(trace_width+pcb.trace_trace_gap)
    trace_length += 2π*r
  end
  trace_length += 2*core.center_length
  WindingLayer(trace_width, trace_length, turns)
end

"""
    Windings

**Fields**
- `pcb`                     -- `PCB_Specification`
- `core`                    -- `CoreGeometry`
- `primarywindinggeometry`  -- `WindingGeometry` for all layers of primary
- `secondarywindinggeometry`-- `WindingGeometry` for all layers of secondary
- `isprimary`               -- tuple of `Bool` for each conductor layer
- `isprimaryseries`         -- true if primary is connected in series
- `issecondaryseries`       -- true if secondary is connected in series
"""
struct Windings
  pcb :: PCB_Specification
  core :: CoreGeometry
  primarywindinggeometry :: WindingGeometry
  secondarywindinggeometry :: WindingGeometry
  isprimary :: Tuple
  isprimaryseries :: Bool
  issecondaryseries :: Bool
end

function windings(pcb::PCB_Specification, core::CoreGeometry,
                  primaryturnsperlayer::Int, secondaryturnsperlayer::Int,
                  isprimary,
                  isprimaryeries::Bool, issecondaryseries::Bool)
  if length(isprimary)!=div(length(pcb.stackup.material),2)+1
    throw(ArgumentError("length of isprimary must be the same as number of conductor layers"))
  end

  Windings(pcb,core,
           winding_geometry(pcb,core,primaryturnsperlayer),
           winding_geometry(pcb,core,secondaryturnsperlayer),
           isprimary,
           isprimaryeries, issecondaryseries
          )
end
