"""
```
    BasicMeasurement <: AbstractComponentAnalysisAlgorithm
    BasicMeasurement(; area = true,  perimeter = true)
    analyze_components(labels, f::BasicMeasuremen)
    analyze_components!(df::AbstractDataFrame, labels, f::BasicMeasuremen)
```
Takes as input an array of labelled connected-components and returns a data
frame with columns that store the `area` and `perimeter` of each component.

# Example

```julia
using ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes

img = Gray.(testimage("blobs"))
img2 = binarize(img, Otsu())
components = label_components(img2, trues(3,3), 1)
measurements = analyze_components(components, BasicMeasurement(area = true, perimeter = false))

```

"""
Base.@kwdef struct BasicMeasurement <: AbstractComponentAnalysisAlgorithm
    area::Bool = true
    perimeter::Bool = true
end

function(f::BasicMeasurement)(df::AbstractDataFrame, labels::AbstractArray{<:Integer})
    present_symbols = names(df)
    required_symbols = [Symbol("Q₀"), Symbol("Q₁"), Symbol("Q₂"), Symbol("Q₃"), Symbol("Q₄"), Symbol("Qₓ")]
    has_bitcodes = all(map( x-> x in present_symbols, required_symbols))
    out = (!has_bitcodes) ? fill_properties(f, append_bitcodes(df, labels, nrow(df))) : fill_properties(f, df)
end

function fill_properties(property::BasicMeasurement, df₀::AbstractDataFrame)
    df₁ = property.area ? compute_area(df₀) : df₀
    df₂ = property.perimeter ? compute_perimeter(df₁) : df₁
end

function compute_area(df::AbstractDataFrame)
    # Equation 18.2-8a
    # Pratt, William K., Digital Image Processing, New York, John Wiley & Sons, Inc., 1991, p. 629.
    @transform(df, area = ((1/4)*:Q₁ + (1/2)*:Q₂ + (7/8)*:Q₃ + :Q₄ +(3/4)*:Qₓ))
end

function compute_perimeter(df::AbstractDataFrame)
    # perimiter₀ and perimter₁ are given by equations 18.2-8b and 18.2-7a in [1].
    # perimeter₂ is given by equation (32) in [2]
    # [1] Pratt, William K., Digital Image Processing, New York, John Wiley & Sons, Inc., 1991, p. 629.
    # [2] S. B. Gray, “Local Properties of Binary Images in Two Dimensions,” IEEE Transactions on Computers, vol. C–20, no. 5, pp. 551–561, May 1971. https://doi.org/10.1109/t-c.1971.223289
    @transform(df, perimeter₀ = (:Q₂ + (1/sqrt(2))*(:Q₁ + :Q₃ + 2*:Qₓ)), perimeter₁ = (:Q₁ + :Q₂ + :Q₃ + 2*:Qₓ), perimeter₂ = (:Q₂ + (:Q₁ +:Q₃)/sqrt(2)))
end