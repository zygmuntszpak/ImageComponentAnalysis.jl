using ImageComponentAnalysis
using Test, Images, JuliaDBMeta, IndexedTables, JuliaDBMeta

@testset "ImageComponentAnalysis.jl" begin
    include("test_images.jl")
    include("test_volumes.jl")
    include("contour_tracing.jl")
    include("measurement.jl")
    include("one_component_2d.jl")
    include("one_component_3d.jl")
    include("basic_topology.jl")
    include("region_ellipse.jl")
end
