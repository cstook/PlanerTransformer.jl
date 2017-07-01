export CoreGeometry
export BHloop, SplInput, SpecificPowerLossData
export FerriteProperties
export PCB_Specification, WindingLayer
export Winding
export Magnetics, Transformer
export TransformerPowerDissipation, ChanInductor

"""
    CoreGeometry

**Fields**
- `winding_aperture`    -- m
- `half_center_width`   -- m
- `center_length`       -- m
- `effective_volume`    -- m^3
- `effective_area`      -- m^2
- `effective_length`    -- m
- `mass`                -- Kg
"""
struct CoreGeometry
  # all values are in MKS units
  winding_aperture :: Float64
  half_center_width :: Float64  # center_radius for ER
  center_length :: Float64
  effective_volume :: Float64
  effective_area :: Float64
  effective_length :: Float64
  mass :: Float64
end

"""
    BHloop(hc,bs,br)

Define the BH loop of a magnetic material.

**Fields**
- `hc`      -- Coercive force (A-turn/m)
- `bs`      -- Remnant flux density (Tesla)
- `br`      -- Saturation flux density (Tesla)
"""
struct BHloop
  hc :: Float64
  bs :: Float64
  br :: Float64
end
"""
    SpecificPowerLossData(frequency::Tuple, mb::Tuple)
    SpecificPowerLossData(input::SplInput)

Capture specific power loss data from datasheet.

Data is stored as a series of linear approximations on a log log plot, one for
each frequency.

**Fields**
- `frequency`   -- frequency of linear approximation (Hz)
- `mb`          -- Tuple (slope, offset) defining the linear approximation

In order to simplify manual data entry, data my also be passed as a SplInput
  object.  All data is in MKS units (Hz, Tesla, W/m^3).
"""
SpecificPowerLossData

struct SpecificPowerLossData
  frequency :: Tuple  # in Hz
  mb :: Tuple  # y = mx + b
  # y in W/m^3
  # x in Tesla
  function SpecificPowerLossData(frequency,mb)
    if length(frequency) == 0
      throw(ArgumentError("no frequency list"))
    end
    if length(frequency) == 1
      throw(ArgumentError("single frequency not allowed"))
    end
    if length(frequency)!=length(mb)
      throw(ArgumentError("lengths do not match"))
    end
    new(frequency,mb)
  end
end

"""
    SplInput(data::Tuple)

Simplify manual input of specific power loss data.

Data format is as follows.
(f1,(x1,y1),(x2,y2), f2,(x3,y3),(x4,y4), ...)

**Elements of Tuple**
- fn    -- frequency (Hz)
- xn    -- flux density (mT)
- yn    -- specific power loss (Kw/m^3)

The only purpose of this object is to pass to `SpecificPowerLossData`.  Data is
converted to MKS units there.
"""
struct SplInput
  data :: Tuple
end

function SpecificPowerLossData(input::SplInput)
    data=input.data
    l = length(data)
    if mod(l,3)!=0
      throw(ArgumentError("incorrect input length"))
    end
    output_length = div(l,3)
    frequency = ntuple(x->data[x*3-2],output_length)
    function slope_offset(x)
      i = x*3-2
      (f,(x1,y1),(x2,y2)) = data[i:i+2]
      x1 = log10(0.001*x1) # convert mT to T
      x2 = log10(0.001*x2) # convert mT to T
      y1 = log10(1000.0*y1) # convert kW/m^3 to W/m^3
      y2 = log10(1000.0*y2) # convert kW/m^3 to W/m^3
      m = (y2-y1)/(x2-x1)
      b = y1-m*x1
      (m,b)
    end
    mb = ntuple(slope_offset, output_length)
    SpecificPowerLossData(frequency,mb)
end

"""
    FerriteProperties(frequency_range, troom, thot, bh_room, bh_hot, spl_hot)

Store material data.

**Fields**
- `fmin`              -- minimum recommended operating frequency
- `fmax`              -- maximum recommended operating frequency
- `troom`             -- typicaly 25C
- `thot`              -- typicaly 100C
- `bh_room`           -- BH loop at room temperature
- `bh_hot`            -- BH loop at hot temperature
- `spl_hot`           -- specfic power loss data at hot temperature
"""
struct FerriteProperties
  fmin :: Float64
  fmax :: Float64
  troom :: Float64
  thot :: Float64
  bh_room :: BHloop
  bh_hot :: BHloop
  spl_hot :: SpecificPowerLossData
