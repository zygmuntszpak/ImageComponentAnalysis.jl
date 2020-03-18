"""
```
    MinimumOrientedBoundingBox <: AbstractComponentAnalysisAlgorithm
    MinimumOrientedBoundingBox(;  oriented_box_area = true, oriented_box_aspect_ratio = true)
    analyze_components(components, f::MinimumOrientedBoundingBox)
    analyze_components!(df::AbstractDataFrame, components, f::MinimumOrientedBoundingBox)
```
Takes as input an array of labelled connected components and returns a
`DataFrame` with columns that store a length-4 vector containing the four corner
points of the minimum oriented bounding box of each component. It optionally
also returns the area and aspect ratio of the minimum oriented bounding box.

# Example

```julia
using ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes

img = Gray.(testimage("blobs"))
img2 = binarize(img, Otsu())
components = label_components(img2, trues(3,3), 1)
algorithm = MinimumOrientedBoundingBox(oriented_box_area = true, oriented_box_aspect_ratio = true)
measurements = analyze_components(components, algorithm)

```

"""
Base.@kwdef struct MinimumOrientedBoundingBox <: AbstractComponentAnalysisAlgorithm
    oriented_box_area::Bool = true
    oriented_box_aspect_ratio::Bool = true
end

function(f::MinimumOrientedBoundingBox)(df::AbstractDataFrame, labels::AbstractArray{<:Integer})
    measure_feature!(df, labels, f)
    return nothing
end

function measure_feature!(df::AbstractDataFrame, labels::AbstractArray{<:Integer}, property::MinimumOrientedBoundingBox)
    N = maximum(labels)
    oriented_boxes = [determine_minimum_rectangle(findall(labels .== n))  for n = 1:N]
    df[!, :oriented_box] = oriented_boxes
    fill_properties!(df, property)
    return nothing
end

function fill_properties!(df::AbstractDataFrame, property::MinimumOrientedBoundingBox)
    property.oriented_box_area ? compute_oriented_box_area!(df) : nothing
    property.oriented_box_aspect_ratio ? compute_oriented_box_aspect_ratio!(df) : nothing
end

function compute_oriented_box_area!(df::AbstractDataFrame)
    df[!, :oriented_box_area] = Array{Float64}(undef, size(df,1))
    for r in eachrow(df)
        l₁ = norm(r.oriented_box[2] - r.oriented_box[1])
        l₂ = norm(r.oriented_box[3] - r.oriented_box[2])
        r.oriented_box_area = l₁ * l₂
    end
    return nothing
end

function compute_oriented_box_aspect_ratio!(df::AbstractDataFrame)
    df[!, :oriented_box_aspect_ratio] = Array{Float64}(undef, size(df,1))
    for r in eachrow(df)
        l₁ = norm(r.oriented_box[2] - r.oriented_box[1])
        l₂ = norm(r.oriented_box[3] - r.oriented_box[2])
        r.oriented_box_aspect_ratio = max(l₁, l₂) / min(l₁, l₂)
    end
    return nothing
end

function determine_minimum_rectangle(points₀::AbstractArray)
    # Determine the convex hull for the specified set of points.
    points = map(x-> SVector(x.I), points₀)
    chull = ConvexHull{CW, Float64}()
    jarvis_march!(chull, points)
    N = num_vertices(chull)
    vert = vertices(chull)
    if N == 1
        # When there is only a single vertex there is no unique minimum bounding
        # retangle. In this instance we mark the four corners of the bounding
        # rectangle as the vertex itself. #TODO Is there a better solution? Return Nothing?
        corners = [first(vert) for i = 1:4]
        return corners
    else
        smallest_area = typemax(Float64)
        for n₁ = 1:N
            n₂ = n₁ == N ? 1 : n₁ + 1
            edge = vert[n₂] - vert[n₁]
            # Unit norm vector pointing in the direction of the current edge.
            𝐞₁′ = edge / norm(edge)
            # Unit norm vector perpendicular to the edge direction.
            𝐞₂′ = SVector(-𝐞₁′[2], 𝐞₁′[1]) / norm(SVector(-𝐞₁′[2], 𝐞₁′[1]))
            # Transform points into the local coordinate system that is pinned to
            # vertex n₁.
            𝐞₁ = SVector(1, 0)
            𝐞₂ = SVector(0, 1)
            𝐑 = inv(hcat(𝐞₁, 𝐞₂)) * hcat(𝐞₁′, 𝐞₂′)
            𝐜 = vert[n₁]
            𝐭 = -𝐑' * 𝐜
            vert′ = map(𝐩 -> 𝐑' * 𝐩 + 𝐭 , vert)
            # Setup transformation for mapping points back to the original image
            # coordinate system.
            𝐑′ = inv(hcat(𝐞₁′, 𝐞₂′)) * hcat(𝐞₁, 𝐞₂)
            𝐜′ = 𝐑' * SVector(0,0) + 𝐭
            𝐭′ = -𝐑′' * 𝐜′
            # Determine the width and height of the bounding rectangle.
            r = reshape(reinterpret(Float64, vert′), (2,length(vert′)))
            max₁ = maximum(view(r, 1,:))
            min₁ = minimum(view(r, 1,:))
            max₂ = maximum(view(r, 2,:))
            min₂ = minimum(view(r, 2,:))
            h = max₁ - min₁
            w = max₂ - min₂
            area = w * h
            # Pick the smallest rectangle and determine its four corners with
            # respect to the canonical image coordinate system.
            if area < smallest_area
                smallest_area = area
                # Specify the four corners of the enclosing rectangle.
                𝐩₁′ =  SVector(min₁, max₂)
                𝐩₂′ =  SVector(max₁, max₂)
                𝐩₃′ =  SVector(max₁, min₂)
                𝐩₄′ =  SVector(min₁, min₂)
                corners′ = [𝐩₁′,  𝐩₂′, 𝐩₃′, 𝐩₄′]
                corners = map(𝐩 -> 𝐑′' * 𝐩 + 𝐭′, corners′)
            end
        end
        return corners
    end
end
