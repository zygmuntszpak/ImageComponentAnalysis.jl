using ImageComponentAnalysis
using Test, Images

@testset "ImageComponentAnalysis.jl" begin
    include("test_images.jl")
    include("contour_tracing.jl")
    include("moore_tracing.jl")
    include("outer_tracing.jl")
end
