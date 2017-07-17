export flux_density, specific_power_loss
export turns, copper_weight_to_meters, winding_resistance
export volt_seconds_per_turn, volts_per_turn, volts, volt_seconds
export equivalent_parallel_resistance, winding_layer, chan_inductor


function interpolate_third_point(x1,y1,x2,y2, x3)
  m = (y2-y1)/(x2-x1)
  b = y1-x1*m
  return m*x3+b
end
function find_nearest_spl_frequency_indices(spl::SpecificPowerLossData,f)
  i = 2
  for i in 2:length(spl.frequency) # there will never be many of these
    if spl.frequency[i]>f break end
  end
  return i-1:i
end

"""
    specific_power_loss(spl::SpecificPowerLossData, flux_density, frequency)
    specific_power_loss(fp::FerriteProperties, flux_density, frequency)
    specific_power_loss(m::Magnetics, flux_density, frequency)
    specific_power_loss(t::Transformer, flux_density, frequency)

Returns specific power loss.
"""
specific_power_loss

function specific_power_loss(spl::SpecificPowerLossData, flux_density, f)
  # spl = tabulated specific power loss data from graph on datasheet
  # flux_density = magnetic field strength in Tesla
  # f = frequency in Hz
  # retruns specfic power loss (W/m^3) at flux_density (Tesla), f (Hz)
  indexrange = find_nearest_spl_frequency_indices(spl,f)
  f_array = [spl.frequency[i] for i in indexrange]
  pv_array = [spl.mb[i][1]*log10(flux_density)+spl.mb[i][2] for i in indexrange]
  pv = 10^interpolate_third_point(f_array[1],pv_array[1],
                                    f_array[2],pv_array[2], f)
  return pv # specicic power loss (W/m^3) at flux_density, frequency f
end
specific_power_loss(fp::FerriteProperties, flux_density, f) =
  specific_power_loss(fp.spl_hot,flux_density,f)
specific_power_loss(m::Magnetics, flux_density::Float64, f::Float64)=
  specific_power_loss(m.ferriteproperties,flux_density,f)
specific_power_loss(t::Transformer, flux_density::Float64, f::Float64)=
  specific_power_loss(t.magnetics,flux_density,f)


"""
    flux_density(spl::SpecificPowerLossData, coreloss, frequency)
    flux_density(fp::FerriteProperties, coreloss, frequency)
    flux_density(m::Magnetics, coreloss, frequency)
    flux_density(t::Transformer, coreloss, frequency)

Returns magnetic field strength in Tesla.
"""
flux_density

function flux_density(spl::SpecificPowerLossData, coreloss::Float64, f::Float64)
  # spl = tabulated specific power loss data from graph on datasheet
  # coreloss = specfic power loss at b,f in W/m^3
  # f = frequency in Hz
  # returns magametic field strength in Tesla
  indexrange = find_nearest_spl_frequency_indices(spl,f)
  f_array = [spl.frequency[i] for i in indexrange]
  b_array = [(log10(coreloss)-spl.mb[i][2])/spl.mb[i][1] for i in indexrange]
  b = 10^interpolate_third_point(f_array[1],b_array[1],
                              f_array[2],b_array[2], f)
  return b # magnetic field strength in Tesla
end
flux_density(fp::FerriteProperties, coreloss::Float64, f::Float64) =
  flux_density(fp.spl_hot,coreloss,f)
flux_density(m::Magnetics, coreloss::Float64, f::Float64) =
  flux_density(m.ferriteproperties,coreloss,f)
flux_density(t::Transformer, coreloss::Float64, f::Float64) =
  flux_density(t.magnetics,coreloss,f)

"""
    winding_layer(pcb :: PCB_Specification,
                 isouter :: Bool,
                 core :: CoreGeometry,
                 turns :: Int)

Create a `WindingLayer` for a specific core and PCB.
"""
function winding_layer(pcb :: PCB_Specification,
                      isouter :: Bool,
                      core :: CoreGeometry,
                      turns :: Int)
  trace_width = (core.winding_aperture-2*pcb.trace_edge_gap-
    (turns-1)*pcb.trace_trace_gap)/turns
  trace_length = 0.0
  for i in 0:turns-1
    r = core.half_center_width+pcb.trace_edge_gap+
        0.5*trace_width+i*(trace_width+pcb.trace_trace_gap)
    trace_length += 2π*r
  end
  trace_length += 2*core.center_length
  trace_thickness =
    isouter ? pcb.outer_copper_thickness : pcb.inner_copper_thickness
  WindingLayer(trace_width, trace_length, trace_thickness, turns)
end

"""
    copper_weight_to_meters(oz)

PCB copper thickness is typicaly given in ounces.  This function multiplies
by 0.48e-3 to give thickness in meters.
"""
copper_weight_to_meters(oz) = 0.48e-3*oz

const μ0 =1.2566370614e-6
δ(f,ρ)=√(ρ/(π*f*μ0)) # skin depth
function conductivity(ρ_20, temperature_coefficient, temperature)
  # todo: add skin effect
  ρ_20*(1 + temperature_coefficient*(temperature-20.0))
