
flux = 0.01 # Tesla
frequency = 2e6 # Hz
coreloss = specific_power_loss(ferrite_dict["3f4"],flux,frequency)
flux2 = flux_density(ferrite_dict["3f4"],coreloss,frequency)

specific_power_loss(ferrite_dict["4f1"],0.01,1e6)

core = "e14"
plate = "plt14"
material = "3f4"
turns = 4 # per layer
trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
thickness = copper_weight_to_meters(1.0) # oz
loss_limit = 150e3 # W/m^3
frequency = 1e6 # operating frequency
flux_density_peak = flux_density(ferrite_dict[material],loss_limit,frequency)
flux_density_pp = 2*flux_density_peak
vst = volt_seconds_per_turn(core_geometry_dict[core],flux_density_pp)
vt = volts_per_turn(core_geometry_dict[core],ferrite_dict[material],loss_limit,frequency)
r = winding_resistance(Winding(core_geometry_dict[core],
                       turns,
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
specific_power_loss(spl_3f3,0.06,300e3)*0.001
frequency = spl_3f3.frequency[3]
(m,b) = spl_3f3.mb[3]
m*0.06 +b

using PlanerTransformer
using Plots
spl = specific_power_loss(ferrite_dict["3f3"],0.02,600e3)
flux_density(ferrite_dict["3f3"],spl,600e3)

material = ferrite_dict["3f4"]
spl = 200e3
f = linspace(material.fmin,material.fmax+1e6,100)
b = [flux_density(material,spl,x) for x in f]
bf = b.*f
plot(f./1e6,bf)
gui()

using PlanerTransformer
trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
outer_copper_thickness = copper_weight_to_meters(1.0)
inner_copper_thickness = copper_weight_to_meters(1.0)
number_of_layers = 4
pcb = PCB_Specification(trace_edge_gap,
                        trace_trace_gap,
                        outer_copper_thickness,
                        inner_copper_thickness,
                        number_of_layers)

e_core = core_geometry_dict["e14"]
plate = core_geometry_dict["plt14"]
material = ferrite_dict["3f4"]
layer1 = winding_layer(pcb,true,e_core,3)
layer2 = winding_layer(pcb,false,e_core,2)
layer3 = winding_layer(pcb,false,e_core,2)
layer4 = winding_layer(pcb,true,e_core,3)
primary = Winding(pcb,[layer1,layer4],false)
secondary = Winding(pcb,[layer2,layer3],true)
magnetics = Magnetics(material, [e_core,plate])
transformer = Transformer(magnetics,[primary,secondary])
frequency = 1e6
volts(transformer,450e3,frequency)
tpd =TransformerPowerDissipation(transformer,[2.0,5.0],frequency)
winding_resistance(transformer)
ci = chan_inductor(transformer)
PlanerTransformer.center_frequency(transformer)
equivalent_parallel_resistance(transformer,.333,1e6)

turns.(transformer.windings)


using PlanerTransformer
trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
outer_copper_thickness = copper_weight_to_meters(1.0)
inner_copper_thickness = copper_weight_to_meters(1.0)
number_of_layers = 2
pcb = PCB_Specification(trace_edge_gap,
                        trace_trace_gap,
                        outer_copper_thickness,
                        inner_copper_thickness,
                        number_of_layers)

e_core = core_geometry_dict["e14"]
plate = core_geometry_dict["plt14"]
material = ferrite_dict["3f4"]
layer1 = winding_layer(pcb,true,e_core,1)
layer2 = winding_layer(pcb,true,e_core,1)
primary = Winding(pcb,[layer1],false)
secondary = Winding(pcb,[layer2],false)
magnetics = Magnetics(material, [e_core,plate])
transformer = Transformer(magnetics,[primary,secondary])
frequency = 1e6
volts(transformer,450e3,frequency)
tpd =TransformerPowerDissipation(transformer,[0.5,1.0],frequency)
winding_resistance(transformer)
ci = chan_inductor(transformer)
PlanerTransformer.center_frequency(transformer)
equivalent_parallel_resistance(transformer,0.5,1e6)






ferrite_dict["3f3"]



struct T
  x :: Array{Int,1}
end
T([1,2,3,4])
T((1,2,3,4))



cd("C:\\Users\\Chris")
cd("C:/Users/Chris/.julia/v0.6/PlanerTransformer/docs")
include("make.jl")
# ER14.5/3/7-3F4-S
# E14/3.5/5/R-3F4
# PLT14/5/1.5/S-3F4
using PlanerTransformer
g = core_geometry_dict["i20"]
ex1 = :($(fieldnames(CoreGeometry)[1])(x::CoreGeometry) = x.$(fieldnames(CoreGeometry)[1]))
ex2 = :($(fieldnames(CoreGeometry)[2])(x::CoreGeometry) = x.$(fieldnames(CoreGeometry)[2]))

eval(ex)

name(g)

function functionalize_fieldnames(x)
  for field in fieldnames(x)
    @eval $field(y::$x) = y.$field
  end
end

functionalize_fieldnames(CoreGeometry)
name(g)
winding_aperture(g)


fieldnames(CoreGeometry)


core_geometry_dict["er12.5_plt"]




a = 2.0
a *= 1e-3



# fff
