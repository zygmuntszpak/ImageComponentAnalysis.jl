"""
```
    EllipseRegion <: AbstractComponentAnalysisAlgorithm
    EllipseRegion(;  centroid = true, semiaxes = true, orientation = true, eccentricity = true)
    analyze_components(components, f::EllipseRegion)
    analyze_components!(df::AbstractDataFrame, components, f::EllipseRegion)
```
Takes as input an array of labelled connected components and returns a
`DataFrame` with columns that store the parameters of the best fit elliptic region
for each component. The ellipse parameters are as follows:

1.  `centroid`: A length-2 `SVector` representing the center of the ellipse.
2.  `semiaxes`: A length-2 `SVector` representing the length of the semimajor and semiminor axes respectively.
3.  `orientation` ∈ [-90, 90): the orientation in degrees of the semimajor axes with respect to the positive x-axis.
4.  `eccentricity`: a measure of how nearly circular the ellipse is.

# Example

```julia
using ImageComponentAnalysis, TestImages, ImageBinarization, ImageCore, AbstractTrees

img = Gray.(testimage("blobs"))
img2 = binarize(img, Otsu())
components = label_components(img2, trues(3,3), 1)
measurements = analyze_components(components, EllipseRegion())

```

# Reference
1. [1] M. R. Teague, “Image analysis via the general theory of moments*,” Journal of the Optical Society of America, vol. 70, no. 8, p. 920, Aug. 1980.
"""
Base.@kwdef struct EllipseRegion <: AbstractComponentAnalysisAlgorithm
    centroid::Bool = true
    semiaxes::Bool = true
    orientation::Bool = true
    eccentricity::Bool = true
end

function(f::EllipseRegion)(df::AbstractDataFrame, labels::AbstractArray{<:Integer})
    out = measure_feature(f, df, labels)
end


# [1] M. R. Teague, “Image analysis via the general theory of moments*,” Journal of the Optical Society of America, vol. 70, no. 8, p. 920, Aug. 1980.
# https://doi.org/10.1364/josa.70.000920
function measure_feature(property::EllipseRegion, df₁::AbstractDataFrame, labels::AbstractArray)
    N =  maximum(labels)
    init = StepRange(typemax(Int), -1, -typemax(Int))
    ℳ₀₀ = zeros(N)
    ℳ₁₀ = zeros(N)
    ℳ₀₁ = zeros(N)
    ℳ₁₁ = zeros(N)
    ℳ₂₀ = zeros(N)
    ℳ₀₂ = zeros(N)
    # TODO Document discretization model that underpins these moment computations.
    for i in CartesianIndices(labels)
        l = labels[i]
        if  l != 0
            y, x = i.I
            ℳ₀₀[l] += 1
            ℳ₁₀[l] += x
            ℳ₀₁[l] += y
            ℳ₁₁[l] += x*y
            ℳ₂₀[l] += x^2 + 1/12
            ℳ₀₂[l] += y^2 + 1/12
        end
    end
    df₂ = @transform(df₁, M₀₀ = ℳ₀₀, M₁₀ = ℳ₁₀, M₀₁ = ℳ₀₁, M₁₁ = ℳ₁₁, M₂₀ = ℳ₂₀, M₀₂ = ℳ₀₂)
    fill_properties(property, df₂)
end

function fill_properties(property::EllipseRegion, df₁::DataFrame)
    df₂ = property.centroid ? compute_centroid(df₁) : df₁
    df₃ = property.semiaxes ? compute_semiaxes(df₂) : df₂
    df₄ = property.orientation ? compute_orientation(df₃) : df₃
    df₅ = property.eccentricity ? compute_eccentricity(df₄) : df₄
end

function compute_centroid(df₁::DataFrame)
    df₂ = @byrow! df₁ begin
        @newcol centroid::Array{SArray{Tuple{2},Float64,1,2},1}
        :centroid = SVector(:M₀₁ / :M₀₀, :M₁₀ / :M₀₀)
    end
end

function compute_semiaxes(df₁::DataFrame)
    df₂ = @byrow! df₁ begin
        @newcol semiaxes::Array{SArray{Tuple{2},Float64,1,2},1}
        :semiaxes = compute_semiaxes(:M₀₀,  :M₁₀, :M₀₁, :M₁₁, :M₂₀, :M₀₂)
    end
end


