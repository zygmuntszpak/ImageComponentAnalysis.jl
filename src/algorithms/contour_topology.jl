"""
```
    ContourTopology <: AbstractComponentAnalysisAlgorithm
    ContourTopology()
    analyze_components(components, f::ContourTopology)
    analyze_components!(df::AbstractDataFrame, components, f::ContourTopology)
```
Takes as input an array of labelled connected components and returns a
`DataFrame` with columns that store the contours for each connected component,
as well as the component labels of parent and child contours.


# Example

```julia
using ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes

img = Gray.(testimage("blobs"))
img2 = binarize(img, Otsu())
components = label_components(img2, trues(3,3), 1)
measurements = analyze_components(components, ContourTopology())

```

"""
struct ContourTopology <: AbstractComponentAnalysisAlgorithm
end

function(f::ContourTopology)(df::AbstractDataFrame, labels::AbstractArray{<:Integer})
    out = measure_feature(f, df, labels)
end

function measure_feature(property::ContourTopology, df::AbstractDataFrame, labels::AbstractArray{<:Integer})

end
