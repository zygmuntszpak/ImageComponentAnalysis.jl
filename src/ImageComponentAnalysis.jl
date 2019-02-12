module ImageComponentAnalysis

using Images, StaticArrays, DataStructures

abstract type ComponentAnalysisAlgorithm end
struct OneComponent2D <: ComponentAnalysisAlgorithm end
struct OneComponent3D <: ComponentAnalysisAlgorithm end
struct ContourTracing <: ComponentAnalysisAlgorithm end

abstract type Connectivity end
struct FourConnected <: Connectivity end
struct EightConnected <: Connectivity end

include("contour_tracing.jl")
include("one_component_2d.jl")
include("one_component_3d.jl")

export
    label_components,
    ContourTracing,
	  FourConnected,
	  EightConnected,
	  OneComponent2D,
    OneComponent3D
end # module
