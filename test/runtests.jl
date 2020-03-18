using ImageComponentAnalysis
using Test, ImageCore, StaticArrays
using AbstractTrees
const label_components = ImageComponentAnalysis.label_components

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
    include("measurement.jl")
    include("basic_topology.jl")
    include("contour_topology.jl")
    include("ellipse_region.jl")
    include("minimum_oriented_bounding_box.jl")
    include("label_components.jl")
    include("analyze_components_api.jl")
end
