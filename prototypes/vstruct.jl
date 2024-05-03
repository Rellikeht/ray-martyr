module Vstruct
import Base: zero, rand, +, -, *, /

struct Vect
    x::Float64
    y::Float64
    z::Float64
    Vect(coords::NTuple{3,T}=(0,0,0)) where {T<:Union{Int,Float64}} =
        new(Float64.(coords)...)
    Vect(x::T, y::T, z::T) where {T<:Union{Int,Float64}} =
        Vect((x,y,z))
end

function zero(::T)::Vect where {T<:Union{Vect, Type{Vect}}}
    Vect()
end

function rand(::Type{Vect}, r::AbstractRange{Float64})
    Vect(rand(r), rand(r), rand(r))
end

function +(v1::Vect, v2::Vect)::Vect
    Vect(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end

function -(v1::Vect, v2::Vect)::Vect
    Vect(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end
function -(v::Vect)
    Vect(-v.x, -v.y, -v.z)
end

function *(v::Vect, n::T)::Vect where {T<:Union{Float64,Int}}
    Vect(n * v.x, n * v.y, n * v.z)
end
function *(n::Union{Int,Float64}, v::Vect)::Vect
    v * n
end

function /(v::Vect, n::T)::Vect where {T<:Union{Float64,Int}}
    Vect(n / v.x, n / v.y, n / v.z)
end

function length(v::Vect)::Float64
    sqrt(v.x^2 + v.y^2 + v.z^2)
end

function distance(v1::Vect, v2::Vect)::Float64
    sqrt((v1.x - v2.x)^2 + (v1.y - v2.y)^2 + (v1.z - v2.z)^2)
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
