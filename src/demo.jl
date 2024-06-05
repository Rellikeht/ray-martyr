using March, Objects, Vectors
import CairoMakie: RGBf
mscene = initMscene(HD)
cam = Camera()

solids = [
    Solid(Sphere(Vect(2.5, 1, -1), 1.5), Material(0.1, 1.0, 0.7)),
    Solid(Cube(Vect(2, -2, 4.5), 2.0), Material(0.0, 0.6, 1.0)),
]
scene = Scene(
    cam,
    DEFAULT_WORLD_BOUNDS,
    # [LightSource(Vect(1.5, 3, -1), RGBf(1.0, 1.0, 1.0))],
    [LightSource(Vect(1, 3, 0), RGBf(1.0, 1.0, 1.0))],
    solids
)

render!(mscene, scene)
display(mscene)
