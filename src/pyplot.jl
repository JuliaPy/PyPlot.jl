module pyplot
using Base

PYPLOT_JL_HOME = getenv("PYPLOT_JL_HOME")

## matploblib.pyplot wrapper
include("$PYPLOT_JL_HOME/plot.jl")
## other auxiliary functions
include("$PYPLOT_JL_HOME/aux.jl")

end # end module
