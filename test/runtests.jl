using ImageComponentAnalysis
using Test, Images

@testset "ImageComponentAnalysis.jl" begin
    include("test_volumes.jl")
    include("test_images.jl")
    include("one_component_2d.jl")
    include("one_component_3d.jl")
    include("contour_tracing.jl")
    include("moore_tracing.jl")
    include("outer_tracing.jl")
end
