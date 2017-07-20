export TransformerPowerAnalysis, transformer_power_analysis


"""
    TransformerPowerAnalysis

Object to store the result of a transformer_power_analysis().

**Fields**
- `transformer`             -- from input
- `converter`               -- type of converter.
- `frequency`               -- from input
- `flux_density`            -- peak flux density in Tesla
- `voltage`                 -- (primary, secondary) Vpp
- `current`                 -- (promary, secondary) Ipp
- `ac_winding_resistance`   -- (primary, secondary) Ω
- `dc_winding_resistance`   -- (primary, secondary) Ω
- `r_core`                  -- parallel resistance for spice model.
- `core_specific_power`     -- power dissipated in core in W/m^3
- `core_total_power`        -- power dissipated in core in W
- `winding_power`           -- power dissipated in each winding in W
- `total_power`             -- winding and core losses in W
"""
struct TransformerPowerAnalysis
  transformer :: Transformer
  converter :: Converter
  frequency :: Float64
  flux_density ::Float64
  voltage :: Tuple # (primary, secondary)
  current :: Tuple # (primary, secondary)
  ac_winding_resistance :: Tuple
  dc_winding_resistance :: Tuple
  r_core :: Float64
  core_specific_power :: Float64
  core_total_power :: Float64
  winding_power :: Tuple # (primary, secondary)
  total_power :: Float64
end

"""
    TransformerPowerAnalysis(t::Transformer,
                        ct::Converter,
                        v_in, i_out,
                        frequency = center_frequency(t))

Determine the losses of a transformer.

`v_in` and `i_out` are peak to peak.  `v_in` must be positive and `i_out` must be
negative (power flow from primary to secondary).  Options for `ct` are PushPull()
 or Forward.  `frequency` will default to the center of the manufacutre recomended
 operating range for the ferrite.  Results are returned as a `TransformerPowerAnalysis`
 object.
"""
function transformer_power_analysis(t::Transformer,
                             ct::Converter,
                             v_in, i_out,
                             frequency=center_frequency(t))
  v_in < 0.0 && throw(ArgumentError("v_in must be positive."))
  i_out > 0.0 && throw(ArgumentError("i_out must be negative"))
  frequency < 0.0 && throw(ArgumentError("frequency must be positive"))
  n = turns(t)[2]/turns(t)[1]
  seconds = duty(ct)/frequency
  r = winding_resistance(t, frequency)
  # initial conditions
  v1 = v_in
  i2 = i_out
  i1 = -i2 * n
  core_total_power = 0.0
  core_specific_power = 0.0
  v3 = 0.0
  v2 = 0.0
  flux_density = 0.0
  i1_old = 0.0
  for j in 1:10
    # estimate v2
    v3 = v1 - i1*r[1] # v3 referenced to primary
    v3 = v3>0.0 ? v3 : 0.0 # avoid log of negative number. unlikely? delete line?
    v2 = n*v3 + i2*r[2]
    # estimate average core power dissipation
    flux_density_pp = v3*seconds/(turns(t)[1]*effective_area(t))
    flux_density = flux_density_pp / 2.0
    core_specific_power = specific_power_loss(t, flux_density, frequency)
    core_total_power = effective_volume(t) * core_specific_power
    # estimate i1
    i1_old = i1
    i1 = core_total_power/(duty(ct)*v3) - i2 *n
    # println(abs(i1_old-i1),"    ",i1)
    if abs(i1_old-i1)<eps()*10
      break
    end
   end
  v3 /= turns(t)[1] # referance v3 to 1 turn
  r_core = v3^2/core_total_power
  p_primary = duty(ct)*i1^2*r[1]
  p_secondary = duty(ct)*i2^2*r[2]
  total_power = core_total_power + p_primary + p_secondary
  TransformerPowerAnalysis(t, ct, frequency, flux_density, (v1, v2), (i1, i2),r,
      winding_resistance(t,0.0), r_core, core_specific_power,
      core_total_power, (p_primary, p_secondary), total_power)
end

"""
    power_error(ta::TransformerPowerAnalysis)

returns the difference between total_power and the power loss computed from the
voltages and currents.
"""
function power_error(ta::TransformerPowerAnalysis)
  p_in = voltage(ta)[1]*current(ta)[1]*duty(converter(ta))
  p_out = voltage(ta)[2]*current(ta)[2]*duty(converter(ta))
  p_loss1 = p_in+p_out
  total_power(ta) - p_loss1
end
