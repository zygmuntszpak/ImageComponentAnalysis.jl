module ImageComponentAnalysis

using IndexedTables, JuliaDBMeta, OffsetArrays, StaticArrays, DataStructures
using ImageFiltering
using PlanarConvexHulls
using LinearAlgebra
using ImageMorphology

# Used in generic_labelling.jl to allow @nexprs macros.
using Base.Cartesian

abstract type AbstractMeasurementProperties end

struct Measurement <: AbstractMeasurementProperties
    area::Bool
    perimeter::Bool
end
Measurement(; area::Bool = true, perimeter::Bool = true) = Measurement(area, perimeter)


struct BoundingBox <: AbstractMeasurementProperties
    box_area::Bool
end
BoundingBox(; box_area::Bool = true) = BoundingBox(box_area)

struct MinimumOrientedBoundingBox <: AbstractMeasurementProperties
    oriented_box_area::Bool
    oriented_box_aspect_ratio::Bool
end
MinimumOrientedBoundingBox(; oriented_box_area::Bool = true, oriented_box_aspect_ratio = true) = MinimumOrientedBoundingBox(oriented_box_area, oriented_box_aspect_ratio)


struct BasicTopology <: AbstractMeasurementProperties
    holes::Bool
    euler_number::Bool
end
BasicTopology(; holes::Bool = true, euler_number::Bool = true) = BasicTopology(holes, euler_number)


struct RegionEllipse <: AbstractMeasurementProperties
    centroid::Bool
    semi_axes::Bool
    orientation::Bool
    eccentricity::Bool
end
RegionEllipse(; semi_axes::Bool = true, orientation::Bool = true, eccentricity::Bool = true, centroid::Bool = true) = RegionEllipse(centroid, semi_axes, orientation, eccentricity)

struct Boundary <: AbstractMeasurementProperties
    inner::Bool
    outer::Bool
    #holes_inner::Bool
    #holes_outer::Bool
end
Boundary(; inner::Bool = true, outer::Bool = true) = Boundary(inner, outer)


abstract type AbstractComponentLabellingAlgorithm end
struct OneComponent2D <: AbstractComponentLabellingAlgorithm end
struct OneComponent3D <: AbstractComponentLabellingAlgorithm end
struct Generic <: AbstractComponentLabellingAlgorithm end
struct ContourTracing <: AbstractComponentLabellingAlgorithm end

abstract type AbstractTracingAlgorithm end
struct CostaOuter <: AbstractTracingAlgorithm end
struct MooreInner <: AbstractTracingAlgorithm end

abstract type AbstractConnectivity end
struct FourConnected <: AbstractConnectivity end
struct EightConnected <: AbstractConnectivity end

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
include("separate_utility.jl")
include("separate_components.jl")
include("minimum_oriented_boundingbox.jl")

export
    # Types of analysis one can perform on a labelled binary image.
    Boundary,
    BoundingBox,
    MinimumOrientedBoundingBox,
    Measurement,
    BasicTopology,
    RegionEllipse,
    # Types of component labelling algorithms.
    ContourTracing,
    FourConnected,
    EightConnected,
    OneComponent2D,
    OneComponent3D,
    Generic,
    # Types of contour tracing algorithms
    CostaOuter,
    MooreInner,
    # Principal API
    measure_components,
    label_components,
    determine_minimum_rectangle,
    trace_boundary,
    # API still to be decided
    get_endpoints,
    join_line_segments,
    separate_components,
    label_separate_components
end # module
