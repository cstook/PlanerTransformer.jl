# Design

!!! note
    All fields of structs can be accessed as functions.

## PCB
```@docs
Stackup
LayerMaterial
Dielectric
Conductor
copper_weight_to_meters
PCB_Specification
```
## Windings
```@docs
Windings
windings
WindingGeometry
winding_resistance
turns
capacitance
leakage_inductance
does_pcb_fit
```
## Transformer
```@docs
Transformer
volt_seconds_per_turn
volt_seconds
flux_density
specific_power_loss
```
## Analysis
```@docs
TransformerPowerAnalysis
transformer_power_analysis
winding_power
total_power
input_power
output_power
efficiency
r_core
chan_inductor
```
