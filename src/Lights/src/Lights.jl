module Lights

using Objects, Vectors
import Base: max
import Base: *
import Base.Threads: @threads

export Ray, Frange
export march
export BLACK, DEFAULT_DISTANCE_LIMIT, DEFAULT_REFLECTION_LIMIT

const Frange = StepRangeLen{Float64,Float64,Float64,Int}

const DEFAULT_DISTANCE_LIMIT = 1e-2
const DEFAULT_REFLECTION_LIMIT = 3
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

function max(c1::RGBf, c2::RGBf)::RGBf
    RGBf(
        max(c1.r, c2.r),
        max(c1.g, c2.g),
        max(c1.b, c2.b),
    )
end

function scale(
    distance::Float64,
)
    # TODO
    1.0
end

function shadowRay(
    scene::Scene,
    position::Vect,
    normal::Vect,
    light::LightSource,
    distance_limit::Float64=DEFAULT_DISTANCE_LIMIT,
)::RGBf
    ray::Ray = Ray(position, direction(position, light.position))
    # values were essentially guessed, they look
    # reasonably well
    ray.position += 8 * distance_limit * ray.direction

    while inside(scene.bounds, ray.position)
        d::Float64 = min(
            sdf(scene, ray.position),
            sdf(light, ray.position)
        )
        if d < distance_limit / 2
            if d == sdf(light, ray.position)
                return light.intensity *
                       max(0, ray.direction * normal) *
                       scale(distance(position, ray.position))
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
            shadow_rays = sum(shadowRay.(
                (scene,),
                (ray.position,),
                (norm,),
                scene.lights,
                (distance_limit,),
            ))

            reflected_direction::Vect = reflect(norm, ray.direction)
            reflected = march(
                scene,
                Ray(
                    ray.position + distance_limit * reflected_direction,
                    reflected_direction
                );
                reflection_limit=reflection_limit - 1,
                distance_limit=distance_limit
            )

            return element.material.ambient * scene.ambient +
                   element.material.diffuse * shadow_rays +
                   element.material.specular * reflected
            # * (shadow_rays + reflected + scene.ambient)
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
    scene_sizes::Vect = Vect(
        0,
        scene.camera.plane_width / 2,
        scene.camera.plane_height / 2,
    )
    vmin::Vect = scene.camera.plane_center - scene_sizes
    vmax::Vect = scene.camera.plane_center + scene_sizes
    colors::Matrix{RGBf} = zeros(resolution[1], resolution[2])
    max_colors::Vector{RGBf} = zeros(resolution[2])

    @threads for i in 1:resolution[2]
        z = vmin[3] + (vmax[3] - vmin[3]) * (i - 1) / (resolution[2] - 1)
        for j in 1:resolution[1]
            y = vmin[2] + (vmax[2] - vmin[2]) * (j - 1) / (resolution[1] - 1)
            p::Vect = Vect(vmin[1], y, z)
            colors[j, i] = march(
                scene,
                Ray(p, direction(scene.camera.position, p));
                reflection_limit,
                distance_limit,
            )
            max_colors[i] = max(max_colors[i], colors[j, i])
        end
    end

    max_color::RGBf = max(max_colors...)
    max_val::Float64 = max(max_color.r, max_color.g, max_color.b)
    if max_val > 1
        colors ./= max_val
    end
    return colors
end

let
    psolid = [
        Solid(Sphere(Vect(1, 2, 3), 2.0)),
        Solid(Box(Vect(4, 5, 6), 3.0))
    ]

    pcam = Camera()
    pscene = Scene(
        pcam,
        DEFAULT_WORLD_BOUNDS,
        [LightSource(Vect(3, 2, 0))],
        psolid
    )

    _ = scale(1.0)
    _ = march(pscene, Ray((0, 0, 0), (1, 0, 0)); reflection_limit=1)
    _ = march(pscene, Ray((0, 0, 0), (1, 1, 0)); reflection_limit=2)
    _ = march(pscene, (20, 10); reflection_limit=3)
end

end
