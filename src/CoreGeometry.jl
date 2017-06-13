immutable CoreGeometry
  # all values are in MKS units
  winding_aperture :: Float64
  half_center_width :: Float64  # center_radius for ER
  center_length :: Float64
  effective_volume :: Float64
  effective_area :: Float64
  mass :: Float64
end

core_geometry_dict = Dict(
  :e14=> CoreGeometry(4e-3,     1.5e-3,   5e-3, 300e-9, 14.5e-6, 0.6e-3),
  :e18=> CoreGeometry(5e-3,     2e-3,     10e-3, 960e-9, 39.5e-6, 2.4e-3),
  :e22=> CoreGeometry(5.9e-3,   2.5e-3,   15.8e-3, 2550e-9, 78.5e-6, 6.5e-3),
  :e32=> CoreGeometry(9.27e-3,  3.175e-3, 20.32e-3, 5380e-9, 129e-6, 10e-3),
  :e58=> CoreGeometry(21.4e-3,  4.05e-3,  38.1e-3, 24600e-9, 305e-6, 62e-3),
  :e64=> CoreGeometry(21.8e-3,  5.08e-3,  50.8e-3, 40700e-9, 511e-6, 100e-3),
  :er20=>CoreGeometry(2.03e-3,  4.4e-3, 0, 0, 0, 0),
  :plt14=>CoreGeometry(0, 0, 0, 240e-9, 14.5e-6, 0.5e-3),
  :plt18=>CoreGeometry(0, 0, 0, 800e-9, 39.5e-6, 1.7e-3),
  :plt22=>CoreGeometry(0, 0, 0, 2040e-9, 78.5e-6, 4e-3),
  :plt32=>CoreGeometry(0, 0, 0, 4560e-9, 129e-6, 10e-3),
  :plt58=>CoreGeometry(0, 0, 0, 20800e-9, 305e-6, 44e-3),
  :plt64=>CoreGeometry(0, 0, 0, 35500e-9, 511e-6, 78e-3)
)

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
copper_weight_to_meters(oz) = 0.48e-3*oz
function resistance(w::Winding, temperature = 100.0)
  ρ = w.conductivity*(1 + w.temperature_coefficient*(temperature-20.0))
  return ρ*w.length/(w.width*w.thickness)
end
