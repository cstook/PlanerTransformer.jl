export Magnetics, Transformer
export volt_seconds_per_turn, volts_per_turn, volts, volt_seconds
export TransformerPowerDissipation, ChanInductor, equivalent_parallel_resistance


"""
    Magnetics(fp::FerriteProperties, cores::Array{CoreGeometry,1})

All magnetic information for `Transformer` in one object.
"""
struct Magnetics
  ferriteproperties :: FerriteProperties
  cores :: Array{CoreGeometry,1}
  effective_volume :: Float64
  effective_area :: Float64
  effective_length :: Float64
  mass :: Float64
  function Magnetics(fp::FerriteProperties,cores::Array{CoreGeometry,1})
    effective_area = cores[1].effective_area
    effective_volume = 0.0
    effective_length = 0.0
    mass = 0.0
    for i in eachindex(cores)
      if effective_area != cores[i].effective_area
        throw(ArgumentError("effective area of all cores nust be the same"))
      end
      effective_volume += cores[i].effective_volume
      effective_length += cores[i].effective_length
      mass += cores[i].mass
    end
    new(fp,cores,effective_volume,effective_area,effective_length,mass)
  end
end

"""
    Transformer(m::Magnetics,w::Array{Winding,1})

`Transformer` is a combination of `Magnetics` and two or more windings.
"""
struct Transformer
  magnetics :: Magnetics
  windings :: Array{Winding,1}
  function Transformer(m::Magnetics,w::Array{Winding,1})
    if length(w)<2
      throw(ArgumentError("transformers must have two windings"))
    end
    new(m,w)
  end
end

flux_density(m::Magnetics, coreloss::Float64, f::Float64) =
  flux_density(m.ferriteproperties,coreloss,f)
flux_density(t::Transformer, coreloss::Float64, f::Float64) =
  flux_density(t.magnetics,coreloss,f)
specificpowerloss(m::Magnetics, flux_density::Float64, f::Float64)=
  specificpowerloss(m.ferriteproperties,flux_density,f)
specificpowerloss(t::Transformer, flux_density::Float64, f::Float64)=
  specificpowerloss(t.magnetics,flux_density,f)

turns(t::Transformer) = turns.(t.windings)

"""
    volt_seconds_per_turn(effective_area, flux_density_pp)
    volt_seconds_per_turn(cg::CoreGeometry, flux_density_pp)
    volt_seconds_per_turn(m::Magnetics, flux_density_pp)
    volt_seconds_per_turn(t::Transformer, flux_density_pp)

Volt seconds per turn at `flux_density_pp`.  The first form is just an alias for multiply.
"""
volt_seconds_per_turn(effective_area, flux_density_pp) =
  effective_area * flux_density_pp
volt_seconds_per_turn(cg::CoreGeometry, flux_density_pp) =
  volt_seconds_per_turn(cg.effective_area, flux_density_pp)
volt_seconds_per_turn(m::Magnetics, flux_density_pp) =
  volt_seconds_per_turn(m.effective_area, flux_density_pp)
volt_seconds_per_turn(t::Transformer, flux_density_pp) =
  volt_seconds_per_turn(t.magnetics, flux_density_pp)


"""
    volt_seconds(t::Transformer, flux_density_pp)

Volt seconds at `flux_density_pp`.
"""
volt_seconds(t::Transformer, flux_density_pp) =
  volt_seconds_per_turn(t, flux_density_pp).*turns(t)


# need to rethink this
"""
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
  volts_per_turn(t.magnetics, loss_limit, frequency)

function volts(w::Winding,m::Magnetics,loss_limit::Float64, frequency::Float64)
  volts_per_turn(m,loss_limit,frequency)*w.turns
end
function volts(t::Transformer,loss_limit::Float64, frequency::Float64)
  vpt = volts_per_turn(t,loss_limit,frequency)
  [vpt*t.windings[i].turns for i in eachindex(t.windings)]
end


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
immutable TransformerPowerDissipation
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
    flux_density = v1/(2*frequency*t.windings[1].turns*t.magnetics.effective_area)
    core_specific_power = specificpowerloss(t,flux_density,frequency)
    core_total_power = t.magnetics.effective_volume * core_specific_power
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

winding_resistance(t::Transformer) = [winding_resistance(t.windings[i]) for i in eachindex(t.windings)]

immutable ChanInductor
  hc :: Float64
  bs :: Float64
  br :: Float64
  a :: Float64
  lm :: Float64
  lg :: Float64
  n :: Float64
end
function ChanInductor(fp::FerriteProperties, effective_area::Float64,
                      effective_length::Float64,ishot=true)
  bh = ishot?fp.bh_hot:fp.bh_room
  ChanInductor(bh.hc, bh.bs, bh.br, effective_area, effective_length,0.0, 1.0)
end
ChanInductor(m::Magnetics, ishot=true) =
  ChanInductor(m.ferriteproperties, m.effective_area, m.effective_length,ishot)
ChanInductor(t::Transformer, ishot=true) =
  ChanInductor(t.magnetics, ishot)
function Base.show(io::IO,ci::ChanInductor)
  println(io,"Hc=",ci.hc,", Bs=",ci.bs,", Br=",ci.br,", A=",
          ci.a,", Lm=",ci.lm,", Lg=",ci.lg,", N=",ci.n)
end


center_frequency(fp::FerriteProperties) = middle(fp.fmin,fp.fmax)
center_frequency(m::Magnetics) = center_frequency(m.ferriteproperties)
center_frequency(t::Transformer) = center_frequency(t.magnetics)
function equivalent_parallel_resistance(fp::FerriteProperties,
                                        effective_area::Float64,
                                        effective_volume::Float64,
                                        volts::Float64,
                                        frequency::Float64=center_frequency(fp),
                                        turns::Float64=1.0,
                                        ishot::Bool=true)
  flux_density = volts/(2.0*frequency*turns*effective_area)
  spldata = ishot?fp.spl_hot:fp.spl_room
  spl = specificpowerloss(spldata,flux_density,frequency)
  loss = spl*effective_volume
  volts^2/loss
end
function equivalent_parallel_resistance(m::Magnetics,
                                        volts::Float64,
                                        frequency::Float64=center_frequency(m),
                                        turns::Float64=1.0,
                                        ishot::Bool=true)
  equivalent_parallel_resistance(m.ferriteproperties,
                                 m.effective_area,
                                 m.effective_volume,
                                 volts,
                                 frequency,
                                 turns,
                                 ishot)
end
function equivalent_parallel_resistance(t::Transformer,
                                        volts::Float64,
                                        frequency::Float64=center_frequency(t),
                                        turns::Float64=1.0,
                                        ishot::Bool=true)
  equivalent_parallel_resistance(t.magnetics,
                                 volts,
                                 frequency,
                                 turns,
                                 ishot)
end
