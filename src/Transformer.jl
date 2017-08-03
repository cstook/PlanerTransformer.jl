export Transformer, does_pcb_fit, core_name, ferrite_name

"""
    Transformer(ferrite, windings)

**Fields**
- `ferrite`   -- `FerriteProperties` object
- `windings`  -- `Windings` object
"""
struct Transformer
  ferrite :: FerriteProperties
  windings :: Windings
end

effective_volume(t::Transformer) = effective_volume(windings(t))
effective_area(t::Transformer) = effective_area(windings(t))
effective_length(t::Transformer) = effective_length(windings(t))
winding_aperature_height(t::Transformer) = winding_aperature_height(windings(t))
core_name(t::Transformer) = core_name(windings(t))
ferrite_name(t::Transformer) = name(ferrite(t))
"""
    does_pcb_fit(t)

`true` if PCB thickness is <= winding aperature height.
"""
does_pcb_fit(t) = pcb_thickness(t) <= winding_aperature_height(t)
