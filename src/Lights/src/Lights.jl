module Lights
using Objects, Vectors
export Color, Ray, Frange
export march
export BLACK, DEFAULT_DISTANCE_LIMIT, DEFAULT_REFLECTION_LIMIT

const Frange = StepRangeLen{Float64,Float64,Float64,Int}

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
    resolution::Tuple{Int,Int}=(640, 480),
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
)::Vector{Color}
    _, ymin, zmin = scene.camera.imagePlane.down_left
    _, ymax, zmax = scene.camera.imagePlane.top_right
    colors::Vector{Color} = zeros((resolution[1] + 1) * (resolution[2] + 1))

    for y in 0:resolution[1]
        for z in 0:resolution[2]
            p::Vect = Vect(
                scene.camera.imagePlane.top_right[1],
                ymin + y * (ymax - ymin) / resolution[1],
                zmin + z * (zmax - zmin) / resolution[2],
            )
            colors[1+y*resolution[2]+z] = march(
                scene,
                Ray(scene.camera.position, p),
                reflection_limit
            )
        end
    end

    return colors
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

    _ = march(pscene, Ray((0, 0, 0), (1, 0, 0)), 1)
    _ = march(pscene, (4, 3), 1)
end

end
