module Vtuple
import Base: zero, rand, +, -, *, /

const IntOrFloat = Union{Int,Float64}
const Vect = NTuple{3,Float64}
# const Vect = Tuple{Float64,Float64,Float64}

function Vect(x::T, y::T, z::T) where {T<:IntOrFloat}
    Float64.((x, y, z))
end
function Vect()
    (0, 0, 0)
end

function zero(::T)::Vect where {T<:Union{Vect,Type{Vect}}}
    Vect()
end

function rand(::Type{Vect}, r::AbstractRange{Float64})
    (rand(r), rand(r), rand(r))
end

function +(v1::Vect, v2::Vect)::Vect
    v1 .+ v2
end

function -(v1::Vect, v2::Vect)::Vect
    v1 .- v2
end

function *(v::Vect, n::T)::Vect where {T<:IntOrFloat}
    v .* n
end

function *(n::T, v::Vect)::Vect where {T<:IntOrFloat}
    v .* n
end

function /(v::Vect, n::T)::Vect where {T<:IntOrFloat}
    v ./ n
end

function sum(v::Vect)::Float64
    v[1] + v[2] + v[3]
end

function length(v::Vect)::Float64
    sqrt(sum(v .^ 2))
end
function distance(v1::Vect, v2::Vect)::Float64
    length(v1 - v2)
end
function normalize(v::Vect)::Vect
    v / length(v)
end

let
    pcv1, pcv2 = Vect(1, 2, 3), Vect(2, 4, 8)

    _ = pcv1 + pcv2
    _ = pcv1 - pcv2
    _ = 2 * pcv2
    _ = pcv1 / 3

    _ = length(pcv1)
    _ = distance(pcv1, pcv2)
    _ = normalize(pcv1)
end

end
