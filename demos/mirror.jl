using March, Objects, Vectors
cam = Camera()

solids::Vector{Solid} = [
    Solid(
        Sphere(Vect(4.0, -2, -0.5), 0.5),
        Material(
            RGBf(0.5),
            RGBf(1.0),
            RGBf(0.08, 0.04, 0.0),
        )
    ),
    # floor
    Solid(
        Box(Vect(6, 0, -5), (5, 5, 0.5)),
        Material(1.0, 1.0, 0.1)
    ),
    # mirror
    Solid(
        Box(Vect(10, 0, 0), (0.0, 20, 10)),
        Material(1.8, 0.0, 1.0)
    ),
]

lights::Vector{LightSource} = [
    LightSource(Vect(1.5, 3, 1.5), RGBf(1.0, 1.0, 1.0)),
    LightSource(Vect(8, 4, 1), RGBf(0.0, 0.2, 0.6)),
]

scene::Scene = Scene(
    cam,
    DEFAULT_WORLD_BOUNDS,
    lights,
    solids,
    RGBf(0.1)
)

mscene = begin
    mscene = initMscene(FHD)
    @time render!(mscene, scene)
    mscene
end

begin
    revise()
    @time render!(mscene, scene)
    display(mscene)
end
