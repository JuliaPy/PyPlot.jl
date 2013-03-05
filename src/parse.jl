#!/usr/bin/env julia
# File: parser.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: translate julia type to python code string
# Created: December 19, 2012

## concatenate strings
import Base.+
function +(a::String, b::Any)
    return string(a, string(b))
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
    return "'$str', "
end

## parse everything else
function parse(i::Any)
    return string(i) + ", "
end

## parse Array
function parse(arr::Array)
    # deal with empty
    if arr == []
        println("Warning: Empty array!")
        return ""
    end

    # deal with complex arrays
    if eltype(arr) <: Complex
        println("ComplexWarning: Casting complex values to real discards the imaginary part!")
        arr = real(arr)
    end

    str = "["
    for a in arr
        str += parse(a)
    end
    return str + "], "
end

## parse Tuple
function parse(tuple::Tuple)
    # deal with empty
    if tuple == ()
        println("Warning: Empty tuple!")
        return ""
    end

    str = "("
    for t in tuple
        str += parse(t)
    end
    return str + "), "
end

## expose macro
macro pyplot(cmds...)
    cmds2 = ""
    for cmd in cmds
        if typeof(cmd) == Expr
            cmds2 += string(cmd)[3:end-1]
        else
            cmds2 += string(cmd)
        end
        cmds2 += " "
    end
    send(cmds2)
end

export @pyplot
