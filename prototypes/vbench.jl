# Generalnie tuple są nieco szybsze + ciut fajniejsze w użyciu

include("vtuple.jl")
include("vstruct.jl")
import Base: rand
using BenchmarkTools

# function rand(::Vtype, n::Int)::Vector{Vtype}
#     T::Type = Base.return_types(rand, (Vtype, Int))
#     result::T = zeros(T, n)
#     @simd for i in eachindex(result)
#         result[i] = rand(Vtype)
#     end
#     return return
# end

const testing_frange::StepRangeLen{Float64,Float64,Float64,Int} = -10000:0.1:10000

function opBench(size::Int, M::Module)
    v1::Vector{M.Vect} = zeros(M.Vect, size)
    v2::Vector{M.Vect} = zeros(M.Vect, size)
    n1::Float64 = rand(testing_frange)
    n2::Int = rand(-10000:10000)

    @simd for i in eachindex(v1)
        v1[i] = M.rand(M.Vect, testing_frange)
        v2[i] = M.rand(M.Vect, testing_frange)
    end

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

opBench(4, Vtuple)
opBench(4, Vstruct)

function lenBench(size::Int, M::Module)
    v1::Vector{M.Vect} = zeros(M.Vect, size)

    @simd for i in eachindex(v1)
        v1[i] = M.rand(M.Vect, testing_frange)
    end

    for i in eachindex(v1)
        _ = M.length(v1[i])
    end

    @simd for i in eachindex(v1)
        _ = M.length(v1[i])
    end
end

lenBench(4, Vtuple)
lenBench(4, Vstruct)

function ndistBench(size::Int, M::Module)
    v1::Vector{M.Vect} = zeros(M.Vect, size)
    v2::Vector{M.Vect} = zeros(M.Vect, size)

    @simd for i in eachindex(v1)
        v1[i] = M.rand(M.Vect, testing_frange)
        v2[i] = M.rand(M.Vect, testing_frange)
    end

    @simd for i in eachindex(v1)
        _ = M.distance(v1[i], v2[i])
        _ = M.normalize(v1[i])
        _ = M.normalize(v2[i])
    end
end

ndistBench(4, Vtuple)
ndistBench(4, Vstruct)

const bsize = 4*10^5
@benchmark opBench(bsize, Vtuple) seconds=30
@benchmark opBench(bsize, Vstruct) seconds=30
println()
@benchmark ndistBench(bsize, Vtuple) seconds=30
@benchmark ndistBench(bsize, Vstruct) seconds=30
println()
@benchmark lenBench(bsize, Vtuple) seconds=30
@benchmark lenBench(bsize, Vstruct) seconds=30
