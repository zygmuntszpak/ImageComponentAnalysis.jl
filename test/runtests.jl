using ImageComponentAnalysis
using Test, ImageCore, DataFramesMeta, StaticArrays, TestImages
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
    include("minimum_oriented_bounding_box.jl")
    include("label_components.jl")
end
