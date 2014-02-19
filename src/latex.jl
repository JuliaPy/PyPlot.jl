# Matplotlib supports LaTeX equations in plot labels etcetera, but
# these are annoying to type as string literals in Julia because of
# all the escaping required, e.g. "\$\\alpha + \\beta\$".   To simplify
# this, we add a new string type with a macro constructor, so that
# one can simply do L"$\alpha + \beta$".

export LaTeXString, @L_str, @L_mstr
import Base: writemime, show, write, endof, getindex, sizeof, search, rsearch, isvalid, next, length

immutable LaTeXString <: String
    s::ByteString
end
macro L_str(s, flags...) LaTeXString(s) end
macro L_mstr(s, flags...) LaTeXString(s) end

write(io::IO, s::LaTeXString) = write(io, s.s)
writemime(io::IO, ::MIME"application/x-latex", s::LaTeXString) = write(io, s)
writemime(io::IO, ::MIME"text/latex", s::LaTeXString) = write(io, s)

function show(io::IO, s::LaTeXString)
    print(io, "L")
    Base.print_quoted_literal(io, s.s)
end

bytestring(s::LaTeXString) = bytestring(s.s)
endof(s::LaTeXString) = endof(s.s)
next(s::LaTeXString, i::Int) = next(s.s, i)
length(s::LaTeXString) = length(s.s)
getindex(s::LaTeXString, i::Int) = getindex(s.s, i)
getindex(s::LaTeXString, i::Integer) = getindex(s.s, i)
getindex(s::LaTeXString, i::Real) = getindex(s.s, i)
getindex(s::LaTeXString, i::Range1{Int}) = getindex(s.s, i)
getindex{T<:Integer}(s::LaTeXString, i::Range1{T}) = getindex(s.s, i)
getindex(s::LaTeXString, i::AbstractVector) = getindex(s.s, i)
sizeof(s::LaTeXString) = sizeof(s.s)
search(s::LaTeXString, c::Char, i::Integer) = search(s.s, c, i)
rsearch(s::LaTeXString, c::Char, i::Integer) = rsearch(s.s, c, i)
isvalid(s::LaTeXString, i::Integer) = isvalid(s.s, i)
