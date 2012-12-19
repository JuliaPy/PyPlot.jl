#!/usr/bin/env julia
# File: wrap.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: wrap functions from pyplot
# Created: December 19, 2012

for func in funcs
    @eval begin
        function ($func)(args...)
            cmd = string($func)

            args_str = ""
            for arg in args
                args_str += parse(arg)
            end

            ## send code to ipython
            send("$cmd($args_str)")
        end
    end
end
