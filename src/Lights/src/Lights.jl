module Lights
using Objects, Vectors

const IntOrFloat = Union{Int,Float64}
const Color = Float64
function Color(value::T=0) where {T<:IntOrFloat}
    return Float64(value)
end

# const Color = NTuple{3, Int} 

const DEFAULT_REFLECTION_LIMIT = 1
const BLACK = Color()

mutable struct Ray
    position::Vect
    direction::Vect
    intensity::Float64
end

function march(
    scene::Scene,
    ray::Ray,
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT
)::Float64
    if reflection_limit < 0
        return BLACK
    end

    while !inside(scene.bounds..., ray.position)
    end

    # hardcode maximum box size and go on
    # TODO do this well another time
    # march
    # if outside box
    # return black
    # if reflection
    # march(limit-1) to all light sources
end

end
