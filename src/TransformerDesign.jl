


volt_seconds_per_turn(effective_area::Float64, flux_density_pp::Float64) =
  effective_area * flux_density_pp
volt_seconds_per_turn(cg::CoreGeometry, flux_density_pp::Float64) =
  cg.effective_area * flux_density_pp
function volts_per_turn(cg::CoreGeometry,
                        fp::FerriteProperties,
                        loss_limit::Float64,
                        frequency::Float64)
  flux_density_peak = flux_density(fp,loss_limit,frequency)
  flux_density_pp = 2*flux_density_peak
  return volt_seconds_per_turn(cg,flux_density_pp) * frequency
end
