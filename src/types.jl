export CoreGeometry
export BHloop, SpecificPowerLossData
export FerriteProperties
export PCB_Specification, WindingLayer
export Winding
export Magnetics, Transformer

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
        throw(ArgumentError("effective area of all cores must be the same"))
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

struct ChanInductor
  hc :: Float64
  bs :: Float64
  br :: Float64
  a :: Float64
  lm :: Float64
  lg :: Float64
  n :: Float64
end
function Base.show(io::IO,ci::ChanInductor)
  println(io,"Hc=",ci.hc,", Bs=",ci.bs,", Br=",ci.br,", A=",
          ci.a,", Lm=",ci.lm,", Lg=",ci.lg,", N=",ci.n)
end
