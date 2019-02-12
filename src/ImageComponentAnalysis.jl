module ImageComponentAnalysis

using Images
using PaddedViews
using OffsetArrays

abstract type ComponentAnalysisAlgorithm end
struct ContourTracing <: ComponentAnalysisAlgorithm end
struct CostaOuter <: ComponentAnalysisAlgorithm end
struct MooreInner <: ComponentAnalysisAlgorithm end

include("contour_tracing.jl")
include("costa_outer.jl")
include("moore_inner.jl")

export
    label_components,
	ContourTracing,
	CostaOuter,
	MooreInner
end # module
