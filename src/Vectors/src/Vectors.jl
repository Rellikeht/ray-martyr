module Vectors

import Base: rand, zero, +, -, *, /

export Vect, IntOrFloat, Bounds
export normalize, distance, reflect
export inside, direction, rand
export +, -, *, /

const IntOrFloat = Union{Int,Float64}
const Vect = NTuple{3,Float64}

function Vect(x::T, y::T, z::T) where {T<:IntOrFloat}
    Float64.((x, y, z))
end
function Vect()
    Float64.((0, 0, 0))
end
function zero(::T)::Vect where {T<:Union{Vect,Type{Vect}}}
    Vect()
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

# Dot product
function *(v1::Vect, v2::Vect)::Float64
    return sum(v1 .* v2)
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

function +(v::Vect, n::T)::Vect where {T<:IntOrFloat}
    result::Vect = v
    v + n * normalize(v)
    return result
end
function -(v::Vect, n::T)::Vect where {T<:IntOrFloat}
    v + (-n)
end

# https://math.stackexchange.com/questions/13261/how-to-get-a-reflection-vector
function reflect(norm::Vect, v::Vect)::Vect
    v - 2 * v * norm * norm / length(norm)^2
end

const Bounds = Tuple{NTuple{3,IntOrFloat},NTuple{3,IntOrFloat}}
function Bounds(
    xstart::IntOrFloat,
    xend::IntOrFloat,
    ystart::IntOrFloat,
    yend::IntOrFloat,
    zstart::IntOrFloat,
    zend::IntOrFloat,
)::Bounds
    return (
        (
            min(xstart, xend),
            min(ystart, yend),
            min(zstart, zend),
        ),
        (
            max(xstart, xend),
            max(ystart, yend),
            max(zstart, zend),
        ),
    )
end

function Bounds(p1::Vect, p2::Vect)::Bounds
    return (
        Vect(
            min(p1[1], p2[1]),
            min(p1[2], p2[2]),
            min(p1[3], p2[3]),
        ),
        Vect(
            max(p1[1], p2[1]),
            max(p1[2], p2[2]),
            max(p1[3], p2[3]),
        ),
    )
end

function inside(b::Bounds, v::Vect)::Bool
    for i in 1:3
        if v[i] < b[1][i] || v[i] > b[2][i]
            return false
        end
    end
    return true
end

function direction(a::Vect, b::Vect)::Vect
    return normalize(b .- a)
end

function rand(::Type{Vect}, r::AbstractRange{Float64})
    (rand(r), rand(r), rand(r))
end

let
    pcv1, pcv2 = Vect(1, 2, 3), Vect(2, 4, 8)

    _ = pcv1 + pcv2
    _ = pcv1 - pcv2
    _ = pcv1 + 1
    _ = pcv2 - 2
    _ = 2 * pcv2
    _ = pcv1 * pcv2
    _ = pcv1 / 3

    _ = length(pcv1)
    _ = distance(pcv1, pcv2)
    _ = normalize(pcv1)
    _ = reflect(pcv1, pcv2)

    _ = direction(pcv1, pcv2)
    _ = inside((pcv1, pcv2), Vect())
    _ = rand(Vect, -1:0.1:1)
end

end
