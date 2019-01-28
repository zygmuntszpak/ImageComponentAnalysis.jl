module ImageComponentAnalysis

using Images, IndexedTables, JuliaDBMeta, LinearAlgebra

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


abstract type ComponentAnalysisAlgorithm end
struct ContourTracing <: ComponentAnalysisAlgorithm end

include("boundingbox.jl")
include("measurement.jl")
include("basic_topology.jl")
include("region_ellipse.jl")
include("measure_components.jl")
include("contour_tracing.jl")

export
	BoundingBox,
	Measurement,
	BasicTopology,
	RegionEllipse,
	measure_components,
    label_components,
	ContourTracing
end # module
