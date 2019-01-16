using ImageComponentAnalysis
using Test, Images

@testset "ImageComponentAnalysis.jl" begin
    include("test_images.jl")
    include("one_component_2d.jl")
end
