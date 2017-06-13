export volt_seconds_per_turn, volts_per_turn

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
  cg.effective_area * flux_density_pp

"""julia
    volts_per_turn(cg::CoreGeometry,
                   fp::FerriteProperties, loss_limit, frequency)

Returns the maximum volts per turn.
"""
function volts_per_turn(cg::CoreGeometry,
                        fp::FerriteProperties,
                        loss_limit::Float64,
                        frequency::Float64)
  flux_density_peak = flux_density(fp,loss_limit,frequency)
  flux_density_pp = 2*flux_density_peak
  return volt_seconds_per_turn(cg,flux_density_pp) * frequency
end
