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
    Sphere(position::Vect, radius::Float64=1.0) = new(position, radius)
end

function sdf(sphere::Sphere, vect::Vect)::Float64
    distance(sphere.position, vect)
end

struct Cube <: AbstractSolid
    # position::Vect
    # side::Float64
    verts::NTuple{8,Vect}
    # Cube(
    #     position::Vect,
    #     side::Float64=1.0
    # ) = begin
    #     c = new()
    #     # c.side[1] = 
    #     c
    # end
end

function sdf(cube::Cube, vect::Vect)::Float64
    d::Float64 = 0
    @simd for i in eachindex(cube.verts)
        d = min(d, distance(cube.verts[i], vect))
    end
    return d
end

end
