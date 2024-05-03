module Vectors
export AbstractVect, Vect, MutVect
export length, normalize

abstract type AbstractVect end

struct Vect <: AbstractVect
    x::Float64
    y::Float64
    z::Float64
    Vect(
        x::Float64=0.0,
        y::Float64=0.0,
        z::Float64=0.0
    ) = new(x, y, z)
end

mutable struct MutVect <: AbstractVect
    x::Float64
    y::Float64
    z::Float64
    Vect(
        x::Float64=0.0,
        y::Float64=0.0,
        z::Float64=0.0
    ) = new(x, y, z)
end

function length(v::Union{Vect,MutVect})::Float64
    sqrt(v.x^2 + v.y^2 + v.z^2)
end

function normalize(v::Vect)::Vect
    l::Float64 = length(v)
    return Vect(v.x / l, v.y / l, v.z / l)
end

function normalize(v::MutVect)
    l::Float64 = length(v)
    v.x /= l
    v.y /= l
    v.z /= l
end

end
