using PlanerTransformer
using Test

function testshow(x, verified::String)
  buf = IOBuffer()
  show(buf,x)
  @test String(take!(buf)) == verified
end

include("test_FerriteProperties.jl")
include("test_transformer_construction.jl")
include("test_TransformerAnalysis.jl")
