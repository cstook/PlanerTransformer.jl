# Introduction

This module is based on the design procedure described in
[Designing Planar Magnetics](http://www.ti.com/download/trng/docs/seminar/Topic4LD.pdf).

Load the module.
```@example 1
using PlanerTransformer
```

Define the PCB.
```@example 1
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
```
Operate at 500kHz with a maximum specific power loss of 150kW/m^3.
```@example 1
frequency = 0.5e6 # Hz
spl_max = 150e3 # W/m^3
```

Define core geometry and type of ferrite, or use data from `core_geometry_dict`
 and `ferrite_dict`.
```@example 1
core = core_geometry_dict["er25/5.5_plt"]
```
```@example 1
material = ferrite_dict["3f35"]
```
Define the magnetics as a material and a core geometry.
```@example 1
magnetics = Magnetics(material, core)
```
Interpolate off of specific power loss data to maximum flux density.
```@example 1
flux_density_max_pp = flux_density(magnetics, spl_max, frequency) * 2.0
```
Calculate maximum volt seconds per turn.
```@example 1
vspt = volt_seconds_per_turn(magnetics, flux_density_max_pp)
```
Define the windings.  These windings are just given as an example use of the
package.  They are not optimized for any input voltage and output current.  
The primary will be 3 turns, 3 on each outer layer, both layers in parallel.  
The secondary will be 4 turns, 2 turns on each inner layer, both layers in series.
```@example 1
layer1 = winding_layer(pcb, true, core, 3)
layer2 = winding_layer(pcb, false, core, 2)
layer3 = winding_layer(pcb, false, core, 2)
layer4 = winding_layer(pcb, true, core, 3)
primary = Winding(pcb, [layer1, layer4], false)
secondary = Winding(pcb, [layer2, layer3], true)
```

Define the transformer.  The first element in the winding array should be the
input to the transformer.
```@example 1
transformer = Transformer(magnetics, [primary, secondary])
```

Now that the transformer is defined, we can estimate some circuit parameters.

Maximum volt seconds on each winding.
```@example 1
volt_seconds_max = volt_seconds(transformer, flux_density_max_pp)
```
Power dissipation with 0.5Vpp 50% duty cycle square wave on the primary and
1App load on the secondary.
```@example 1
primary_voltage_pp = 0.5
output_current_pp = 1.0
tpd =TransformerPowerDissipation(transformer,
              [primary_voltage_pp, output_current_pp], frequency)
tp = total_power(tpd) # W
```

Parameters for a LTspice transformer model can also be computed.
```@example 1
r1_r2 = winding_resistance(transformer)
```
```@example 1
l1 = chan_inductor(transformer)
```
```@example 1
r3 = equivalent_parallel_resistance(transformer, primary_voltage_pp, frequency)
```
```@example 1
n1_n2 = turns(transformer)
```
![LTspice transformer model](LTspice transformer model.jpg)
