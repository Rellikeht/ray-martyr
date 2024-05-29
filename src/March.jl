module March
using Lights

using GLMakie
GLMakie.activate!(fullscreen=true)

function render(
    # size::Tuple{Int, Int},
    background::Union{String,Symbol}=:black
)::Scene
    scene::Scene = Scene(
        backgroundcolor=background,
        fulllscreen=true
    )

    campixel!(scene)
    scx::Int, scy::Int = size(scene)
    println(scx)
    println(scy)

    # image!(scene, [RGBf(i / scx, j / scy, 0) for i in 1:scx, j in 1:scy])
    return scene
end

end
