module Lights

using Objects, Vectors
import CairoMakie: RGBf

export Ray, Frange
export march
export BLACK, DEFAULT_DISTANCE_LIMIT, DEFAULT_REFLECTION_LIMIT

const Frange = StepRangeLen{Float64,Float64,Float64,Int}

const DEFAULT_DISTANCE_LIMIT = 0.01
const DEFAULT_REFLECTION_LIMIT = 1
const BLACK = RGBf(0.0, 0.0, 0.0)

mutable struct Ray
    position::Vect
    direction::Vect
    # intensity::Float64
end

function march(
    scene::Scene,
    ray::Ray,
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
)::RGBf
    if reflection_limit < 0
        return BLACK
    end

    BOX_SIZE::Float64 = distance(
        scene.bounds[1],
        scene.bounds[2]
    )
    STARTING_POSITION::Vect = ray.position

    while inside(scene.bounds, ray.position)
        d::Float64 = minDist(scene, ray.position)
        if d < DEFAULT_DISTANCE_LIMIT
            return RGBf(distance(STARTING_POSITION, ray.position) / BOX_SIZE * 2)
        end
        ray.position += d * ray.direction
    end

    return BLACK
end

function march(
    scene::Scene,
    resolution::Tuple{Int,Int}=(640, 480),
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
)::Matrix{RGBf}
    _, ymin, zmin = scene.camera.imagePlane.down_left
    _, ymax, zmax = scene.camera.imagePlane.top_right
    colors::Matrix{RGBf} = zeros(resolution[1], resolution[2])
    i::Int = 1

    for z in Frange(zmin:(zmax-zmin)/(resolution[2]-1):zmax)
        for y in Frange(ymin:(ymax-ymin)/(resolution[1]-1):ymax)
            p::Vect = Vect(scene.camera.imagePlane.top_right[1], y, z)
            colors[i] = march(
                scene,
                Ray(
                    scene.camera.position,
                    direction(scene.camera.position, p),
                ),
                reflection_limit
            )
            i += 1
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
