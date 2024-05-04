module March
using Lights

using GLMakie
GLMakie.activate!()

function render(
    # size::Tuple{Int, Int},
    background::Union{String,Symbol}=:black
)::Scene
    scene::Scene = Scene(backgroundcolor=background)
    scx::Int, scy::Int = size(scene)
    campixel!(scene)

    image!(scene, [RGBf(i / scx, j / scy, 0) for i in 1:scx, j in 1:scy])

    return scene
end

end
