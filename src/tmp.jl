
"""julia
    Winding(width, length, thickness, number_of_turns,
            conductivity, temperature_coefficient)
    Winding(core::CoreGeometry, number_of_turns, trace_edge_gap,
            trace_trace_gap, thickness)

Geometry of the windings.

**Fields**
- `width`                     -- m
- `length`                    -- m
- `thickness`                 -- m
- `number_of_turns`           -- count
- `conductivity`              -- Ohm m
- `temperature_coefficient`   -- K^-1

The second form takes parameters from `core` and PCB parameters.  Geometry
is used to calculate winding resistance, and to layout PCB.
"""
immutable Winding
  width :: Float64
  length :: Float64
  thickness :: Float64
  number_of_turns :: Float64
  conductivity :: Float64 # @20C
  temperature_coefficient :: Float64
  function Winding(w,l,t,
                   turns,
                   c=1.68e-8, # Ωm for Cu @ 20C
                   tc=0.003862) # 1/K for Cu
    new(w,l,t,turns,c,tc)
  end
end

function Winding(core::CoreGeometry,
                 number_of_turns,
                 trace_edge_gap,
                 trace_trace_gap,
                 thickness)
  trace_width = (core.winding_aperture-2*trace_edge_gap-
                (number_of_turns-1)*trace_trace_gap)/number_of_turns
  trace_length = 0.0
  for i in 0:number_of_turns-1
    r = core.half_center_width+trace_edge_gap+
        0.5*trace_width+i*(trace_width+trace_trace_gap)
    trace_length += 2π*r
  end
  trace_length += 2*core.center_length
  Winding(trace_width,trace_length,thickness,number_of_turns)
end
"""julia
    copper_weight_to_meters(oz)

PCB copper thickness is typicaly given in ounces.  This function multiplies
by 0.48e-3 to give thickness in meters.
"""
copper_weight_to_meters(oz) = 0.48e-3*oz

"""julia
    resistance(w::Winding, <keyword parameters>)

Resistance of a winding in Ohms.

**keyword parameters**
- `temperature`   -- default = 100 C
"""
function resistance(w::Winding, temperature = 100.0)
  ρ = w.conductivity*(1 + w.temperature_coefficient*(temperature-20.0))
  return ρ*w.length/(w.width*w.thickness)
end

w1 = Winding(core_geometry_dict["e14"],3,0.2e-3,0.1e-3,
             copper_weight_to_meters(1.0))
@test isapprox(w1.width,0.0011333333333333332)
@test isapprox(w1.length,0.07597344572538565)
@test isapprox(w1.thickness,0.000480)
@test isapprox(w1.number_of_turns,3.00)
@test isapprox(w1.conductivity,1.68e-8)
@test isapprox(w1.temperature_coefficient,0.003862)
@test isapprox(resistance(w1),0.0030711326938981133)
