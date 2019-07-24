module TreeShaker

# Deps
using SnoopCompile # for snooping
using Random # for snoop log names
using Pkg # context/manifest info
using Suppressor # for optionally suppressing build & test output

# Includes 
include("meat.jl")

# Exports 
export shake

end # module
