module Lights

using Objects, Vectors
import CairoMakie: RGBf
import Base: *
import Base.Threads: @threads

export Ray, Frange
export march
export BLACK, DEFAULT_DISTANCE_LIMIT, DEFAULT_REFLECTION_LIMIT

const Frange = StepRangeLen{Float64,Float64,Float64,Int}

const DEFAULT_DISTANCE_LIMIT = 0.001
const DEFAULT_REFLECTION_LIMIT = 1
const BLACK = RGBf(0.0, 0.0, 0.0)

mutable struct Ray
    position::Vect
    direction::Vect
end

function *(c1::RGBf, c2::RGBf)::RGBf
    RGBf(
        c1.r * c2.r,
        c1.g * c2.g,
        c1.b * c2.b,
    )
end

function scaleDistance(
    distance::Float64,
)
    # TODO
end

function shadowRay(
    scene::Scene,
    position::Vect,
    normal::Vect,
    light::LightSource,
    distance_limit::Float64=DEFAULT_DISTANCE_LIMIT,
)::RGBf
    ray::Ray = Ray(position, direction(position, light.position))
    # FUCK
    ray.position += 5 * distance_limit * ray.direction

    # Works
    # return light.intensity * max(0, ray.direction * normal)
    # so problem is below

    while inside(scene.bounds, ray.position)
        d::Float64 = min(
            sdf(scene, ray.position),
            sdf(light, ray.position)
        )
        if d < distance_limit
            if d == sdf(light, ray.position)
                # TODO distance scaling
                return light.intensity * max(0, ray.direction * normal)
            else
                return BLACK
            end
        end
        ray.position += d * ray.direction
    end

    return BLACK
end

function march(
    scene::Scene,
    ray::Ray;
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
    distance_limit::Float64=DEFAULT_DISTANCE_LIMIT,
)::RGBf
    if reflection_limit < 0
        return BLACK
    end

    while inside(scene.bounds, ray.position)
        d::Float64 = sdf(scene, ray.position)
        if d < distance_limit
            norm = normal(scene, ray.position)
            element = closestElement(scene, ray.position)
            # TODO for all lights
            shadow_rays = shadowRay(
                scene,
                ray.position,
                norm,
                scene.lights[1],
                distance_limit
            )

            # reflected = march(
            #     scene,
            #     Ray(
            #         ray.position,
            #         reflect(norm, ray.direction)
            #     );
            #     reflection_limit=reflection_limit - 1,
            #     distance_limit=distance_limit
            # ) # * color

            # return RGBf(0.5 + norm[1] / 2, 0.5 + norm[2] / 2, 0.5 + norm[3] / 2)
            return element.material * shadow_rays
            # TODO what is formula
            # return reflected / 2 + shadow_ray_color / 2
        end
        ray.position += d * ray.direction
    end

    return BLACK
end

function march(
    scene::Scene,
    resolution::Tuple{Int,Int}=(640, 480);
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
    distance_limit::Float64=DEFAULT_DISTANCE_LIMIT,
)::Matrix{RGBf}
    x, ymin, zmin = scene.camera.imagePlane.down_left
    _, ymax, zmax = scene.camera.imagePlane.top_right
    colors::Matrix{RGBf} = zeros(resolution[1], resolution[2])

    # TODO threads
    i::Int = 0
    for z in Frange(zmin:(zmax-zmin)/(resolution[2]-1):zmax)
        j::Int = 1
        for y in Frange(ymin:(ymax-ymin)/(resolution[1]-1):ymax)
            p::Vect = Vect(x, y, z)
            colors[i*resolution[1]+j] = march(
                scene,
                Ray(p, direction(scene.camera.position, p));
                reflection_limit,
                distance_limit,
            )
            j += 1
        end
        i += 1
    end

    return colors
end

let
    psolid = [
        Solid(Sphere(Vect(1, 2, 3), 2.0)),
        Solid(Cube(Vect(4, 5, 6), 3.0))
    ]

    pcam = Camera()
    pscene = Scene(
        pcam,
        DEFAULT_WORLD_BOUNDS,
        [LightSource(Vect(3, 2, 0))],
        psolid
    )

    _ = march(pscene, Ray((0, 0, 0), (1, 0, 0)); reflection_limit=1)
    _ = march(pscene, Ray((0, 0, 0), (1, 1, 0)); reflection_limit=2)
    _ = march(pscene, (20, 10); reflection_limit=3)
end

end
