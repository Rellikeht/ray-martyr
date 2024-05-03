module Vectors
export AbstractVect, Vect, MutVect
export length, normalize, distance, +, -

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

function distance(
    v1::Union{Vect,MutVect},
    v2::Union{Vect,MutVect}
)::Float64
    return sqrt((v1.x - v2.x)^2 + (v1.y - v2.y)^2 + (v1.z - v2.z)^2)
end

function +(v1::Vect, v2::Union{Vect,MutVect})::Vect
    return Vect(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
end
function +(v1::MutVect, v2::Union{Vect,MutVect})
    v1.x += v2.x
    v1.y += v2.y
    v1.z += v2.z
end

function -(v1::Vect, v2::Union{Vect,MutVect})::Vect
    return Vect(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

function -(v1::MutVect, v2::Union{Vect,MutVect})
    v1.x -= v2.x
    v1.y -= v2.y
    v1.z -= v2.z
end

end

module Objects
include("vectors.jl")
using .Vectors

export AbstractObject, AbstractSolid, AbstractLightSource
export Sphere, Cube, sdf

abstract type AbstractObject end
abstract type AbstractSolid <: AbstractObject end
abstract type AbstractLightSource <: AbstractObject end

struct Sphere <: AbstractSolid
    position::Vect
    radius::Float64
end

function sdf(sphere::Sphere, vect::Union{Vect, MutVect})::Float64
    distance(sphere.position, vect)
end

struct Cube <: AbstractSolid
    position::Vect
    side::Float64
end

function sdf(sphere::Sphere, vect::Union{Vect, MutVect})::Float64
    distance(sphere.position, vect)
end

end
