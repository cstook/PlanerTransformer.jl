export TransformerAnalysis

"""
    TransformerAnalysis(t::Transformer, ct::Converter, v_in, i_out, frequency)

Returns a `TransformerAnalysis` object.

v_in and i_out are peak to peak.

**Fields**
- `transformer`             -- from input
- `frequency`               -- from input
- `flux_density`            -- peak flux density (Tesla)
- `winding_voltage`         -- peak to peak voltage on each winding
- `core_specific_power`     -- power dissipated in core (W/m^3)
- `core_total_power`        -- power dissipated in core (W)
- `winding_power`           -- power dissipated in each winding (W)
- `total_power`             -- `core_total_power + sum(winding_power)`
"""
struct TransformerAnalysis
  transformer :: Transformer
  frequency :: Float64
  flux_density ::Float64
  voltage :: Tuple # (primary, secondary)
  current :: Tuple # (primary, secondary)
  ac_winding_resistance :: Tuple
  dc_winding_resistance :: Tuple
  core_specific_power :: Float64
  core_total_power :: Float64
  winding_power :: Tuple # (primary, secondary)
  total_power :: Float64
  function TransformerAnalysis(t::Transformer, ct::Converter, v_in, i_out, frequency=center_frequency(t))
    seconds = duty(ct)/frequency
    flux_density_pp = v_in*seconds/(turns(t)[1]*effective_area(t))
    flux_density = flux_density_pp / 2.0
    core_specific_power = specific_power_loss(t, flux_density, frequency)
    core_total_power = effective_volume(t) * core_specific_power
    n = turns(t)[2]/turns(t)[1]
    v1 = v_in
    i2 = i_out
    i1 = -i2 / n
    r = winding_resistance(t, frequency)
    v2 = v1*n + i2*(r[1]*n + core_total_power/(i2^2*duty(ct)) + r[2])
    p_primary = duty(ct)*i1^2*r[1]
    p_secondary = duty(ct)*i2^2*r[2]
    total_power = core_total_power + p_primary + p_secondary
    new(t, frequency, flux_density, (v1, v2), (i1, i2),r,
        winding_resistance(t,0.0), core_specific_power,
        core_total_power, (p_primary, p_secondary), total_power)
  end
end