function compute_semiaxes(M₀₀::Real, M₁₀::Real, M₀₁::Real, M₁₁::Real, M₂₀::Real, M₀₂::Real)
    μ′₂₀ = (M₂₀ / M₀₀) - (M₁₀ / M₀₀)^2
    μ′₀₂ = (M₀₂ / M₀₀) - (M₀₁ / M₀₀)^2
    μ′₁₁ = (M₁₁ / M₀₀) - ((M₁₀ / M₀₀) * (M₀₁ / M₀₀))

    # See Equations (7) and (8) in [1].
    l₁ = sqrt((μ′₂₀ + μ′₀₂ + sqrt(4 * μ′₁₁^2 +  (μ′₂₀ - μ′₀₂)^2)) / (1 / 2))
    l₂ = sqrt((μ′₂₀ + μ′₀₂ - sqrt(4 * μ′₁₁^2 +  (μ′₂₀ - μ′₀₂)^2)) / (1 / 2))
    SVector(min(l₁, l₂), max(l₁, l₂))
end

function compute_orientation(df₁::DataFrame)
    df₂ = @byrow! df₁ begin
        @newcol orientation::Array{Float64}
        :orientation = compute_orientation(:M₀₀,  :M₁₀, :M₀₁, :M₁₁, :M₂₀, :M₀₂)
    end
end

function compute_eccentricity(df₁::DataFrame)
    df₂ = @byrow! df₁ begin
        @newcol eccentricity::Array{Float64}
        :eccentricity = compute_eccentricity(:M₀₀,  :M₁₀, :M₀₁, :M₁₁, :M₂₀, :M₀₂)
    end
end

function compute_eccentricity(M₀₀::Real, M₁₀::Real, M₀₁::Real, M₁₁::Real, M₂₀::Real, M₀₂::Real)
    b, a = compute_semiaxes(M₀₀, M₁₀, M₀₁, M₁₁, M₂₀, M₀₂)
    e = sqrt(1 - (b/a)^2)
end
#
# [1] M. R. Teague, “Image analysis via the general theory of moments*,” Journal of the Optical Society of America, vol. 70, no. 8, p. 920, Aug. 1980.
# https://doi.org/10.1364/josa.70.000920
function compute_orientation(M₀₀::Real, M₁₀::Real, M₀₁::Real, M₁₁::Real, M₂₀::Real, M₀₂::Real)
    μ′₂₀ = M₂₀ / M₀₀ - (M₁₀ / M₀₀)^2
    μ′₀₂ = M₀₂ / M₀₀ - (M₀₁ / M₀₀)^2
    μ′₁₁ = M₁₁ / M₀₀ - (M₁₀ / M₀₀) * (M₀₁ / M₀₀)

    # Ellipse tilt angle for various cases of signs of the second moments [1].
    θ = 0.0
    if μ′₂₀ - μ′₀₂ == 0 && μ′₁₁  == 0
        θ = 0.0
    elseif μ′₂₀ - μ′₀₂ == 0 && μ′₁₁  > 0
        θ = 45.0
    elseif μ′₂₀ - μ′₀₂ == 0 && μ′₁₁  < 0
        θ = -45.0
    elseif μ′₂₀ - μ′₀₂ > 0 && μ′₁₁ == 0
        θ = 0.0
    elseif μ′₂₀ - μ′₀₂ < 0 && μ′₁₁ == 0
        θ = -90.0
    elseif μ′₂₀ - μ′₀₂ > 0 && μ′₁₁ > 0
        # 0 < θ < 45
        ξ = 2*μ′₁₁ / (μ′₂₀ - μ′₀₂)
        θ = (1/2) * atand(ξ)
    elseif μ′₂₀ - μ′₀₂ > 0 && μ′₁₁ < 0
        # -45 < θ < 0
        ξ = 2*μ′₁₁ / (μ′₂₀ - μ′₀₂)
        θ = (1/2) * atand(ξ)
    elseif μ′₂₀ - μ′₀₂ < 0 && μ′₁₁ > 0
        # 45 < θ < 90
        ξ = 2*μ′₁₁ / (μ′₂₀ - μ′₀₂)
        θ = (1/2) * atand(ξ) + 90.0
    elseif μ′₂₀ - μ′₀₂ < 0 && μ′₁₁ < 0
        # -90 < θ < -45
        ξ = 2*μ′₁₁ / (μ′₂₀ - μ′₀₂)
        θ = (1/2) * atand(ξ) - 90.0
    end
    θ
end
