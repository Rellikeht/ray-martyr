module Lights
using Objects, Vectors

const IntOrFloat = Union{Int,Float64}
const Color = Float64
function Color(value::T=0) where {T<:IntOrFloat}
    return Float64(value)
end

# const Color = NTuple{3, Int} 

const DEFAULT_DISTANCE_LIMIT = 0.001
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

    BOX_SIZE::Float64 = distance(
        scene.bounds[1],
        scene.bounds[2]
    )
    STARTING_POSITION::Vect = ray.position

    while !inside(scene.bounds..., ray.position)
        d::Float64 = minDist(scene, ray.position)
        if d < DEFAULT_DISTANCE_LIMIT
            return distance(STARTING_POSITION, ray.position) / BOX_SIZE
        end
        ray.position += d
    end

    # hardcode maximum box size and go on
    # TODO do this well another time
    # march
    # if outside box
    # return black
    # if reflection
    # march(limit-1) to all light sources

    return 0.0
end

end
