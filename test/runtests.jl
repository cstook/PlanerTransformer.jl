using PlanerTransformer
using Base.Test

function testshow(x, verified::String)
  buf = IOBuffer()
  show(buf,x)
  @test String(take!(buf)) == verified
end


include("test_CoreGeometry.jl")
include("test_Winding.jl")
include("test_FerriteProperties.jl")
include("test_TransformerDesign.jl")
