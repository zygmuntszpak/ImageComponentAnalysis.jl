module ImageComponentAnalysis

using Images

abstract type ComponentAnalysisAlgorithm end
struct ContourTracing <: ComponentAnalysisAlgorithm end
struct MooreTracing <: ComponentAnalysisAlgorithm end
struct OuterTracing <: ComponentAnalysisAlgorithm end

include("contour_tracing.jl")
include("moore_tracing.jl")
include("outer_tracing.jl")

export
    label_components,
	ContourTracing,
	MooreTracing,
	OuterTracing
end # module
