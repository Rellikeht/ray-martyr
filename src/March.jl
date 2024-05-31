# using GLMakie
# GLMakie.activate!()

module March
using Lights

const FHD = (1920, 1080)
const HD = (1280, 720)

using CairoMakie
CairoMakie.activate!()

# Scene from GLMakie refuses to work
# using GLMakie
# GLMakie.activate!()

function initScene(
    size::Tuple{Int,Int}=FHD,
    background::Union{String,Symbol}=:black
)::Scene
    scene::Scene = Scene(
        clear=true,
        backgroundcolor=background,
        size=size,
    )
    # Makie.update_limits!(scene)
    # scale!(scene, 1)
    campixel!(scene)
    return scene
end

function render!(
    scene::Scene
)
    scx::Int, scy::Int = size(scene)
    println(scx)
    println(scy)
    image!(scene, [RGBf(i / scx, j / scy, 0) for i in 1:scx, j in 1:scy])
    # image!(scene, [(i+j)/(scx+scy) for i in 1:scx, j in 1:scy])
end

# function main()::Scene
#     scene = initScene()
#     render!(scene)
#     return scene
# end

let
    precs = initScene((2, 2))
    render!(precs)
end

end
