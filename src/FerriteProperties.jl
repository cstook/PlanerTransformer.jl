immutable BHloop
  Hc :: Float64
  Bs :: Float64
  Br :: Float64
end
immutable SpecificPowerLossData
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

# data input format (f1,(x1,y1),(x2,y2), f2,(x1,y1),(x2,y2))
# f in Hz, x in mT, y in kW/m^3
immutable SplInput
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
function specificpowerloss(spl::SpecificPowerLossData, flux_density::Float64, f::Float64)
  # spl = tabulated specific power loss data from graph on datasheet
  # flux_density = magnetic field strength in Tesla
  # f = frequency in Hz
  # retruns specfic power loss at flux_density in Tesla, f in W/m^3
  indexrange = find_nearest_spl_frequency_indices(spl,f)
  f_array = [spl.frequency[i] for i in indexrange]
  pv_array = [10^(spl.mb[i][1]*log10(flux_density)+spl.mb[i][2]) for i in indexrange]
  pv = interpolate_third_point(f_array[1],pv_array[1],
                                    f_array[2],pv_array[2], f)
  return pv # specicic power loss (W/m^3) at flux_density, frequency f
end

immutable FerriteProperties
  frequency_range :: FloatRange
  troom :: Float64
  thot :: Float64
  bh_room :: BHloop
  bh_hot :: BHloop
  spl_hot :: SpecificPowerLossData
end

specificpowerloss(fp::FerriteProperties, flux_density::Float64, f::Float64) =
  specificpowerloss(fp.spl_hot,flux_density,f)

function flux_density(spl::SpecificPowerLossData, coreloss::Float64, f::Float64)
  # spl = tabulated specific power loss data from graph on datasheet
  # coreloss = specfic power loss at b,f in W/m^3
  # f = frequency in Hz
  # returns magametic field strength in Tesla
  indexrange = find_nearest_spl_frequency_indices(spl,f)
  f_array = [spl.frequency[i] for i in indexrange]
  println(f_array)
  coreloss /= 1000 # convert to kW/m^3
  b_array = [10^((log10(coreloss)-spl.mb[i][1])/spl.mb[i][2]) for i in indexrange]
  println(b_array)
  b = interpolate_third_point(f_array[1],b_array[1],
                              f_array[2],b_array[2], f)
  return b # magametic field strength in Tesla
end
flux_density(fp::FerriteProperties, coreloss::Float64, f::Float64) =
  flux_density(fp.spl_hot,coreloss,f)


input_3f3 = SplInput((
  25e3,(100,14),(300,270),
  100e3,(62,20,),(240,750),
  200e3,(38,8),(190,1100),
  400e3,(20,17),(140,1700),
  700e3,(12,20),(80,1750)
  ))

spl_3f3 = SpecificPowerLossData(input_3f3)
specificpowerloss(spl_3f3,0.06,300e3)*0.001
frequency = spl_3f3.frequency[3]
(m,b) = spl_3f3.mb[3]
m*0.06 +b
