module Objects

# import-export {{{

import Meshes: sdf, closestElement
using Vectors, Meshes
import CairoMakie: RGBf
import Base: *

export AbstractLightSource
export LightSource, Camera, Scene, Solid
export Material, RGBf
export sdf, lightSdf
export closestElement, lightClosestElement
export DEFAULT_WORLD_BOUNDS, DEFAULT_EPS, DEFAULT_AMBIENT_LIGHT

export DEFAULT_AMBIENT_MATERIAL
export DEFAULT_SPECULAR_MATERIAL
export DEFAULT_DIFFUSE_MATERIAL
export DEFAULT_SHININESS

#= }}}=#

# consts and basic types {{{

const DEFAULT_WORLD_BOUNDS = Bounds(
    Vect(-2, 24, 24),
    Vect(24, -24, -24),
)
const DEFAULT_AMBIENT_LIGHT = RGBf(0.05, 0.05, 0.05)
const DEFAULT_AMBIENT_MATERIAL = RGBf(1.0)
const DEFAULT_SPECULAR_MATERIAL = RGBf(1.0)
const DEFAULT_DIFFUSE_MATERIAL = RGBf(1.0)
const DEFAULT_SHININESS = 1

abstract type AbstractLightSource <: AbstractObject end

#= }}}=#

struct Material#= {{{=#
    ambient::RGBf
    diffuse::RGBf
    specular::RGBf
    shininess::Float64

    Material(
        ambient::RGBf=DEFAULT_AMBIENT_MATERIAL,
        diffuse::RGBf=DEFAULT_DIFFUSE_MATERIAL,
        specular::RGBf=DEFAULT_SPECULAR_MATERIAL,
        shininess::IntOrFloat=DEFAULT_SHININESS,
    ) = begin
        if shininess < 0
            throw(ArgumentError("Invalid shininess value"))
        end
        for c in [ambient, diffuse, specular]
            if c.r < 0.0 || c.r > 1.0
                throw(ArgumentError("Invalid red value"))
            elseif c.g < 0.0 || c.g > 1.0
                throw(ArgumentError("Invalid green value"))
            elseif c.b < 0.0 || c.b > 1.0
                throw(ArgumentError("Invalid blue value"))
            end
        end
        new(ambient, diffuse, specular, shininess)
    end

    Material(
        ambient::Float64,
        diffuse::Float64,
        specular::Float64,
        shininess::IntOrFloat=DEFAULT_SHININESS,
    ) = new(RGBf(ambient), RGBf(diffuse), RGBf(specular), shininess)
end#= }}}=#

struct Solid <: AbstractObject #= {{{=#
    mesh::AbstractMesh
    material::Material
    Solid(
        mesh::AbstractMesh,
        material::Material=Material(),
    ) = new(mesh, material)
end#= }}}=#

# LightSource {{{

struct LightSource <: AbstractLightSource
    position::Vect
    intensity::RGBf

    LightSource(
        position::Vect=Vect(),
        intensity::RGBf=RGBf(1.0, 1.0, 1.0)
    ) = new(position, intensity)
end

LightSource(
    position::Vect,
    intensity::Float64
) = LightSource(
    position,
    RGBf(intensity, intensity, intensity)
)

#= }}}=#

struct Camera#= {{{=#
    position::Vect
    plane_center::Vect
    plane_width::Float64
    plane_height::Float64

    Camera(
        position::Vect=Vect(-1, 0, 0),
        plane_center::Vect=Vect(0, 0, 0),
        plane_width::Float64=3.2,
        plane_height::Float64=1.8,
    ) = new(position, plane_center, plane_width, plane_height)
end#= }}}=#

struct Scene <:AbstractObject#= {{{=#
    camera::Camera
    bounds::Bounds
    lights::Vector{AbstractLightSource}
    solids::Vector{Solid}
    ambient::RGBf
    Scene(
        camera::Camera=Camera(),
        bounds::Bounds=DEFAULT_WORLD_BOUNDS,
        lights::Vector{L}=[],
        solids::Vector{Solid}=[],
        ambient::RGBf=DEFAULT_AMBIENT_LIGHT,
    ) where {L<:AbstractLightSource} =
        new(camera, bounds, lights, solids, ambient)
end#= }}}=#

# distance and closest element functions {{{

function sdf(s::Solid, p::Vect)::Float64
    sdf(s.mesh, p)
end

function sdf(s::LightSource, p::Vect)::Float64
    distance(s.position, p)
end

function sdf(scene::Scene, pos::Vect)::Float64
    sdf(scene.solids, pos)
end

function closestElement(scene::Scene, pos::Vect)::Solid
    closestElement(scene.solids, pos)
end

function lightSdf(scene::Scene, pos::Vect)::Float64
    min(sdf(scene, pos), sdf(scene.lights, pos))
end

function lightClosestElement(scene::Scene, pos::Vect)::AbstractObject
    clight = closestElement(scene.lights, pos)
    csolid = closestElement(scene, pos)
    if sdf(clight, pos) < sdf(csolid, pos)
        return clight
    end
    csolid
end

#= }}}=#

let # precompilation {{{
    ppoint = Vect(4, 2, 0)
    psolid = [
        Solid(Sphere(Vect(1, 2, 3), 2.0)),
        Solid(Box(Vect(4, 5, 6), 3.0))
    ]

    plight = LightSource()
    _ = sdf(plight, ppoint)

    pcam = Camera()
    pscene = Scene(
        pcam,
        DEFAULT_WORLD_BOUNDS,
        [plight, LightSource(Vect(1, 2, 3))],
        psolid
    )

    _ = normal(pscene, ppoint)
    _ = sdf(pscene, ppoint)
    _ = sdf(pscene.lights, ppoint)
    _ = closestElement(pscene, ppoint)
    _ = closestElement(pscene.lights, ppoint)
    _ = lightClosestElement(pscene, ppoint)
end#= }}}=#

end
