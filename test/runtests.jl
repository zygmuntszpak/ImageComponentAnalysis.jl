using ImageComponentAnalysis
using Test, Images

@testset "ImageComponentAnalysis.jl" begin
    include("test_volumes.jl")
    include("one_component_3d.jl")
end
