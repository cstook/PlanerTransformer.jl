export BHloop, SplInput, SpecificPowerLossData
export FerriteProperties
export flux_density, specificpowerloss



"""julia
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
"""julia
    SpecificPowerLossData(frequency::Tuple, mb::Tuple)
    SpecificPowerLossData(input::SplInput)

Capture specific power loss data from datasheet.

Data is stored as a series of linear approximations on a log log plot, one for
each frequency.

**Fields**
- `frequency`   -- frequency of linear approximation (Hz)
- `mb`          -- Tuple (slope, offset) defining the approximation

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

"""julia
    SplInput(data::Tuple)

Simplify manual input of specific power loss data.

Data format is as follows.
(f1,(x1,y1),(x2,y2), f2,(x3,y3),(x4,y4), ...)

**Elements of Tuple**
- `f1`    -- frequency (Hz)
- `xn`    -- flux density (mT)
- `yn`    -- specific power loss (Kw/m^3)

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

function interpolate_third_point(x1,y1,x2,y2, x3)
  m = (y2-y1)/(x2-x1)
  b = y1-x1*m
  return m*x3+b
end
function find_nearest_spl_frequency_indices(spl::SpecificPowerLossData,f::Float64)
  i = 2
  for i in 2:length(spl.frequency) # there will never be many of these
    if spl.frequency[i]>f break end
  end
  return i-1:i
end

"""julia
    specificpowerloss(spl::SpecificPowerLossData, flux_density, frequency)
    specificpowerloss(fp::FerriteProperties, flux_density, frequency)

Returns specific power loss.
"""
function specificpowerloss(spl::SpecificPowerLossData, flux_density::Float64, f::Float64)
  # spl = tabulated specific power loss data from graph on datasheet
  # flux_density = magnetic field strength in Tesla
  # f = frequency in Hz
  # retruns specfic power loss at flux_density in Tesla, f in W/m^3
  indexrange = find_nearest_spl_frequency_indices(spl,f)
  f_array = [spl.frequency[i] for i in indexrange]
  pv_array = [spl.mb[i][1]*log10(flux_density)+spl.mb[i][2] for i in indexrange]
  pv = 10^interpolate_third_point(f_array[1],pv_array[1],
                                    f_array[2],pv_array[2], f)
  return pv # specicic power loss (W/m^3) at flux_density, frequency f
end

"""julia
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

specificpowerloss(fp::FerriteProperties, flux_density::Float64, f::Float64) =
  specificpowerloss(fp.spl_hot,flux_density,f)

"""julia
    flux_density(spl::SpecificPowerLossData, coreloss, frequency)
    flux_density(fp::FerriteProperties, coreloss, frequency)

Returns magnetic field strength in Tesla.
"""
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
  return b # magametic field strength in Tesla
end
flux_density(fp::FerriteProperties, coreloss::Float64, f::Float64) =
  flux_density(fp.spl_hot,coreloss,f)
