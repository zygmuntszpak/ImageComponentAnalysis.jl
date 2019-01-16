module ImageComponentAnalysis

using Images, StaticArrays

abstract type ComponentAnalysisAlgorithm end
struct OneComponent2D <: ComponentAnalysisAlgorithm end

abstract type Connectivity end
struct FourConnected <: Connectivity end
struct EightConnected <: Connectivity end

include("one_component_2d.jl")

export
    label_components,
	OneComponent2D,
	FourConnected,
	EightConnected
end # module
