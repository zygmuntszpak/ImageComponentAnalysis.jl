"""
```
    BasicTopology <: AbstractComponentAnalysisAlgorithm
    BasicTopology(; holes = true,  euler_number = true)
    analyze_components(labels, f::BasicTopolgy)
    analyze_components!(df::AbstractDataFrame, labels, f::BasicTopolgy)
```
Takes as input an array of labelled connected-components and returns a data
frame with columns that store the `euler_number` and the total number of `holes`
for each component.

# Example

```julia
using ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes

img = Gray.(testimage("blobs"))
img2 = binarize(img, Otsu())
components = label_components(img2, trues(3,3), 1)
measurements = analyze_components(components, BasicTopology(holes = true, euler_number = true))

```

"""
Base.@kwdef struct BasicTopology <: AbstractComponentAnalysisAlgorithm
    holes::Bool = true
    euler_number::Bool = true
end

function(f::BasicTopology)(df::AbstractDataFrame, labels::AbstractArray{<:Integer})
    present_symbols = names(df)
    required_symbols = [Symbol("Q₀"), Symbol("Q₁"), Symbol("Q₂"), Symbol("Q₃"), Symbol("Q₄"), Symbol("Qₓ")]
    has_bitcodes = all(map( x-> x in present_symbols, required_symbols))
    out = (!has_bitcodes) ? fill_properties(f, append_bitcodes(df, labels, nrow(df))) : fill_properties(f, df)
end

function fill_properties(property::BasicTopology, df₀::AbstractDataFrame)
    df₁ = property.holes ? determine_holes(df₀) : df₀
    df₂ = property.euler_number ? compute_euler_number(df₁) : df₁
end

function compute_euler_number(df::AbstractDataFrame)
    @transform(df, euler₄ = (1/4).*(:Q₁ .- :Q₃ .+ (2 .* :Qₓ)), euler₈ = (1/4).*(:Q₁ .- :Q₃ .- (2 .* :Qₓ)))
end

function determine_holes(df::AbstractDataFrame)
    # Number of holes equals the number of connected components (i.e. 1) minus
    # the Euler number.
    @transform(df, holes = 1 .- (1/4).*(:Q₁ .- :Q₃ .- (2 .* :Qₓ)))
end
