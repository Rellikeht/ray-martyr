using March, Meshes, Objects, Vectors
cam = Camera()

stars::Int = 12
radius::Float64 = 2.0

solids::Vector{Solid} = [
    Solid(
        Box(Vect(12, 0, 0), (0.0, 32.0, 18.0)),
        Material(
            RGBf(1.0),
            RGBf(0.0, 0.0, 1.0),
            RGBf(0.4)
        )
    ),
    (
        Solid(
            Sphere(Vect(6.0, radius * sin(i), radius * cos(i)), 0.2),
            Material(
                RGBf(1.0),
                RGBf(1.0, 1.0, 0.1),
                RGBf(0.05),
            )
        ) for i in 0:2π/stars:2π*(1-1/stars)
    )...
]

lights::Vector{LightSource} = [
    LightSource(Vect(2.0, 0, 0), RGBf(1.0, 1.0, 1.0)),
]

scene = Scene(
    cam,
    DEFAULT_WORLD_BOUNDS,
    lights,
    solids,
    RGBf(0.1)
)

mscene = begin
    mscene = initMscene(HD)
    @time render!(mscene, scene)
    mscene
end

begin
    revise()
    @time render!(mscene, scene)
    display(mscene)
end
