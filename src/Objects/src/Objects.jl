module Objects
using Vectors: IntOrFloat
using Vectors

export AbstractObject, AbstractSolid, AbstractLightSource
export Sphere, Cube, sdf, minDist, closestElement
export LightSource, Camera, Scene

abstract type AbstractObject end
abstract type AbstractSolid <: AbstractObject end
abstract type AbstractLightSource <: AbstractObject end

struct Sphere <: AbstractSolid
    position::Vect
    radius::Float64
    Sphere(position::Vect, radius::T=1.0) where
    {T<:Union{Int,Float64}} = new(position, Float64(radius))
end

function sdf(sphere::Sphere, vect::Vect)::Float64
    distance(sphere.position, vect)
end

const cube_default = (x -> x ./ 2).((
    (1.0, 1.0, 1.0),
    (-1.0, 1.0, 1.0),
    (1.0, -1.0, 1.0),
    (1.0, 1.0, -1.0),
    (-1.0, -1.0, 1.0),
    (-1.0, 1.0, -1.0),
    (1.0, -1.0, -1.0),
    (-1.0, -1.0, -1.0),
))

struct Cube <: AbstractSolid
    verts::NTuple{8,Vect}
    Cube(verts::NTuple{8,Vect}=cube_default) = new(verts)
    Cube(
        position::Vect,
        side::Float64=1.0
    ) = begin
        mult = (x -> x .* side).(cube_default)
        new(Tuple(mult[i] + position for i in eachindex(mult)))
    end
end

function sdf(cube::Cube, vect::Vect)::Float64
    # d::Float64 = 0
    # @simd for i in eachindex(cube.verts)
    #     d = min(d, distance(cube.verts[i], vect))
    # end
    # return d
    reduce(min, distance.(cube.verts, (vect,)))
end

struct LightSource <: AbstractLightSource
    position::Vect
    intensity::Float64
    LightSource(
        position::Vect=Vect(),
        intensity::Float64=0.0
    ) = new(position, intensity)
end

struct Camera
    position::Vect
    Camera(position::Vect=Vect(-1, 0, 0)) = new(position)
end

const Bounds = Tuple{NTuple{3,IntOrFloat},NTuple{3,IntOrFloat}}
const DEFAULT_WORLD_BOUNDS = (
    Vect(0, 1000, 1000),
    Vect(2000, -1000, -1000)
)

struct Scene
    camera::Camera
    bounds::Bounds
    lights::Vector{AbstractLightSource}
    solids::Vector{AbstractSolid}
    Scene(
        camera::Camera=Camera(),
        bounds::Bounds=DEFAULT_WORLD_BOUNDS,
        lights::Vector{L}=[],
        solids::Vector{S}=[],
    ) where {L<:AbstractLightSource,S<:AbstractSolid} =
        new(camera, bounds, lights, solids)
end

function minDist(scene::Scene, pos::Vect)::Float64
    reduce(min, sdf.(scene.solids, (pos,)))
end

function closestElement(scene::Scene, pos::Vect)::AbstractSolid
    scene.solids[argmin(sdf.(scene.solids, (pos,)))]
end

let
    ppoint = Vect(4, 2, 0)
    psolid = [
        Sphere(Vect(1, 2, 3), 2.0)
        Cube(Vect(4, 5, 6), 3.0)
    ]

    for s in psolid
        _ = sdf(s, ppoint)
    end

    pcam = Camera()
    pscene = Scene(pcam, DEFAULT_WORLD_BOUNDS, [LightSource()], psolid)
    _ = minDist(pscene, ppoint)
    _ = closestElement(pscene, ppoint)
end

end
