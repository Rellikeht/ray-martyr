# using GLMakie
# GLMakie.activate!()

module March
using Lights

const FHD = (1920, 1080)
const HD = (1280, 720)

using CairoMakie
CairoMakie.activate!()

# GLMakie.activate!(float=true,)
# GLMakie.activate!(fullscreen=true)

# using GLMakie
# GLMakie.activate!()

# scene::Scene = Scene(
#     # back,
#     clear=true,
#     # backgroundcolor=background,
#     backgroundcolor=:black,
#     # size=HD,
# )
# campixel!(scene)

# function render(scene::Scene)
#     scx::Int, scy::Int = size(scene)
#     image!(scene, [(i+j)/(scx+scy) for i in 1:scx, j in 1:scy])
#     return scene
# end

# function render()::Scene
#     campixel!(scene)
#     scx::Int, scy::Int = size(scene)
#     image!(scene, [(i+j)/(scx+scy) for i in 1:scx, j in 1:scy])
#     return scene
# end

# function initScene(
#     # size::Tuple{Int, Int},
#     background::Union{String,Symbol}=:black
# )::Scene

#     scene::Scene = Scene(
#         # back,
#         clear=true,
#         # backgroundcolor=background,
#         backgroundcolor=:black,
#         # size=HD,
#         # fulllscreen=true
#     )

#     # Makie.update_limits!(scene)
#     # scale!(scene, 1)
#     campixel!(scene)
#     return scene
# end

# function render!(
#     scene::Scene
# )
#     scx::Int, scy::Int = size(scene)
#     println(scx)
#     println(scy)

#     # image!(scene, [RGBf(i / scx, j / scy, 0) for i in 1:scx, j in 1:scy])
#     image!(scene, [(i+j)/(scx+scy) for i in 1:scx, j in 1:scy])
#     # image!(scene, [RGBf(255, 0, 0) for i in 1:scx, j in 1:scy])
# end

# function main()::Scene
#     scene = initScene()
#     render!(scene)
#     return scene
# end

end
