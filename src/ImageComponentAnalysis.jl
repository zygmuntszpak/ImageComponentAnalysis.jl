module ImageComponentAnalysis

using Images
using OffsetArrays
using StaticArrays
using DataStructures


abstract type ComponentAnalysisAlgorithm end
struct OneComponent2D <: ComponentAnalysisAlgorithm end
struct OneComponent3D <: ComponentAnalysisAlgorithm end
struct ContourTracing <: ComponentAnalysisAlgorithm end
struct CostaOuter <: ComponentAnalysisAlgorithm end
struct MooreInner <: ComponentAnalysisAlgorithm end

abstract type Connectivity end
struct FourConnected <: Connectivity end
struct EightConnected <: Connectivity end

include("contour_tracing.jl")
include("costa_outer.jl")
include("moore_inner.jl")
include("one_component_2d.jl")
include("one_component_3d.jl")

export
    label_components,
    ContourTracing,
	FourConnected,
	EightConnected,
	OneComponent2D,
    OneComponent3D,
	CostaOuter,
	MooreInner
end # module
