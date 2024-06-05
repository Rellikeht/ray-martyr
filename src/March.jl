module March
using Lights
export FHD, HD
export initMscene, render!

using CairoMakie
CairoMakie.activate!()
import Lights: Scene, Camera
import Objects: Sphere, Box

const FHD = (1920, 1080)
const HD = (1280, 720)

# Scene from GLMakie refuses to work
# using GLMakie
# GLMakie.activate!()

function initMscene(
    size::Tuple{Int,Int}=FHD,
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
    scene::Scene,
    reflection_limit::Int=DEFAULT_REFLECTION_LIMIT,
)
    scx::Int, scy::Int = size(mscene)
    Makie.image!(mscene, march(scene, (scx, scy); reflection_limit))
end

# function main()::Scene
#     scene = initScene()
#     render!(scene)
#     return scene
# end

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
