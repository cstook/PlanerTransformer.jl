export CoreGeometry


"""julia
    CoreGeometry

**Fields**
- `winding_aperture`    -- m
- `half_center_width`   -- m
- `center_length`       -- m
- `effective_volume`    -- m^3
- `effective_area`      -- m^2
- `mass`                -- Kg
"""
immutable CoreGeometry
  # all values are in MKS units
  winding_aperture :: Float64
  half_center_width :: Float64  # center_radius for ER
  center_length :: Float64
  effective_volume :: Float64
  effective_area :: Float64
  mass :: Float64
end
