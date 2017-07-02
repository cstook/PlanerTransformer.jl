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

Define core geometry and type of ferrite, or use data from `core_geometry_dict` and `ferrite_dict`.
```@example 1
e_core = core_geometry_dict["e14"]
```
```@example 1
plate = core_geometry_dict["plt14"]
```
```@example 1
material = ferrite_dict["3f4"]
```
Define the windings.  In this case the primary will be 3 turns, 3 on each outer
layer, both layers in parallel.  The secondary will be 4 turns, 2 turns on each
inner layer, both layers in series.
```@example 1
layer1 = winding_layer(pcb,true,e_core,3)
layer2 = winding_layer(pcb,false,e_core,2)
layer3 = winding_layer(pcb,false,e_core,2)
layer4 = winding_layer(pcb,true,e_core,3)
primary = Winding(pcb,[layer1,layer4],false)
secondary = Winding(pcb,[layer2,layer3],true)
```

Define the magnetics.  Effective areas for cores in the magnetic circuit must
match.
```@example 1
magnetics = Magnetics(material, [e_core, plate])
```

Define the transformer.  The first element in the winding array should be the
input to the transformer.
```@example 1
transformer = Transformer(magnetics, [primary, secondary])
```

Now that the transformer is defined, we can estimate some circuit parameters.
First pick an operating frequency, and a maximum specific power loss
for the core.
```@example 1
frequency = 1e6 # Hz
spl_max = 450e3 # W/m^3
```
Corresponding maximum peak to peak flux density.
```@example 1
flux_density_max_pp = flux_density(transformer, spl_max, frequency) # Tesla
```
Maximum volt seconds on each winding.
```@example 1
volt_seconds_max = volt_seconds(transformer, flux_density_max_pp)
```
Power Dissipation with 0.5Vpp 50% duty cycle square wave on the primary and
1App load on the secondary.
```@example 1
primary_voltage_pp = 0.5
output_current_pp = 1.0
tpd =TransformerPowerDissipation(transformer,
              [primary_voltage_pp, output_current_pp], frequency)
total_power = tpd.total_power # W
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
