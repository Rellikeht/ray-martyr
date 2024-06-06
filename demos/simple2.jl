using March, Objects, Vectors
cam = Camera()

solids = [
    Solid(
        Sphere(Vect(4.5, 1, 1.5), 2.0),
        Material(
            RGBf(1.0),
            RGBf(1.0),
            RGBf(0.1, 1.0, 0.7),
        )
    ),
    Solid(Box(Vect(8, 0, -6), (30, 30, 0.5)), Material(1.0, 1.0, 1.0)),
]
lights = [
    LightSource(Vect(1.5, 3, 1.5), RGBf(1.0, 0.7, 1.0)),
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
