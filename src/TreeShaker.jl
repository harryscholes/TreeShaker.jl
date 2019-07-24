module TreeShaker

# Deps
using SnoopCompile # for snooping
using Random # for snoop log names
using Pkg # context/manifest info
using Suppressor # for optionally suppressing build & test output

# Includes 
include("trunk.jl")

# Exports 
export shake

end # module
