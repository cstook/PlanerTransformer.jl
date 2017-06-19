export Magnetics, Transformer
export volt_seconds_per_turn, volts_per_turn, volts


immutable Magnetics
  ferriteproperties :: FerriteProperties
  cores :: Array{CoreGeometry,1}
  effective_volume :: Float64
  effective_area :: Float64
  mass :: Float64
  function Magnetics(fp::FerriteProperties,cores::Array{CoreGeometry,1})
    effective_area = cores[1].effective_area
    effective_volume = 0.0
    mass = 0.0
    for i in eachindex(cores)
      if effective_area != cores[i].effective_area
        throw(ArgumentError("effective area of all cores nust be the same"))
      end
      effective_volume += cores[i].effective_volume
      mass += cores[i].mass
    end
    new(fp,cores,effective_volume,effective_area,mass)
  end
end

immutable Transformer
  magnetics :: Magnetics
  windings :: Array{Winding,1}
end

flux_density(m::Magnetics, coreloss::Float64, f::Float64) =
  flux_density(m.ferriteproperties,coreloss,f)

"""julia
    volt_seconds_per_turn(effective_area, flux_density_pp)
    volt_seconds_per_turn(cg::CoreGeometry, flux_density_pp)

Returns maximum volt seconds per turn.

The first form is just an alias for multiply.  The second form pulls the
  effective area from the core geometry.
"""
volt_seconds_per_turn(effective_area::Float64, flux_density_pp::Float64) =
  effective_area * flux_density_pp
volt_seconds_per_turn(cg::CoreGeometry, flux_density_pp::Float64) =
  volt_seconds_per_turn(cg.effective_area, flux_density_pp)
volt_seconds_per_turn(m::Magnetics, flux_density_pp::Float64) =
  volt_seconds_per_turn(m.effective_area, flux_density_pp)

"""julia
    volts_per_turn(cg::CoreGeometry,
                   fp::FerriteProperties, loss_limit, frequency)

Returns the maximum volts per turn.
"""
function volts_per_turn(fp::FerriteProperties,
                        effective_area::Float64,
                        loss_limit::Float64,
                        frequency::Float64)
  flux_density_peak = flux_density(fp,loss_limit,frequency)
  flux_density_pp = 2*flux_density_peak
  return volt_seconds_per_turn(effective_area,flux_density_pp) * frequency
end
function volts_per_turn(fp::FerriteProperties,
                        cg::CoreGeometry,
                        loss_limit::Float64,
                        frequency::Float64)
  volts_per_turn(fp,cg.effective_area,loss_limit,frequency)
end
volts_per_turn(m::Magnetics, loss_limit::Float64, frequency::Float64) =
  volts_per_turn(m.ferriteproperties, m.effective_area, loss_limit, frequency)
volts_per_turn(t::Transformer, loss_limit::Float64, frequency::Float64) =
  volts_per_turn(t.magnetics.ferriteproperties, t.magnetics.effective_area, loss_limit, frequency)


function volts(w::Winding,m::Magnetics,loss_limit::Float64, frequency::Float64)
  volts_per_turn(m,loss_limit,frequency)*w.turns
end
function volts(t::Transformer,loss_limit::Float64, frequency::Float64)
  vpt = volts_per_turn(t,loss_limit,frequency)
  [vpt*t.windings[i].turns for i in eachindex(t.windings)]
end
