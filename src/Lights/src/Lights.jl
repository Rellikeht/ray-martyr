module Lights
using Objects, Vectors

# const Color = NTuple{3, Int} 

const Color = Float64
function Color()
    return 0.0
end

const DEFAULT_DISTANCE_LIMIT = 0.01
const DEFAULT_REFLECTION_LIMIT = 1
const BLACK = Color()

mutable struct Ray
    position::Vect
    direction::Vect
    # intensity::Float64
end

function march(
    scene::Scene,
    ray::Ray,
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
)::Color
    if reflection_limit < 0
        return BLACK
    end

    BOX_SIZE::Float64 = distance(
        scene.bounds[1],
        scene.bounds[2]
    )
    STARTING_POSITION::Vect = ray.position

    while !inside(scene.bounds, ray.position)
        d::Float64 = minDist(scene, ray.position)
        if d < DEFAULT_DISTANCE_LIMIT
            return Color(distance(STARTING_POSITION, ray.position) / BOX_SIZE)
        end
        ray.position += d
    end

    return BLACK
end

function march(
    scene::Scene,
    resolution::Tuple{Int, Int}=(640, 480)
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
)::Vector{Color}
end

let
    psolid = [
        Sphere(Vect(1, 2, 3), 2.0),
        Cube(Vect(4, 5, 6), 3.0)
    ]

    pcam = Camera()
    pscene = Scene(
        pcam,
        DEFAULT_WORLD_BOUNDS,
        [LightSource()],
        psolid
    )

    _ = march(pscene, Ray((0, 0, 0), (1, 0, 0)))
end

end
