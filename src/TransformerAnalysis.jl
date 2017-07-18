export TransformerAnalysis

"""
    TransformerAnalysis(t::Transformer, v_in, i_out, frequency)

Computes power dissipation of transformer.

The first element of the input array is the peak to peak voltage applied to the
first winding.  The following elements are the load currents in the output
windings.  Returns a `TransformerAnalysis` object.

**Fields**
- `transformer`             -- from input
- `frequency`               -- from input
- `flux_density`            -- peak flux density (Tesla)
- `winding_voltage`         -- peak to peak voltage on each winding
- `core_specific_power`     -- power dissipated in core (W/m^3)
- `core_total_power`        -- power dissipated in core (W)
- `winding_power`           -- power dissipated in each winding (W)
- `total_power`             -- `core_total_power +sum(winding_power)`
"""
struct TransformerAnalysis
  transformer :: Transformer
  frequency :: Float64
  flux_density ::Float64
  winding_voltage :: Tuple # (primary, secondary)
  core_specific_power :: Float64
  core_total_power :: Float64
  winding_power :: Tuple # (primary, secondary)
  total_power :: Float64
  function TransformerAnalysis(t::Transformer, v_in, i_out, frequency)
    flux_density = v_in/(4.0*frequency*turns(t)[1]*effective_area(t))
    core_specific_power = specific_power_loss(t,flux_density,frequency)
    core_total_power = effective_volume(t) * core_specific_power
    turns_ratio = turns(t)[2]/turns(t)[1]
    v = (v_in, v_in*turns_ratio)
    resistance = winding_resistance(t)
    p_secondary = i_out^2 * resistance[2]
    p_primary = 0.0
    i1 = 0.0
    i1previous = 0.0
    for i in 1:10
      pbetter = p_secondary+p_primary
      i1 = pbetter/v_in
      if abs(i1-i1previous)<=eps()
        break
      end
      i1previous = i1
      p_primary = i1^2*resistance[1]
    end
    total_power = core_total_power + p_primary + p_secondary
    new(t, frequency, flux_density, v, core_specific_power,
        core_total_power, (p_primary, p_secondary), total_power)
  end
end
