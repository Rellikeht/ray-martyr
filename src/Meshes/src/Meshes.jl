module Meshes

# import-export {{{

using Vectors

export AbstractMesh, AbstractObject
export Sphere, Box
export sdf, closestElement, normal

#= }}}=#

# types and consts {{{

abstract type AbstractObject end
abstract type AbstractMesh <: AbstractObject end

const DEFAULT_EPS = 1e-6

#= }}}=#

# helpers {{{

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

#= }}}=#

# Sphere {{{

struct Sphere <: AbstractMesh
    position::Vect
    radius::Float64
    Sphere(position::Vect, radius::T=1.0) where
    {T<:Union{Int,Float64}} = new(position, Float64(radius))
end

function sdf(sphere::Sphere, vect::Vect)::Float64
    distance(sphere.position, vect) - sphere.radius
end

#= }}}=#

# Box {{{

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

#= }}}=#

# TODO cone and cyllinder
# TODO math formulas

# operations on collections {{{

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

#= }}}=#

# additional operations {{{

function normal(
    object::T,
    position::Vect,
    eps::Float64=DEFAULT_EPS,
)::Vect where {T<:AbstractObject}
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

#= }}}=#

let # precompilation {{{
    ppoint = Vect(4, 2, 0)

    pmesh = [
        Sphere(Vect(1, 2, 3), 2.0),
        Box(Vect(4, 5, 6), 3.0)
    ]

    for s in pmesh
        _ = sdf(s, ppoint)
    end

    _ = sdf(pmesh, ppoint)
    _ = closestElement(pmesh, ppoint)
    _ = normal(pmesh[1], ppoint)
end#= }}}=#

end # module Meshes
