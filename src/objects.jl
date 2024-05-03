module Objects

abstract type AbstractObject end
abstract type AbstractSolid<:AbstractObject end
abstract type AbstractLightSource<:AbstractObject end

function sdf(solid::AbstractSolid)::Float64
    throw(ErrorException("Not implemented for " * typeof(solid)))
end

struct Sphere<:AbstractSolid
    radius::Float64
end

end
