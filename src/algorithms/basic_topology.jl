"""
```
    BasicTopology <: AbstractComponentAnalysisAlgorithm
    BasicTopology(; holes = true,  euler_number = true)
    analyze_components(components, f::BasicTopolgy)
    analyze_components!(dataframe::AbstractDataFrame, components, f::BasicTopolgy)
```
Takes as input an array of labelled connected components and returns a `DataFrame`
with columns that store basic topological properties for each component, such as
the `euler_number` and the total number of `holes`.

The function returns two variants of the `euler_number`: `euler₄` and `euler₈`
which correspond to a `4-connected` versus `8-connected` neighbourhood.

The `euler_number` and number of `holes` are derived from *bit-quad* patterns,
which are certain 2 × 2 pixel patterns described in [1]. Hence, the function
adds six bit-quad patterns to the `DataFrame` under column names `Q₀, Q₁, Q₂,
Q₃, Q₄` and `Qₓ`.


# Example

```julia
using ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes

img = Gray.(testimage("blobs"))
img2 = binarize(img, Otsu())
components = label_components(img2, trues(3,3), 1)
measurements = analyze_components(components, BasicTopology(holes = true, euler_number = true))

```

# Reference
1. S. B. Gray, “Local Properties of Binary Images in Two Dimensions,” IEEE Transactions on Computers, vol. C–20, no. 5, pp. 551–561, May 1971.

"""
Base.@kwdef struct BasicTopology <: AbstractComponentAnalysisAlgorithm
    holes::Bool = true
    euler_number::Bool = true
end

function(f::BasicTopology)(df::AbstractDataFrame, labels::AbstractArray{<:Integer})
    present_symbols = names(df)
    required_symbols = [Symbol("Q₀"), Symbol("Q₁"), Symbol("Q₂"), Symbol("Q₃"), Symbol("Q₄"), Symbol("Qₓ")]
    has_bitcodes = all(map( x-> x in present_symbols, required_symbols))
    !(has_bitcodes) ? append_bitcodes!(df, labels, nrow(df)) : nothing
    fill_properties!(df, f)
    return nothing
end

function fill_properties!(df::AbstractDataFrame, property::BasicTopology)
    property.holes ? determine_holes!(df) : nothing
    property.euler_number ? compute_euler_number!(df) : nothing
end

function compute_euler_number!(df::AbstractDataFrame)
    df[!, :euler₄] = (1/4).*(df.Q₁ .- df.Q₃ .+ (2 .* df.Qₓ))
    df[!, :euler₈] = (1/4).*(df.Q₁ .- df.Q₃ .- (2 .* df.Qₓ))
end

function determine_holes!(df::AbstractDataFrame)
    # Number of holes equals the number of connected components (i.e. 1) minus
    # the Euler number.
    df[!, :holes] = 1 .- (1/4).*(df.Q₁ .- df.Q₃ .- (2 .* df.Qₓ))
end
