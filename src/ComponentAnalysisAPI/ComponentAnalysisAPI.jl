module ComponentAnalysisAPI

using DataFrames

"""
    AbstractImageAlgorithm

The root of image algorithms type system
"""
abstract type AbstractImageAlgorithm end

"""
    AbstractComponentAnalysis <: AbstractImageAlgorithm

Component Analysis refers to algorithms whose input is an array of integers
which label *connected components*.
"""
abstract type AbstractComponentAnalysis <: AbstractImageAlgorithm end

include("component_analysis.jl")

# we do not export any symbols since we don't require
# package developers to implemente all the APIs

end  # module ComponentAnalysisAPI
