module ImageComponentAnalysis

using Images, IndexedTables, JuliaDBMeta, OffsetArrays, StaticArrays, DataStructures

# Used in generic_labelling.jl to allow @nexprs macros.
using Base.Cartesian

abstract type MeasurementProperties end

struct Measurement <: MeasurementProperties
	area::Bool
	perimeter::Bool
end
Measurement(; area::Bool = true, perimeter::Bool = true) = Measurement(area, perimeter)

struct BoundingBox <: MeasurementProperties
	box_area::Bool
end
BoundingBox(; box_area::Bool = true) = BoundingBox(box_area)

struct BasicTopology <: MeasurementProperties
	holes::Bool
	euler_number::Bool
end
BasicTopology(; holes::Bool = true, euler_number::Bool = true) = BasicTopology(holes, euler_number)

struct RegionEllipse <: MeasurementProperties
	centroid::Bool
	semi_axes::Bool
	orientation::Bool
	eccentricity::Bool
end
RegionEllipse(; semi_axes::Bool = true, orientation::Bool = true, eccentricity::Bool = true, centroid::Bool = true) = RegionEllipse(centroid, semi_axes, orientation, eccentricity)

struct Boundary <: MeasurementProperties
	inner::Bool
	outer::Bool
	#holes_inner::Bool
	#holes_outer::Bool
end
Boundary(; inner::Bool = true, outer::Bool = true) = Boundary(inner, outer)


abstract type ComponentLabellingAlgorithm end
struct OneComponent2D <: ComponentLabellingAlgorithm end
struct OneComponent3D <: ComponentLabellingAlgorithm end
struct Generic <: ComponentLabellingAlgorithm end
struct ContourTracing <: ComponentLabellingAlgorithm end

abstract type TracingAlgorithm end
struct CostaOuter <: TracingAlgorithm end
struct MooreInner <: TracingAlgorithm end

abstract type Connectivity end
struct FourConnected <: Connectivity end
struct EightConnected <: Connectivity end

include("boundingbox.jl")
include("measurement.jl")
include("basic_topology.jl")
include("region_ellipse.jl")
include("boundary.jl")
include("measure_components.jl")
include("contour_tracing.jl")
include("costa_outer.jl")
include("moore_inner.jl")
include("one_component_2d.jl")
include("one_component_3d.jl")
include("generic_labelling.jl")

export
	Boundary,
	BoundingBox,
	Measurement,
	BasicTopology,
	RegionEllipse,
	measure_components,
	label_components,
	ContourTracing,
	FourConnected,
	EightConnected,
	OneComponent2D,
  OneComponent3D,
	Generic,
	trace_boundary,
	CostaOuter,
	MooreInner
end # module
