__precompile__()

module PlanerTransformer
include("string_literals.jl")
include("types.jl")
include("TransformerAnalysis.jl")
include("functionalize_fieldnames.jl")
include("methods.jl")


# create ferrite and core dictionaries
include("DataEntry.jl")
include("FerriteData.jl")
include("CoreData.jl")

end # module
