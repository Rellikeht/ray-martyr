module March
using Lights
export FHD, HD, QHD, K4
export initMscene, render!

using CairoMakie
CairoMakie.activate!()
import Lights: Scene, Camera
import Objects: Sphere, Box

const K4 = (3840, 2160)
const QHD = (2560, 1440)
const FHD = (1920, 1080)
const HD = (1280, 720)
const SD = (640, 480)

# Scene from GLMakie refuses to work
# using GLMakie
# GLMakie.activate!()

function initMscene(
    size::Tuple{Int,Int}=SD,
    background::Union{String,Symbol}=:black
)::Makie.Scene
    scene::Makie.Scene = Makie.Scene(
        clear=true,
        backgroundcolor=background,
        size=size,
    )
    # Makie.update_limits!(scene)
    # scale!(scene, 1)
    Makie.campixel!(scene)
    return scene
end

function render!(
    mscene::Makie.Scene,
    scene::Scene;
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
    distance_limit::Float64=DEFAULT_DISTANCE_LIMIT,
)
    scx::Int, scy::Int = size(mscene)
    Makie.image!(
        mscene,
        march(
            scene,
            (scx, scy);
            distance_limit=distance_limit,
            reflection_limit=reflection_limit
        )
    )
end

let
    using Objects, Vectors
    precs = initMscene((20, 10))

    psolid = [
        Solid(Sphere(Vect(1, 2, 3), 2.0)),
        Solid(Box(Vect(4, 5, 6), 3.0))
    ]

    pcam = Camera()
    pscene = Scene(
        pcam,
        DEFAULT_WORLD_BOUNDS,
        [LightSource(Vect(2, 3, 0), RGBf(1.0, 1.0, 1.0))],
        psolid
    )

    render!(precs, pscene)
end

end
