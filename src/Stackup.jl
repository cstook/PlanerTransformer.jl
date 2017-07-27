export LayerMaterial, Conductor, Dielectric, Stackup
export copper, fr408


abstract type LayerMaterial end
name(::LayerMaterial) = ""
ρ_20(::LayerMaterial) = NaN
tc(::LayerMaterial) = NaN
ϵ(::LayerMaterial) = NaN

struct Conductor <: LayerMaterial
  name  :: String
  ρ_20  :: Float64
  tc    :: Float64
end
conductivity(c::Conductor, temperature) = conductivity(c.ρ_20,c.tc,temperature)
const copper = Conductor("copper",1.68e-8, 0.003862) # (Ωm, 1/K)

const ϵ0 = 8.854187817e-12
struct Dielectric <: LayerMaterial
  name :: String
  ϵ    :: Float64
end
const fr408 = Dielectric("fr408",3.67*ϵ0)



"""
    Stackup(material,thickness)

Specify the PCB stackup.

example:
for double sided FR408 PCB with 1oz copper 63mil thick.
`Stackup([copper,fr408,copper],[0.48e-3,1.6e-3 - (2*0.48e-3),0.48e-3])`

copper and fr408 are exported constants.
"""
struct Stackup
  material  :: Tuple
  thickness :: Tuple
  function Stackup(s::Tuple,t::Tuple)
    if length(s) != length(t)
      throw(ArgumentError("length of material and thickness must match"))
    end
    if length(s) < 3
      throw(ArgumentError("stackup must have at least three layers"))
    end
    if mod(length(s),2) == 0
      throw(ArgumentError("stackup must have odd number of layers"))
    end
    for i in eachindex(s)
      if mod(i,2) == 0
        if typeof(s[i]) != Dielectric
          throw(ArgumentError("even layers must be Dielectric"))
        end
      else
        if typeof(s[i]) != Conductor
          throw(ArgumentError("odd layers must be Conductor"))
        end
      end
    end
    new(s,t)
  end
end
function Stackup{T<:LayerMaterial}(s::Vector{T}, t::Vector)
  Stackup(ntuple(x->s[x],length(s)), ntuple(x->t[x],length(t)))
end
