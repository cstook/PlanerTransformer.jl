export CoreGeometry
export BHloop, SpecificPowerLossData
export FerriteProperties
export PCB_Specification

include("ConverterTypes.jl")
"""
    CoreGeometry

**Fields**
- `name`                      -- string identifying the core
  `winding_aperture_height`  -- m
- `winding_aperture`          -- m
- `half_center_width`         -- m
- `center_length`             -- m
- `effective_volume`          -- m^3
- `effective_area`            -- m^2
- `effective_length`          -- m
- `mass`                      -- Kg
"""
struct CoreGeometry
  # all values are in MKS units
  name :: String
  winding_aperture_height :: Float64
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
hc(x::BHloop) = x.hc
bs(x::BHloop) = x.bs
br(x::BHloop) = x.br

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
- `name`              -- string identifying the ferrite
- `fmin`              -- minimum recommended operating frequency
- `fmax`              -- maximum recommended operating frequency
- `troom`             -- typicaly 25C
- `thot`              -- typicaly 100C
- `bh_room`           -- BH loop at room temperature
- `bh_hot`            -- BH loop at hot temperature
- `spl_hot`           -- specfic power loss data at hot temperature
"""
struct FerriteProperties
  name :: String
  fmin :: Float64
  fmax :: Float64
  troom :: Float64
  thot :: Float64
  bh_room :: BHloop
  bh_hot :: BHloop
  spl_hot :: SpecificPowerLossData
end

include("Stackup.jl")

"""
    PCB_Specification(trace_edge_gap  :: Float64,
                      trace_trace_gap :: Float64,
                      stackup         :: Stackup)

Store PCB data.

**Fields**
- `trace_edge_gap`          -- minimum distance from trace to PCB edge (m)
- `trace_trace_gap`         -- minimum distance between traces (m)
- `stackup`                 -- defines material and thickness of the layers
"""
struct PCB_Specification
  trace_edge_gap :: Float64
  trace_trace_gap :: Float64
  stackup :: Stackup
end

include("Winding.jl")
include("Transformer.jl")

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
