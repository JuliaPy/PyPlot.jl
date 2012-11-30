module pyplot
using Base

JuliaLab_HOME = getenv("JuliaLab_HOME")

## matploblib.pyplot wrapper
include("$JuliaLab_HOME/plot.jl")
## other auxiliary functions
include("$JuliaLab_HOME/aux.jl")

end # end module
