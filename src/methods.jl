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
specific_power_loss(t::Transformer, flux_density::Float64, f::Float64)=
  specific_power_loss(ferrite(t),flux_density,f)


"""
    flux_density(spl::SpecificPowerLossData, coreloss, frequency)
    flux_density(fp::FerriteProperties, coreloss, frequency)
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
flux_density(t::Transformer, coreloss::Float64, f::Float64) =
  flux_density(ferriteproperties(t),coreloss,f)


#=
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
=#

"""
    copper_weight_to_meters(oz)

PCB copper thickness is typicaly given in ounces.  This function multiplies
by 35e-6 to give thickness in meters.
"""
copper_weight_to_meters(oz) = 35e-6*oz

"""
    turns(windinggeometry::WindingGeometry)
    turns(windings::Windings)
    turns(transformer::Transformer)

Number of turns, Array for `Transformer`.
"""
function turns(w::Windings)
  primary_turns = turns(primarywindinggeometry(w))
  primary_turns *= isprimaryseries(w) ? count(isprimary(w)) : 1
  secondary_turns = turns(secondarywindinggeometry(w))
  secondary_turns *= issecondaryseries(w) ? length(isprimary(w)) - count(isprimary(w)) : 1
  (primary_turns, secondary_turns)
end
turns(t::Transformer) = turns(windings(t))

"""
    volt_seconds_per_turn(effective_area, flux_density_pp)
    volt_seconds_per_turn(cg::CoreGeometry, flux_density_pp)
    volt_seconds_per_turn(w::Windings, flux_density_pp)
    volt_seconds_per_turn(t::Transformer, flux_density_pp)

Volt seconds per turn at `flux_density_pp`.  The first form is just an alias for multiply.
"""
volt_seconds_per_turn(effective_area, flux_density_pp) =
  effective_area * flux_density_pp
volt_seconds_per_turn(cg::CoreGeometry, flux_density_pp) =
  volt_seconds_per_turn(effective_area(cg), flux_density_pp)
volt_seconds_per_turn(w::Windings, flux_density_pp) =
  colt_seconds_per_turn(core(w), flux_density_pp)
volt_seconds_per_turn(t::Transformer, flux_density_pp) =
  volt_seconds_per_turn(windings(t), flux_density_pp)

"""
    volt_seconds(t::Transformer, flux_density_pp)

Volt seconds at `flux_density_pp`.
"""
volt_seconds(w::Windings, flux_density_pp) =
  volt_seconds_per_turn(core(w), flux_density_pp).*turns(w)
volt_seconds(t::Transformer, flux_density_pp) =
  volt_seconds_per_turn(windings(t), flux_density_pp)

const μ0 =1.2566370614e-6
skin_depth(ρ,f)=√(ρ/(π*f*μ0)) # skin depth
function conductivity(ρ_20, temperature_coefficient, temperature)
  ρ_20*(1 + temperature_coefficient*(temperature-20.0))
end

layer_resistance(wg::WindingGeometry, thickness, ρ) =
  ρ*length(wg)/(width(wg)*thickness)
function layer_resistance(w::Windings, i, frequency=0.0, temperature=100.0)
  winding_geometry = isprimary(w)[i] ? primarywindinggeometry(w) : secondarywindinggeometry(w)
  ρ = conductivity(ρ_20(material(stackup(pcb(w)))[i*2-1]), tc(material(stackup(pcb(w)))[i*2-1]), temperature)
  effective_thickness = thickness(stackup(pcb(w)))[i*2-1]
  if frequency>0.0
    δ = skin_depth(ρ, frequency)
    effective_thickness = minimum((sides(w)[i]*δ, effective_thickness))
  end
  layer_resistance(winding_geometry, effective_thickness, ρ)
end
function layer_resistance_tuple(w::Windings, frequency=0.0, temperature=100.0)
  ntuple(i->layer_resistance(w, i, frequency, temperature), eachindex(isprimary(w)))
end
"""
    winding_resistance(w::Windings, frequency=0.0, temperature=100.0)

Returns tuple `(primary_resistance, secondary_resistance)`
"""
function winding_resistance(w::Windings, frequency=0.0, temperature=100.0)
  primary = 0.0
  secondary = 0.0
  for i in eachindex(isprimary(w))
    x = layer_resistance(w,i,frequency,temperature)
    if isprimary(w)[i]
      primary += isprimaryseries(w) ? x : 1/x
    else
      secondary = issecondaryseries(w) ? x : 1/x
    end
  end
  (isprimaryseries(w) ? primary : 1/primary, issecondaryseries(w) ? secondary : 1/secondary)
end
winding_resistance(t::Transformer, frequency=0.0, temperature=100.0) =
  winding_resistance(windings(t),frequency,temperature)

center_frequency(fp::FerriteProperties) = middle(fmin(fp),fmax(fp))
center_frequency(t::Transformer) = center_frequency(ferrite(t))

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
  spldata = ishot?spl_hot(fp):spl_room(fp)
  spl = specific_power_loss(spldata,flux_density,frequency)
  loss = spl*effective_volume
  volts^2/loss
end
function equivalent_parallel_resistance(t::Transformer,
                                        volts,
                                        frequency=center_frequency(t),
                                        turns=1,
                                        ishot::Bool=true)
  equivalent_parallel_resistance(ferriteproperties(t),
                                 volts,
                                 frequency,
                                 turns,
                                 ishot)
end

"""
    chan_inductor(ferriteproperties, effective_area, effective_length,ishot=true)
    chan_inductor(transformer, ishot=true)

Parameters for LTspice [Chan inductor](http://ltwiki.org/?title=The_Chan_model)
to be used for magnetizing inductance.
"""
chan_inductor
function chan_inductor(fp::FerriteProperties,
                       effective_area,effective_length,ishot::Bool=true)
  bh = ishot ? bh_hot(fp) : bh_room(fp)
  ChanInductor(hc(bh), bs(bh), br(bh), effective_area, effective_length,0.0, 1.0)
end
chan_inductor(t::Transformer, ishot::Bool=true) =
  chan_inductor(ferriteproperties(t),
                effective_area(t),
                effective_length(t),
                ishot)

leakage_inductance(volume,turns,width) = volume*μ0*(turns/width)^2
