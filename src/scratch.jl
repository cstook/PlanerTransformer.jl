
flux = 0.01 # Tesla
frequency = 2e6 # Hz
coreloss = specificpowerloss(ferrite_dict["3f4"],flux,frequency)
flux2 = flux_density(ferrite_dict["3f4"],coreloss,frequency)

specificpowerloss(ferrite_dict["4f1"],0.01,1e6)

core = :e18
plate = :plt18
material = "3f4"
number_of_turns = 4 # per layer
trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
thickness = copper_weight_to_meters(1.0) # oz
loss_limit = 150e3 # W/m^3
frequency = 1e6 # operating frequency
flux_density_peak = flux_density(ferrite_dict[material],loss_limit,frequency)
flux_density_pp = 2*flux_density_peak
i = 5.0
vst = volt_seconds_per_turn(core_geometry_dict[core],flux_density_pp)
vt = volts_per_turn(core_geometry_dict[core],ferrite_dict[material],loss_limit,frequency)
r = resistance(Winding(core_geometry_dict[core],
                       number_of_turns,
                       trace_edge_gap,
                       trace_trace_gap,
                       thickness))
p_winding = i^2 * r  # per layer
p_ferrite = loss_limit * (core_geometry_dict[core].effective_volume
            + core_geometry_dict[plate].effective_volume)

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

using PlanerTransformer
spl = specificpowerloss(ferrite_dict["3f3"],0.02,600e3)
flux_density(ferrite_dict["3f3"],spl,600e3)

# ER14.5/3/7-3F4-S
# E14/3.5/5/R-3F4
# PLT14/5/1.5/S-3F4
