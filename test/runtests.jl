using ImageComponentAnalysis
using Test, Images, JuliaDBMeta, IndexedTables

function compare(expected_result, test, N)
    for n in 1:N
        for i in CartesianIndices(test[n])
            if Tuple(test[n][i]) != expected_result[n][i]
                return false
            end
        end
    end
    return true
end

@testset "ImageComponentAnalysis.jl" begin
    include("test_images.jl")
    include("test_volumes.jl")
    include("test_ellipse_images.jl")
    include("contour_tracing.jl")
    include("measurement.jl")
    include("generic_labelling.jl")
    include("one_component_2d.jl")
    include("one_component_3d.jl")
    include("basic_topology.jl")
    include("region_ellipse.jl")
    include("separate_components.jl")
    include("costa_outer.jl")
    include("moore_inner.jl")
end
