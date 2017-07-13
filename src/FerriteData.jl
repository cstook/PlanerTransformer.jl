export ferrite_dict

# Specific power loss data read off the charts
# frequency,(x1,y1),(x2,y2)
# frequency if Hz
# x1, x2 flux density in mT
# y1, y2 specific power loss kW/m^3
spldata_3f3 = SplInput((
  25e3,(100,14),(300,270),
  100e3,(62,20,),(240,750),
  200e3,(38,8),(190,1100),
  400e3,(20,17),(140,1700),
  700e3,(12,20),(80,1750)
  ))
spldata_3f35 = SplInput((
  500e3,(42,52),(130,1400),
  1e6,(20,70),(68,1400)
  ))
spldata_3f4 = SplInput((
  25e3,(82,19),(210,360),
  100e3,(48,19),(170,1070),
  200e3,(35,19),(150,1300),
  400e3,(25,16),(140,1700),
  1e6,(15,20),(78,1900),
  2e6,(5.5,20),(40,1850),
  3e6,(4,40),(26,2000)
  ))
spldata_3f45 = SplInput((
  500e3,(22,12),(120,1700),
  1e6,(14,10),(95,1750),
  2e6,(5.5,14),(50,2000),
  ))
spldata_3f5 = SplInput((
  1e6,(15,10),(95,1750),
  2e6,(6.8,13),(57,1600),
  3e6,(4,15),(40,1700)
  ))
spldata_4f1 = SplInput((
  3e6,(5.3,33),(28,1400),
  5e6,(4,40),(22,1500),
  10e6,(3.2,43),(13,1500)
  ))


const ferrite_dict = Dict(
  "3f3" => FerriteProperties("3f3",0.2e6,0.5e6,25,100,
                             BHloop(15,.44,.15),
                             BHloop(10,.345,.120),
                             SpecificPowerLossData(spldata_3f3)),
  "3f35"=> FerriteProperties("3F35",0.5e6,1.0e6,25,100,
                              BHloop(40,.45,.2),
                              BHloop(25,.4,.15),
                              SpecificPowerLossData(spldata_3f35)),
  "3f4" => FerriteProperties("3f4",1e6,2e6,25,100,
                             BHloop(60,0.4,0.16),
                             BHloop(50,0.345,.14),
                             SpecificPowerLossData(spldata_3f4)),
  "3f45" => FerriteProperties("3f45",1e6,2e6,25,100,
                             BHloop(60,.375,.155),
                             BHloop(50,.360,.145),
                             SpecificPowerLossData(spldata_3f45)),
  "3f5" => FerriteProperties("3f5",2e6,4e6,25,100,
                             BHloop(60,.35,.15),
                             BHloop(50,.30,.12),
                             SpecificPowerLossData(spldata_3f5)),
  "4f1" => FerriteProperties("4f1",4e6,10e6,25,100,
                             BHloop(160,.275,.200),
                             BHloop(140,.250,.150),
                             SpecificPowerLossData(spldata_4f1))
  )
