"""
```
    BoundingBox <: AbstractComponentAnalysisAlgorithm
    BoundingBox(;  box_area = true)
    analyze_components(components, f::BoundingBox)
    analyze_components!(df::AbstractDataFrame, components, f::BoundingBox)
```
Takes as input an array of labelled connected components and returns a
`DataFrame` with columns that store a tuple of `StepRange` types that demarcate
the minimum (image axis-aligned) bounding box of each component.

The function can optionally also return the box area.

# Example

```julia
using ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes

img = Gray.(testimage("blobs"))
img2 = binarize(img, Otsu())
components = label_components(img2, trues(3,3), 1)
measurements = analyze_components(components, BoundingBox(box_area = true))

```

"""
Base.@kwdef struct BoundingBox <: AbstractComponentAnalysisAlgorithm
    box_area::Bool = true
end

function(f::BoundingBox)(df::AbstractDataFrame, labels::AbstractArray{<:Integer})
    out = measure_feature(f, df, labels)
end

function measure_feature(property::BoundingBox, df::AbstractDataFrame, labels::AbstractArray)
    N =  maximum(labels)
    init = StepRange(typemax(Int),-1,-typemax(Int))
    coords = [(init, init) for i = 1:N]

    for i in CartesianIndices(labels)
        l = labels[i]
        if  l != 0
            rs, cs = coords[l]
            rs = i[1] < first(rs) ? StepRange(i[1], 1, last(rs)) : rs
            rs = i[1] > last(rs) ? StepRange(first(rs), 1, i[1]) : rs
            cs = i[2] < first(cs) ? StepRange(i[2], 1, last(cs)) : cs
            cs = i[2] > last(cs) ? StepRange(first(cs), 1, i[2]) : cs
            coords[l] = rs, cs
        end
    end
    coords_matrix = reshape(reinterpret(StepRange{Int,Int},coords),(2,N))
    df₁ = @transform(df, box_indices = coords)
    fill_properties(property, df₁)
end

function fill_properties(property::BoundingBox, df₀::AbstractDataFrame)
    df₁ = property.box_area ? compute_box_area(df₀) : df₀
end

function compute_box_area(df::AbstractDataFrame)
    @transform(df, box_area = length.(first.(:box_indices)) .*  length.(last.(:box_indices)))
end
