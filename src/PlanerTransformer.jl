__precompile__()

module PlanerTransformer
include("types.jl")
include("methods.jl")
include("TransformerPowerDissipation.jl")

# create ferrite and core dictionaries
include("DataEntry.jl")
include("FerriteData.jl")
include("CoreData.jl")

end # module
