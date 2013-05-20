#!/usr/bin/env julia
# File: wrap.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: wrap functions from pyplot
# Created: December 19, 2012

for func in funcs
    @eval begin
        function ($func)(args...; kargs...)
            # translate function calls to strings
            cmd_str = string($func)
            args_str = parse_args(args, kargs)

            # send commands to ipython
            send("$cmd_str($args_str)")
        end
    end
    eval(Expr(:export, func))
end
