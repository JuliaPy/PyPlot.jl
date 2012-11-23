module JuliaLab
using Base

JuliaLab_HOME = "/Users/ljunf/Documents/Projects/JuliaLab.jl/src"

## matploblib.pyplot wrapper
include("$JuliaLab_HOME/plot.jl")
## other auxiliary functions
include("$JuliaLab_HOME/aux.jl")

end # end module
