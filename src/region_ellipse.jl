# [1] M. R. Teague, “Image analysis via the general theory of moments*,” Journal of the Optical Society of America, vol. 70, no. 8, p. 920, Aug. 1980.
# https://doi.org/10.1364/josa.70.000920
function measure_feature(property::RegionEllipse, t::IndexedTable, labels::AbstractArray, N::Int = 0)
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
    t = transform(t, :M₀₀ => ℳ₀₀, :M₁₀ => ℳ₁₀, :M₀₁ => ℳ₀₁, :M₁₁ => ℳ₁₁, :M₂₀ => ℳ₂₀, :M₀₂ => ℳ₀₂)
    fill_properties(property, t)
end

function fill_properties(property::RegionEllipse, t::IndexedTable)
    t = property.centroid ? compute_centroid(t) : t
    t = property.semi_axes ? compute_semi_axes(t) : t
    t = property.orientation ? compute_orientation(t) : t
    t = property.eccentricity ? compute_eccentricity(t) : t
end

function compute_centroid(t::IndexedTable)
    @transform t {centroid = (:M₀₁ / :M₀₀, :M₁₀ / :M₀₀)}
end

function compute_semi_axes(t::IndexedTable)
    semi_axes = select(t, (:M₀₀,  :M₁₀, :M₀₁, :M₁₁, :M₂₀, :M₀₂) => row -> compute_semi_axes(row...))
    t = transform(t, :semi_axes => semi_axes)
end


function compute_semi_axes(M₀₀::Real, M₁₀::Real, M₀₁::Real, M₁₁::Real, M₂₀::Real, M₀₂::Real)
    μ′₂₀ = (M₂₀ / M₀₀) - (M₁₀ / M₀₀)^2
    μ′₀₂ = (M₀₂ / M₀₀) - (M₀₁ / M₀₀)^2
    μ′₁₁ = (M₁₁ / M₀₀) - ((M₁₀ / M₀₀) * (M₀₁ / M₀₀))

    # See Equations (7) and (8) in [1].
    l₁ = sqrt((μ′₂₀ + μ′₀₂ + sqrt(4 * μ′₁₁^2 +  (μ′₂₀ - μ′₀₂)^2)) / (1 / 2))
    l₂ = sqrt((μ′₂₀ + μ′₀₂ - sqrt(4 * μ′₁₁^2 +  (μ′₂₀ - μ′₀₂)^2)) / (1 / 2))
    min(l₁, l₂), max(l₁, l₂)
end

function compute_orientation(t::IndexedTable)
    orientation = select(t, (:M₀₀,  :M₁₀, :M₀₁, :M₁₁, :M₂₀, :M₀₂) => row -> compute_orientation(row...))
    t = transform(t, :orientation => orientation)
end

function compute_eccentricity(t::IndexedTable)
    eccentricity = select(t, (:M₀₀,  :M₁₀, :M₀₁, :M₁₁, :M₂₀, :M₀₂) => row -> compute_eccentricity(row...))
    t = transform(t, :eccentricity => eccentricity)
end

function compute_eccentricity(M₀₀::Real, M₁₀::Real, M₀₁::Real, M₁₁::Real, M₂₀::Real, M₀₂::Real)
    b, a = compute_semi_axes(M₀₀, M₁₀, M₀₁, M₁₁, M₂₀, M₀₂)
    e = sqrt(1 - (b/a)^2)
end

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
