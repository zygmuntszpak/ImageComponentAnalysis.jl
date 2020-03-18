# usage example for package developer:
#
#     import ComponentAnalysisAPI: AbstractComponentAnalysisAlgorithm,
#                             analyze_component, analyze_component!

"""
    AbstractComponentAnalysisAlgorithm <: AbstractComponentAnalysis

The root type for `ImageComponentAnalysis` package.

Any concrete component analysis algorithm shall subtype it to support
[`analyze_components`](@ref) and [`analyze_components!`](@ref) APIs.

# Examples

All component analysis algorithms in `ImageComponentAnalysis` are called in the
following pattern:

```julia
# determine the connected components and label them
components = label_components(binary_image)

# generate an algorithm instance
f = BasicMeasurement(area = true, perimiter = true)

# then pass the algorithm to `analyze_components`
measurements = analyze_components(components, f)

# or use in-place version `analyze_components!`
g = BoundingBox(area = true)
analyze_components!(measurements, components, g)
```

You can run a sequence of analyses by passing a tuple
of the relevant algorithms. For example,

```julia
# determine the connected components and label them
components = label_components(binary_image)

# generate algorithm instances
p = Contour()
q = MinimumOrientedBoundingBox(oriented_box_aspect_ratio = false)
r = EllipseRegion(semiaxes = true)

# then pass the algorithm to `analyze_components`
measurements = analyze_components(components, tuple(p, q, r))

# or use in-place version `analyze_components!`
analyze_components!(measurements, components, tuple(p, q, r))
```


Most algorithms receive additional information as an argument, such as `area` or
`perimeter` of `BasicMeasurement`. In general, arguments are boolean flags
that signal whether or not to include a particular feature in the analysis.

```julia
# you can explicit specify whether or not you wish to report certain
# properties
f = BasicMeasurement(area = false, perimiter = true)
```

For more examples, please check [`analyze_components`](@ref),
[`analyze_components!`](@ref) and concrete algorithms.
"""
abstract type AbstractComponentAnalysisAlgorithm <: AbstractComponentAnalysis end

analyze_components!(out::AbstractDataFrame,
                    labels::AbstractArray{<:Integer},
                    f::AbstractComponentAnalysisAlgorithm,
                    args...; kwargs...) =  f(out, labels, args...; kwargs...)



function analyze_components(labels::AbstractArray{<:Integer},
                            f::AbstractComponentAnalysisAlgorithm,
                            args...; kwargs...)

    out = DataFrame(l = Base.OneTo(maximum(labels)))
    analyze_components!(out, labels, f, args...; kwargs...)
    return out
end



# Handle instance where the input is several component analysis algorithms.
function analyze_components!(out::AbstractDataFrame,
                             labels::AbstractArray{<:Integer},
                             fs::Tuple{AbstractComponentAnalysisAlgorithm ,Vararg{AbstractComponentAnalysisAlgorithm}},
                             args...; kwargs...)
    for f in fs
       f(out, labels, args...; kwargs...)
    end
    return nothing
end


function analyze_components(labels::AbstractArray{<:Integer},
                            f::Tuple{AbstractComponentAnalysisAlgorithm ,Vararg{AbstractComponentAnalysisAlgorithm}},
                            args...; kwargs...)
     df = DataFrame(l = Base.OneTo(maximum(labels)))
     analyze_components!(df, labels, f, args...; kwargs...)
     return df
end

### Docstrings

"""
    analyze_components!(dataframe::AbstractDataFrame, components::AbstractArray{<:Integer}, f::AbstractComponentAnalysisAlgorithm, args...; kwargs...)
    analyze_components!(dataframe::AbstractDataFrame, components::AbstractArray{<:Integer}, fs::Tuple{AbstractComponentAnalysisAlgorithm, Vararg{AbstractComponentAnalysisAlgorithm}}, args...; kwargs...)

Analyze connected components using component analysis algorithm `f` or sequence
of algorithms specified in a tuple `fs`,  and store the results in a `DataFrame`.

# Output

The information about the components is stored in a `DataFrame`; each
row number contains information corresponding to a particular connected component.
The `DataFrame` will be changed in place and its columns will store the
measurements that algorithm `f` or algorithms `fs` computes.

# Examples

Just simply pass an algorithm to `analyze_components!`:

```julia
df = DataFrame()
f = BasicMeasurement()
analyze_components!(df, components, f)

fs = tuple(RegionEllipse(), Contour())
analyze_components!(df, components, fs)
```

See also: [`analyze_components`](@ref)
"""
analyze_components!

"""
    analyze_components(components::AbstractArray{<:Integer}, f::AbstractComponentAnalysisAlgorithm, args...; kwargs...)
    analyze_components(components::AbstractArray{<:Integer}, f::Tuple{AbstractComponentAnalysisAlgorithm, Vararg{AbstractComponentAnalysisAlgorithm}}, args...; kwargs...)

Analyze connected components using algorithm `f` or sequence
of algorithms specified in a tuple `fs`, and store the results in a `DataFrame`.

# Output

The information about the components is stored in a `DataFrame`; each row number
contains information corresponding to a particular connected component. The
columns of the `DataFrame` will store the measurements that algorithm `f` or
algorithms `fs` computes.

# Examples

Pass an array of labelled connected components and component analysis algorithm
to `analyze_component`.

```julia
f = BasicMeasurement()
analyze_components = analyze_component(components, f)

fs = tuple(RegionEllipse(), Contour())
analyze_components!(df, components, fs)
```

The first example reads as "`analyze_components` of connected `components` using
algorithm `f`".

See also [`analyze_components!`](@ref) for appending information about connected
components to an existing `DataFrame`.
"""
analyze_components
