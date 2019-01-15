module ImageComponentAnalysis

using Images

abstract type ComponentAnalysisAlgorithm end
struct ContourTracing <: ComponentAnalysisAlgorithm end

include("contour_tracing.jl")

export
    label_components,
	ContourTracing
end # module
