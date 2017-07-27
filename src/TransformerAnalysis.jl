export TransformerPowerAnalysis, transformer_power_analysis
export total_power, winding_power, r_core, input_power, output_power

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
- `equilivent_resistance`   -- (primary, secondary) Ω
- `r_core`                  -- parallel resistance for spice model.
- `core_specific_power`     -- power dissipated in core in W/m^3
- `core_total_power`        -- power dissipated in core in W
- `winding_power`           -- power dissipated in each winding in W
- `total_power`             -- winding and core losses in W
"""
struct TransformerPowerAnalysis
  transformer :: Transformer
  converter :: Converter
  flux_density ::Float64
  voltage :: Tuple # (primary, secondary)
  current :: Tuple # (primary, secondary)
  ac_winding_resistance :: Tuple
  dc_winding_resistance :: Tuple
  equilivent_resistance :: Tuple
  v_core  :: Float64 # volatge referenced to 1T corrected for input resistance loss
  core_specific_power :: Float64
  core_total_power :: Float64
end

"""
    TransformerPowerAnalysis(t::Transformer,
                             c::Converter)

Determine the losses of a transformer.
"""
function transformer_power_analysis(t::Transformer, c::Converter)
  n = turns(t)[2]/turns(t)[1]
  seconds = duty(c)/frequency(c)
  r = equilivent_resistance(t,c) #winding_resistance(t, frequency(c))
  # initial conditions
  v1 = v_in(c)
  i2 = i_out(c)
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
    flux_density = flux_density_voltage(c,v3)*seconds/(turns(t)[1]*effective_area(t))
    core_specific_power = specific_power_loss(t, flux_density, frequency(c))
    core_total_power = effective_volume(t) * core_specific_power
    # estimate i1
    i1_old = i1
    i1 = new_i1(c, core_total_power, i2, v3, n)
    # println(abs(i1_old-i1),"    ",i1)
    if abs(i1_old-i1)<eps()*10
      break
    end
   end
  v3 /= turns(t)[1] # reference v3 to 1 turn
  TransformerPowerAnalysis(t, c, flux_density, (v1, v2), (i1, i2),
    winding_resistance(t, frequency(c)), winding_resistance(t,0.0),
    r,
    v3, core_specific_power,
      core_total_power)
end
function equilivent_resistance(t::Transformer, c::PushPull)
  winding_resistance(t, frequency(c))
end
function equilivent_resistance(t::Transformer, c::Forward)
  (1.0-duty(c)).*winding_resistance(t, frequency(c)) .+ duty(c).*winding_resistance(t, 0.0)
end
flux_density_voltage(c::PushPull, v3::Float64) = v3
flux_density_voltage(c::Forward, v3::Float64) = 0.5*(v3-reset_voltage(c))
new_i1(c::PushPull, core_total_power::Float64, i2::Float64, v3::Float64, n::Float64) = core_total_power/v3 - i2*n
new_i1(c::Forward, core_total_power::Float64, i2::Float64, v3::Float64, n::Float64) = core_total_power/(v3*duty(c)) - i2*n

total_power(tpa::TransformerPowerAnalysis) = sum(winding_power(tpa)) + core_total_power(tpa)

winding_power(tpa::TransformerPowerAnalysis) = winding_power(tpa, converter(tpa))
function winding_power(tpa::TransformerPowerAnalysis, c::PushPull)
  current(tpa).^2 .* equilivent_resistance(tpa)
end
function winding_power(tpa::TransformerPowerAnalysis, c::Forward)
  duty(c).*current(tpa).^2 .* equilivent_resistance(tpa)
end

r_core(tpa::TransformerPowerAnalysis) = r_core(tpa, converter(tpa))
function r_core(tpa::TransformerPowerAnalysis, c::PushPull)
  v_core(tpa)^2/core_total_power(tpa)
end
function r_core(tpa::TransformerPowerAnalysis, c::Forward)
  duty(c)*v_core(tpa)^2/core_total_power(tpa)
end
"""
    power_error(ta::TransformerPowerAnalysis)

returns the difference between total_power and the power loss computed from the
voltages and currents.
"""
power_error(ta::TransformerPowerAnalysis) = total_power(ta) - (input_power(ta) + output_power(ta))

input_power(tpa::TransformerPowerAnalysis) = input_power(tpa, converter(tpa))
input_power(tpa::TransformerPowerAnalysis, c::PushPull) = voltage(tpa)[1]*current(tpa)[1]
input_power(tpa::TransformerPowerAnalysis, c::Forward) = voltage(tpa)[1]*current(tpa)[1]*duty(c)

output_power(tpa::TransformerPowerAnalysis) = output_power(tpa, converter(tpa))
output_power(tpa::TransformerPowerAnalysis, c::PushPull) = voltage(tpa)[2]*current(tpa)[2]
output_power(tpa::TransformerPowerAnalysis, c::Forward) = voltage(tpa)[2]*current(tpa)[2]*duty(c)
