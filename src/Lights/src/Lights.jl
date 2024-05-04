module Lights
using Objects, Vectors
import GLMakie: RGBAf

const Ray = Vect

function march(
    ray::Ray,
    # max_steps::Int
)::RGBAf
    color::RGBAf = RGBAf(0, 0, 0, 0)
    # TODO
    color
end
# _ = march(Ray(1,2,3), 2)
_ = march(Ray(1, 2, 3))

end
