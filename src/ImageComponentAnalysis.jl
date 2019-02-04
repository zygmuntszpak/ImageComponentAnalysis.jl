module ImageComponentAnalysis

using Images, DataStructures

abstract type ComponentAnalysisAlgorithm end
struct OneComponent3D <: ComponentAnalysisAlgorithm end

include("one_component_3d.jl")

export
    label_components,
	OneComponent3D
end # module
