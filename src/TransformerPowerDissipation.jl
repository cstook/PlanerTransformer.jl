export TransformerPowerDissipation

"""
    TransformerPowerDissipation(t::Transformer, input::Array{Float64,1}, frequency)

Computes power dissipation of transformer.

The first element of the input array is the peak to peak voltage applied to the
first winding.  The following elements are the load currents in the output
windings.  Returns a `TransformerPowerDissipation` object.

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
struct TransformerPowerDissipation
  transformer :: Transformer
  frequency :: Float64
  flux_density ::Float64
  winding_voltage :: Array{Float64,1}
  core_specific_power :: Float64
  core_total_power :: Float64
  winding_power :: Array{Float64,1}
  total_power :: Float64
  function TransformerPowerDissipation(t::Transformer, input::Array{Float64,1}, frequency)
    # input = [Vin, Iout, Iout, ...]
    # first winding is always input
    if length(t.windings) != length(input)
      throw(ArgumentError("length of input array must equal number of windings"))
    end
    v1 = input[1]
    flux_density = v1/(2*frequency*t.windings[1].turns*effective_area(t.magnetics.core))
    core_specific_power = specific_power_loss(t,flux_density,frequency)
    core_total_power = effective_volume(t.magnetics.core) * core_specific_power
    winding_voltage = [v1*t.windings[i].turns/t.windings[1].turns for i in eachindex(t.windings)]
    winding_power = similar(input)
    for i in 2:length(t.windings)
      winding_power[i] = input[i]^2*winding_resistance(t.windings[i])
    end
    p = sum(winding_power[2:end])+core_total_power+sum(input[2:end].*winding_voltage[2:end])
    r1 = winding_resistance(t.windings[1])
    winding_power[1] = 0.0
    i1 = 0.0
    i1previous = 0.0
    for i in 1:10
      pbetter = p+winding_power[1]
      i1 = pbetter/v1
      if abs(i1-i1previous)<=eps()
        break
      end
      i1previous = i1
      winding_power[1] = i1^2*r1
    end
    total_power = core_total_power + sum(winding_power)
    new(t, frequency, flux_density, winding_voltage, core_specific_power,
        core_total_power, winding_power, total_power)
  end
end