end

"""
    PCB_Specification(trace_edge_gap,
                      trace_trace_gap,
                      outer_copper_thickness,
                      inner_copper_thickness = 0.0,
                      number_of_layers = 2,
                      ρ_20=1.68e-8,
                      temperature_coefficient=0.003862)

Store PCB data.

** Fields **
- `trace_edge_gap`          -- minimum distance from trace to PCB edge (m)
- `trace_trace_gap`         -- minimum distance between traces (m)
- `outer_copper_thickness`  -- thickness of top and bottom copper layers (m)
- `inner_copper_thickness`  -- thickness of inner copper layers (m)
- `number_of_layers`        -- number of copper layers
- `ρ_20`                    -- conductivity, default to 1.68e-8 Ωm for Cu @ 20C
- `temperature_coefficient` -- default to 0.003862 1/K for Cu
"""
struct PCB_Specification
  trace_edge_gap :: Float64
  trace_trace_gap :: Float64
  outer_copper_thickness :: Float64
  inner_copper_thickness :: Float64
  number_of_layers :: Int
  ρ_20 :: Float64 # Ωm @ 20C
  temperature_coefficient :: Float64 # 1/K
  function PCB_Specification(trace_edge_gap,
                     trace_trace_gap,
                     outer_copper_thickness,
                     inner_copper_thickness = 0.0,
                     number_of_layers = 2,
                     ρ_20=1.68e-8, # Ωm for Cu @ 20C
                     temperature_coefficient=0.003862) # 1/K for Cu
    new(trace_edge_gap,
        trace_trace_gap,
        outer_copper_thickness,
        inner_copper_thickness,
        number_of_layers,
        ρ_20,
        temperature_coefficient)
  end
end

"""
    WindingLayer

**Fields**
- `width`           -- width of trace (m)
- `length`          -- length of trace (m)
- `thickness`       -- thickness of trace (m)
- `number_of_turns` -- number of turns
"""
struct WindingLayer
  width :: Float64
  length :: Float64
  thickness :: Float64
  number_of_turns :: Int
end

"""
    WindingLayer(pcb :: PCB_Specification,
                 isouter :: Bool,
                 core :: CoreGeometry,
                 number_of_turns :: Int)

Create a `WindingLayer` for a specific core and PCB.
"""
function WindingLayer(pcb :: PCB_Specification,
                      isouter :: Bool,
                      core :: CoreGeometry,
                      number_of_turns :: Int)
  trace_width = (core.winding_aperture-2*pcb.trace_edge_gap-
    (number_of_turns-1)*pcb.trace_trace_gap)/number_of_turns
  trace_length = 0.0
  for i in 0:number_of_turns-1
    r = core.half_center_width+pcb.trace_edge_gap+
        0.5*trace_width+i*(trace_width+pcb.trace_trace_gap)
    trace_length += 2π*r
  end
  trace_length += 2*core.center_length
  trace_thickness =
    isouter ? pcb.outer_copper_thickness : pcb.inner_copper_thickness
  WindingLayer(trace_width, trace_length, trace_thickness, number_of_turns)
end

"""
    Winding(pcb::PCB_Specification,
            windinglayers,
            isseries::Bool)

Create a `Winding` by combining several `WindingLayers`.
"""
struct Winding
  pcb :: PCB_Specification
  windinglayers :: Array{WindingLayer,1}
  isseries :: Bool
  turns :: Int
  function Winding(pcb::PCB_Specification,windinglayers,isseries::Bool)
    if length(windinglayers)==0
      throw(ArgumentError("must have at least one winding"))
    end
    turns_1 = windinglayers[1].number_of_turns
    turns = turns_1
    for i in 2:length(windinglayers)
      turns_i = windinglayers[i].number_of_turns
      if isseries
        turns += turns_i
      elseif turns_i != turns_1
        throw(ArgumentError("parallel windings must have same number of turns"))
      end
    end
    new(pcb,windinglayers,isseries,turns)
  end
end

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

`Transformer` is a combination of `Magnetics` and two or more `Winding`s.
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

struct ChanInductor
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
