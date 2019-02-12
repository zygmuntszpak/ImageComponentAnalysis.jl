using ImageComponentAnalysis
using Test, Images

@testset "ImageComponentAnalysis.jl" begin
    include("test_images.jl")
    include("test_volumes.jl")
    include("contour_tracing.jl")
    include("one_component_2d.jl")
    include("one_component_3d.jl")
    # include("moore_tracing.jl")
    # include("outer_tracing.jl")
end
