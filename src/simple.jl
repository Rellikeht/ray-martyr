using March, Objects, Vectors
import CairoMakie: RGBf
cam = Camera()

solids = [
    Solid(Sphere(Vect(2.5, 1, -1), 1.5), Material(0.1, 1.0, 0.7)),
    Solid(Cube(Vect(2, -2, 4.5), 2.0), Material(0.0, 0.6, 1.0)),
]
scene = Scene(
    cam,
    DEFAULT_WORLD_BOUNDS,
    [LightSource(Vect(1, 4, 0), RGBf(1.0, 1.0, 1.0))],
    solids
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
