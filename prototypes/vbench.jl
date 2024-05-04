# Generalnie tuple są nieco szybsze + ciut fajniejsze w użyciu

include("vtuple.jl")
include("vstruct.jl")
import Base: rand
using BenchmarkTools
const testing_frange::StepRangeLen{Float64,Float64,Float64,Int} = -10000:0.1:10000

function randVec(size::Int, M::Module)
    v::Vector{M.Vect} = zeros(M.Vect, size)
    @simd for i in eachindex(v)
        v[i] = M.rand(M.Vect, testing_frange)
    end
    v
end

function opBench(
    v1::Vector{T},
    v2::Vector{T},
    M::Module,
) where {T}
    n1::Float64 = rand(testing_frange)
    n2::Int = rand(-10000:10000)
    @simd for i in eachindex(v1)
        _ = (M.:+)(v1[i], v2[i])
        _ = (M.:*)(v1[i], n1)
        _ = (M.:*)(v2[i], n2)
    end
    for i in eachindex(v1)
        _ = (M.:-)(v1[i], v2[i])
        _ = (M.:/)(v1[i], n1)
        _ = (M.:/)(v2[i], n2)
    end
end

function lenBench(v::Vector{T}, M::Module) where {T}
    for i in eachindex(v)
        _ = M.length(v[i])
    end
    @simd for i in eachindex(v)
        _ = M.length(v[i])
    end
end

function ndistBench(
    v1::Vector{T},
    v2::Vector{T},
    M::Module,
) where {T}
    @simd for i in eachindex(v1)
        _ = M.distance(v1[i], v2[i])
        _ = M.normalize(v1[i])
        _ = M.normalize(v2[i])
    end
end

let
    ps1 = randVec(4, Vstruct)
    ps2 = randVec(4, Vstruct)
    pt1 = randVec(4, Vtuple)
    pt2 = randVec(4, Vtuple)

    opBench(ps1, ps2, Vstruct)
    opBench(pt1, pt2, Vtuple)
    lenBench(ps1, Vstruct)
    lenBench(pt1, Vtuple)
    ndistBench(ps1, ps2, Vstruct)
    ndistBench(pt1, pt2, Vtuple)
end

const bsize = 4 * 10^5
const secs = 30

const stv1 = randVec(bsize, Vstruct)
const stv2 = randVec(bsize, Vstruct)
const tpv1 = randVec(bsize, Vtuple)
const tpv2 = randVec(bsize, Vtuple)

for i in 1:10
    println()
end

@benchmark _ = randVec(bsize, Vstruct) seconds = secs
@benchmark _ = randVec(bsize, Vtuple) seconds = secs
println()

@benchmark opBench(stv1, stv2, Vstruct) seconds = secs
@benchmark opBench(tpv1, tpv2, Vtuple) seconds = secs
println()

@benchmark lenBench(stv1, Vstruct) seconds = secs
@benchmark lenBench(tpv1, Vtuple) seconds = secs
println()

@benchmark ndistBench(stv1, stv2, Vstruct) seconds = secs
@benchmark ndistBench(tpv1, tpv2, Vtuple) seconds = secs
println()

