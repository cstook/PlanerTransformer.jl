export Magnetics, Transformer
export volt_seconds_per_turn, volts_per_turn, volts
export TransformerPowerDissipation, ChanInductor

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
specificpowerloss(m::Magnetics, flux_density::Float64, f::Float64)=
  specificpowerloss(m.ferriteproperties,flux_density,f)
specificpowerloss(t::Transformer, flux_density::Float64, f::Float64)=
  specificpowerloss(t.magnetics,flux_density,f)

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

immutable TransformerPowerDissipation
  transformer :: Transformer
  frequency :: Float64
  flux_density ::Float64
  winding_voltage :: Array{Float64,1}
  core_specific_power :: Float64
  core_total_power :: Float64
  winding_power :: Array{Float64,1}
  total_power :: Float64
  function TransformerPowerDissipation(t::Transformer, input::Array{Float64,1}, frequency::Float64)
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
      winding_power[i] = input[i]^2*resistance(t.windings[i])
    end
    p = sum(winding_power[2:end])+core_total_power+sum(input[2:end].*winding_voltage[2:end])
    r1 = resistance(t.windings[1])
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

resistance(t::Transformer) = [resistance(t.windings[i]) for i in eachindex(t.windings)]

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