end
leakage_inductance(volume,turns,width) = volume*μ0*(turns/width)^2

"""
    turns(windinglayer::WindingLayer)
    turns(winding::Winding)
    turns(transformer::Transformer)

Number of turns, Array for `Transformer`.
"""
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
  volt_seconds_per_turn(m.core, flux_density_pp)
volt_seconds_per_turn(t::Transformer, flux_density_pp) =
  volt_seconds_per_turn(t.magnetics, flux_density_pp)

"""
    volt_seconds(t::Transformer, flux_density_pp)

Volt seconds at `flux_density_pp`.
"""
volt_seconds(t::Transformer, flux_density_pp) =
  volt_seconds_per_turn(t, flux_density_pp).*turns(t)


# BEGIN need to rethink this
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
  volts_per_turn(m.ferriteproperties, m.core, loss_limit, frequency)
volts_per_turn(t::Transformer, loss_limit::Float64, frequency::Float64) =
  volts_per_turn(t.magnetics, loss_limit, frequency)

function volts(w::Winding,m::Magnetics,loss_limit::Float64, frequency::Float64)
  volts_per_turn(m,loss_limit,frequency)*w.turns
end
function volts(t::Transformer,loss_limit::Float64, frequency::Float64)
  vpt = volts_per_turn(t,loss_limit,frequency)
  [vpt*t.windings[i].turns for i in eachindex(t.windings)]
end
# END need to rethink this

"""
    winding_resistance(wl::WindingLayer, ρ)
    winding_resistance(wl::WindingLayer, pcb::PCB_Specification, temperature=100.0)
    winding_resistance(w::Winding, temperature=100.0)

Returns the resistance of a `Winding` or `WindingLayer`.
"""
winding_resistance(wl::WindingLayer, ρ) = ρ*wl.length/(wl.width*wl.thickness)
function winding_resistance(wl::WindingLayer, pcb::PCB_Specification, temperature=100.0)
  ρ = conductivity(pcb.ρ_20, pcb.temperature_coefficient, temperature)
  winding_resistance(wl,ρ)
end
function winding_resistance(w::Winding, temperature=100.0)
  x = 0.0
  for i in eachindex(w.windinglayers)
    r = winding_resistance(w.windinglayers[i],w.pcb,temperature)
    x += w.isseries ?  r : 1/r
  end
  return w.isseries ?  x : 1/x
end
winding_resistance(t::Transformer) =
  [winding_resistance(t.windings[i]) for i in eachindex(t.windings)]

center_frequency(fp::FerriteProperties) = middle(fp.fmin,fp.fmax)
center_frequency(m::Magnetics) = center_frequency(m.ferriteproperties)
center_frequency(t::Transformer) = center_frequency(t.magnetics)

"""
    equivalent_parallel_resistance(tansformer::Transformer,
                                   volts,
                                   frequency=center_frequency(transformer),
                                   turns=1,
                                   ishot::Bool=true)

Parallel resistance for spice model for correct power dissipation.
"""
equivalent_parallel_resistance
function equivalent_parallel_resistance(fp::FerriteProperties,
                                        effective_area,
                                        effective_volume,
                                        volts,
                                        frequency=center_frequency(fp),
                                        turns=1,
                                        ishot::Bool=true)
  flux_density = volts/(2.0*frequency*turns*effective_area)
  spldata = ishot?fp.spl_hot:fp.spl_room
  spl = specific_power_loss(spldata,flux_density,frequency)
  loss = spl*effective_volume
  volts^2/loss
end
function equivalent_parallel_resistance(m::Magnetics,
                                        volts,
                                        frequency=center_frequency(m),
                                        turns=1,
                                        ishot::Bool=true)
  equivalent_parallel_resistance(m.ferriteproperties,
                                 effective_area(m.core),
                                 effective_volume(m.core),
                                 volts,
                                 frequency,
                                 turns,
                                 ishot)
end
function equivalent_parallel_resistance(t::Transformer,
                                        volts,
                                        frequency=center_frequency(t),
                                        turns=1,
                                        ishot::Bool=true)
  equivalent_parallel_resistance(t.magnetics,
                                 volts,
                                 frequency,
                                 turns,
                                 ishot)
end

"""
    chan_inductor(ferriteproperties, effective_area, effective_length,ishot=true)
    chan_inductor(magnetics, ishot=true)
    chan_inductor(transformer, ishot=true)

Parameters for LTspice [Chan inductor](http://ltwiki.org/?title=The_Chan_model)
to be used for magnetizing inductance.
"""
chan_inductor
function chan_inductor(fp::FerriteProperties,
                       effective_area,effective_length,ishot::Bool=true)
  bh = ishot?fp.bh_hot:fp.bh_room
  ChanInductor(bh.hc, bh.bs, bh.br, effective_area, effective_length,0.0, 1.0)
end
chan_inductor(m::Magnetics, ishot::Bool=true) =
  chan_inductor(m.ferriteproperties, effective_area(m.core), effective_length(m.core),ishot)
chan_inductor(t::Transformer, ishot::Bool=true) =
  chan_inductor(t.magnetics, ishot)
