#  Types and methods used to create core_geometry_dict and ferrite_dict


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
    Magnetics_ER_Input

Direct entry of Magnetics ER core values from datasheet.

**Fields**
- `effective_length`    -- mm
- `effective_area`      -- mm^2
- `effective_volume`    -- mm^3
- `mass`                -- g
- `e`                   -- mm
- `f`                   -- mm
"""
struct Magnetics_ER_Input
  effective_length :: Float64
  effective_area :: Float64
  effective_volume :: Float64
  mass :: Float64
  e :: Float64
  f :: Float64
end

function CoreGeometry(x::Magnetics_ER_Input)
  winding_aperture = (x.e-x.f)/2.0
  half_center_width = x.f/2.0
  center_length = 0.0
  # convert to MKS units
  winding_aperture *=1e-3 # mm to m
  half_center_width *=1e-3 # mm to m
  effective_length = x.effective_length *1e-3 # mm to m
  effective_volume = x.effective_volume * 1e-9 # mm^3 to m^3
  effective_area = x.effective_area * 1e-6 # mm^2 to m^2
  mass = x.mass * 1e-3 # g to Kg
  CoreGeometry(winding_aperture, half_center_width, center_length,
               effective_volume, effective_area, effective_length, mass)
end

"""
    Magnetics_I_Input

Direct entry of Magnetics I core values from datasheet.

**Fields**
- `effective_length`    -- mm
- `effective_area`      -- mm^2
- `effective_volume`    -- mm^3
- `mass`                -- g
"""
struct Magnetics_I_Input
  effective_length :: Float64
  effective_area :: Float64
  effective_volume :: Float64
  mass :: Float64
end

function CoreGeometry(x::Magnetics_I_Input)
  winding_aperture = 0.0
  half_center_width = 0.0
  center_length = 0.0
  # convert to MKS units
  effective_length = x.effective_length *1e-3 # mm to m
  effective_volume = x.effective_volume * 1e-9 # mm^3 to m^3
  effective_area = x.effective_area * 1e-6 # mm^2 to m^2
  mass = x.mass * 1e-3 # g to Kg
  CoreGeometry(winding_aperture, half_center_width, center_length,
               effective_volume, effective_area, effective_length, mass)
end
