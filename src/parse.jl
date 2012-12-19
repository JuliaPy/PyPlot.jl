#!/usr/bin/env julia
# File: parser.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: translate julia type to python code string
# Created: December 19, 2012

## concatenate strings
import Base.+
function +(a::String, b::Any)
    return strcat(a, string(b))
end

## parse Char
function parse(ch::Char)
    return "'$ch', "
end

## parse Symbol
function parse(sym::Symbol)
    return string(sym) + "="
end

## parse Bool
function parse(bl::Bool)
    return bl ? "True" : "False"
end

## parse String
function parse(str::String)
    if str == ""
        return ""
    else
        return "'$str', "
    end
end

## parse Array
function parse(arr::Array)
    if arr == []
        return ""
    else
        # generate warning when plot complex arrays
        if eltype(arr) <: Complex
            println("ComplexWarning: Casting complex values to real discards the imaginary part!")
            arr = real(arr)
        end

        str = "["
        for a in arr
            str += parse(real(a))
        end
        return str + "], "
    end
end

## parse Tuple
function parse(tuple::Tuple)
    # return empty string when tuple is empty
    if tuple == ()
        return ""
    else
        str = "("
        for t in tuple
            str += parse(t)
        end
        return str + "), "
    end
end

## parse everything else
function parse(i::Any)
    return string(i) + ", "
end
