module Objects

using Vectors
import CairoMakie: RGBf
import Base: *

export AbstractObject, AbstractMesh, AbstractLightSource
export Sphere, Box
export LightSource, Camera, Scene, Solid
export Material, RGBf
export normal
export sdf, lightSdf
export closestElement, lightClosestElement
export DEFAULT_WORLD_BOUNDS, DEFAULT_EPS, DEFAULT_AMBIENT

const DEFAULT_WORLD_BOUNDS = Bounds(
    Vect(-2, 24, 24),
    Vect(24, -24, -24),
)
const DEFAULT_EPS = 1e-6
const DEFAULT_AMBIENT = RGBf(0.05, 0.05, 0.05)

abstract type AbstractObject end
abstract type AbstractMesh <: AbstractObject end
abstract type AbstractLightSource <: AbstractObject end

struct Sphere <: AbstractMesh
    position::Vect
    radius::Float64
    Sphere(position::Vect, radius::T=1.0) where
    {T<:Union{Int,Float64}} = new(position, Float64(radius))
end

function sdf(sphere::Sphere, vect::Vect)::Float64
    distance(sphere.position, vect) - sphere.radius
end

struct Box <: AbstractMesh
    center::Vect
    sizes::NTuple{3,Float64}

    Box(
        center::Vect=Vect,
        sizes::Tuple{T1,T2,T3}=(1, 1, 1)
    ) where {
        T1<:IntOrFloat,
        T2<:IntOrFloat,
        T3<:IntOrFloat,
    } = new(center, sizes)

    Box(
        position::Vect,
        side::IntOrFloat
    ) = new(position, (side, side, side))
end

function distBetween(
    ab::Tuple{Float64,Float64},
    p::Float64,
)::Float64
    va = ab[1] - p
    vb = p - ab[2]
    if abs(va) > abs(vb)
        return vb
    end
    return va
end

function inside(b::Box, v::Vect)::Bool
    @simd for i in 1:3
        if v[i] < b.center[i] - b.sizes[i] / 2 ||
           v[i] > b.center[i] + b.sizes[i] / 2
            return false
        end
    end
    return true
end

function sdf(box::Box, vect::Vect)::Float64
    verts::NTuple{3,NTuple{2,Float64}} = (
        (x, s) -> (x - s / 2, x + s / 2)
    ).(box.center, box.sizes)

    if inside(box, vect)
        return -sqrt(sum((distBetween.(verts, vect)) .^ 2))
    end
    return sqrt(sum(max.(distBetween.(verts, vect), 0) .^ 2))
end

# TODO cone and cyllinder

struct Material
    red::Float64
    green::Float64
    blue::Float64

    Material(
        red::Float64=0.5,
        green::Float64=0.5,
        blue::Float64=0.5,
    ) = begin
        if red < 0.0 || red > 1.0
            throw(ArgumentError("Invalid red value"))
        elseif green < 0.0 || green > 1.0
            throw(ArgumentError("Invalid green value"))
        elseif blue < 0.0 || blue > 1.0
            throw(ArgumentError("Invalid blue value"))
        end
        new(red, green, blue)
    end
end

function *(m::Material, c::RGBf)::RGBf
    RGBf(c.r * m.red, c.g * m.green, c.b * m.blue)
end

function *(c::RGBf, m::Material)::RGBf
    m * c
end

struct Solid <: AbstractObject
    mesh::AbstractMesh
    material::Material
    Solid(
        mesh::AbstractMesh,
        material::Material=Material(),
    ) = new(mesh, material)
end

function sdf(s::Solid, p::Vect)::Float64
    sdf(s.mesh, p)
end

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

function sdf(s::LightSource, p::Vect)::Float64
    distance(s.position, p)
end

struct Camera
    position::Vect
    imagePlane::Plane
    Camera(
        position::Vect=Vect(-1, 0, 0),
        plane::Plane=Plane(
            Vect(0.0, -1.6, -0.9),
            Vect(0.0, 1.6, 0.9),
        ),
    ) = new(position, plane)
end

struct Scene
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
        ambient::RGBf=DEFAULT_AMBIENT,
    ) where {L<:AbstractLightSource} =
        new(camera, bounds, lights, solids, ambient)
end

function sdf(
    objects::Vector{T},
    pos::Vect
)::Float64 where {T<:AbstractObject}
    reduce(min, sdf.(objects, (pos,)))
end

function closestElement(
    objects::Vector{T},
    pos::Vect
)::T where {T<:AbstractObject}
    objects[argmin(sdf.(objects, (pos,)))]
end

function closestElement(scene::Scene, pos::Vect)::Solid
    closestElement(scene.solids, pos)
end

function sdf(scene::Scene, pos::Vect)::Float64
    sdf(scene.solids, pos)
end

function lightSdf(scene, pos::Vect)::Float64
    min(sdf(scene, pos), sdf(scene.lights, pos))
end

function closestLight(scene::Scene, pos::Vect)::LightSource
    scene.lights[argmin(sdf.(scene.lights, (pos,)))]
end

function lightClosestElement(scene::Scene, pos::Vect)::AbstractObject
    clight = closestLight(scene, pos)
    csolid = closestElement(scene, pos)
    if sdf(clight, pos) < sdf(csolid, pos)
        return clight
    end
    csolid
end

function normal(
    object::AbstractObject,
    position::Vect,
    eps::Float64=DEFAULT_EPS,
)::Vect
    normalize(
        Vect(
            sdf(object, position + Vect(eps, 0.0, 0.0)) -
            sdf(object, position - Vect(eps, 0.0, 0.0)),
            sdf(object, position + Vect(0.0, eps, 0.0)) -
            sdf(object, position - Vect(0.0, eps, 0.0)),
            sdf(object, position + Vect(0.0, 0.0, eps)) -
            sdf(object, position - Vect(0.0, 0.0, eps)),
        )
    )
end

function normal(
    scene::Scene,
    position::Vect,
    eps::Float64=DEFAULT_EPS,
)::Vect
    normalize(
        Vect(
            sdf(scene, position + Vect(eps, 0.0, 0.0)) -
            sdf(scene, position - Vect(eps, 0.0, 0.0)),
            sdf(scene, position + Vect(0.0, eps, 0.0)) -
            sdf(scene, position - Vect(0.0, eps, 0.0)),
            sdf(scene, position + Vect(0.0, 0.0, eps)) -
            sdf(scene, position - Vect(0.0, 0.0, eps)),
        )
    )
end

let
    ppoint = Vect(4, 2, 0)
    psolid = [
        Solid(Sphere(Vect(1, 2, 3), 2.0)),
        Solid(Box(Vect(4, 5, 6), 3.0))
    ]

    for s in psolid
        _ = sdf(s, ppoint)
    end
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
    _ = closestLight(pscene, ppoint)
    _ = lightClosestElement(pscene, ppoint)
end

end
