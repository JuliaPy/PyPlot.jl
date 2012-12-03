#!/usr/bin/env julia
# File: util.jl
# Author: Junfeng Li <li424@mcmaster.ca>
# Description: useful functions that hasn't been implemented by julia core
# team yet
# Created: November 21, 2012

export J, integrate, bisec, mismore, mfilter

## autojump :)
function J(dst::String)
    cd(readchomp(`autojump $dst`))
    cwd()
end
J() = J("")


# one-dimensional numerical integration: quadrature
function integrate(f::Function, x1::Real, x2::Real)
    N = 100     # sampling
    sum = 0
    xa = linspace(x1, x2, N)
    for i = 2:N-1
        sum += f(xa[i])
    end
    sum += (f(x1) + f(x2)) / 2
    sum *= (x2 - x1) / (N - 1)
    return sum
end


# root: bisection method
function bisec(f::Function, a::Real, b::Real)
    TOL = 1.0e-9 # tolerence
    c = (a + b)/2
    while abs(f(c)) > TOL
        if f(c) * f(a) > 0
            a = c
        else
            b = c
        end
        c = (a+b)/2
        #println(a, '\t', b, '\t', c, '\t', f(c))
    end
    return c
end

# Comparison between two complex effective indices,
# thus made sort() available. Used in simulation and
# calculation of waveguide.
# Definion: when x is close to x-axis, i.e., has a
# small part of imag, the bigger real part, the bigger
# of x; when x has a significant imag part, the bigger
# imag part, the bigger of x.
function mismore(x1::Complex128, x2::Complex128)
    THOLD = -0.2    # key threshold

    if imag(x1) > THOLD && imag(x2) > THOLD
        return (real(x1) > real(x2)) ? true : false
    elseif imag(x1) < THOLD && imag(x2) < THOLD
        return (imag(x1) > imag(x2)) ? true : false
    elseif imag(x1) > THOLD && imag(x2) < THOLD
        return true
    else
        return false
    end
end


## filter/sort effective indices
function mfilter(A::Array, start::Number, num::Integer)
    B = copy(A)
    B = sort(mismore, B)
    idx = 0
    for i in 1:length(B)
        if mismore(B[i], complex(start))
            continue
        else
            idx = i
            break
        end
    end
    return B[idx:idx + num - 1]
end
mfilter(A::Array, num::Integer) = mfilter(A, Inf, num)
mfilter(A::Array) = mfilter(A, Inf, 6)
