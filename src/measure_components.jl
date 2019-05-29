function measure_components(properties::Tuple{MeasurementProperties, Vararg{MeasurementProperties}}, labels::AbstractArray; N::Int = 0)
    N = N == 0 ? maximum(labels) : N
    # Set primary key as the component label.
    t = table(Base.OneTo(N); names = [:l], pkey=:l)
    # Some measurements require that we have computed so-called `Bit Quads`.
    usecodes = any(map(x->typeof(x) <: Union{Measurement, BasicTopology}, properties))
    t = usecodes ? append_bitcodes(t, labels, N) : t
    for i = 1:length(properties)
        t = measure_feature(properties[i], t, labels, N)
        Base.display(t)
    end
    t
end

function append_bitcodes(t::IndexedTable, labels::AbstractArray, N::Int)
    # Stores counts of Bit Quad patterns for each component.
    𝓠₀ = zeros(Int, N)
    𝓠₁ = zeros(Int, N)
    𝓠₂ = zeros(Int, N)
    𝓠₃ = zeros(Int, N)
    𝓠₄ = zeros(Int, N)
    𝓠ₓ = zeros(Int, N)
    rows, cols = axes(labels)
    labels_padded = padarray(labels, Fill(0, (2,2)))
    rows, cols = axes(labels_padded)
    for r = first(rows):last(rows)-1
        for c = first(cols):last(cols)-1
            for n = 1:N
                p₁ = labels_padded[r, c] == n ? 1 : 0
                p₂ = labels_padded[r + 1, c] == n ? 1 : 0
                p₃ = labels_padded[r, c + 1] == n ? 1 : 0
                p₄ = labels_padded[r + 1, c + 1] == n ? 1 : 0
                𝓠₀[n] = Q₀(p₁, p₂, p₃, p₄) ? 𝓠₀[n] + 1 : 𝓠₀[n]
                𝓠₁[n] = Q₁(p₁, p₂, p₃, p₄) ? 𝓠₁[n] + 1 : 𝓠₁[n]
                𝓠₂[n] = Q₂(p₁, p₂, p₃, p₄) ? 𝓠₂[n] + 1 : 𝓠₂[n]
                𝓠₃[n] = Q₃(p₁, p₂, p₃, p₄) ? 𝓠₃[n] + 1 : 𝓠₃[n]
                𝓠₄[n] = Q₄(p₁, p₂, p₃, p₄) ? 𝓠₄[n] + 1 : 𝓠₄[n]
                𝓠ₓ[n] = Qₓ(p₁, p₂, p₃, p₄) ? 𝓠ₓ[n] + 1 : 𝓠ₓ[n]
            end
        end
    end
    pushcol(t, :Q₀ => 𝓠₀, :Q₁ => 𝓠₁, :Q₂ => 𝓠₂, :Q₃ => 𝓠₃, :Q₄ => 𝓠₄, :Qₓ => 𝓠ₓ)
end


function Q₀(p₁, p₂, p₃, p₄)
    c₁ = (p₁ == 0 && p₂ == 0 && p₃ == 0 &&  p₄ == 0) ? true : false
end

function Q₁(p₁, p₂, p₃, p₄)
    c₁ = (p₁ == 1 && p₂ == 0 && p₃ == 0 &&  p₄ == 0) ? true : false
    c₂ = (p₁ == 0 && p₂ == 0 && p₃ == 1 &&  p₄ == 0) ? true : false
    c₃ = (p₁ == 0 && p₂ == 0 && p₃ == 0 &&  p₄ == 1) ? true : false
    c₄ = (p₁ == 0 && p₂ == 1 && p₃ == 0 &&  p₄ == 0) ? true : false
    c₁ || c₂ || c₃ || c₄
end

function Q₂(p₁, p₂, p₃, p₄)
    c₁ = (p₁ == 1 && p₂ == 0 && p₃ == 1 &&  p₄ == 0) ? true : false
    c₂ = (p₁ == 0 && p₂ == 0 && p₃ == 1 &&  p₄ == 1) ? true : false
    c₃ = (p₁ == 0 && p₂ == 1 && p₃ == 0 &&  p₄ == 1) ? true : false
    c₄ = (p₁ == 1 && p₂ == 1 && p₃ == 0 &&  p₄ == 0) ? true : false
    c₁ || c₂ || c₃ || c₄
end

function Q₃(p₁, p₂, p₃, p₄)
    c₁ = (p₁ == 1 && p₂ == 0 && p₃ == 1 &&  p₄ == 1) ? true : false
    c₂ = (p₁ == 0 && p₂ == 1 && p₃ == 1 &&  p₄ == 1) ? true : false
    c₃ = (p₁ == 1 && p₂ == 1 && p₃ == 0 &&  p₄ == 1) ? true : false
    c₄ = (p₁ == 1 && p₂ == 1 && p₃ == 1 &&  p₄ == 0) ? true : false
    c₁ || c₂ || c₃ || c₄
end

function Q₄(p₁, p₂, p₃, p₄)
    c₁ = (p₁ == 1 && p₂ == 1 && p₃ == 1 &&  p₄ == 1) ? true : false
end

function Qₓ(p₁, p₂, p₃, p₄)
    c₁ = (p₁ == 1 && p₂ == 0 && p₃ == 0 &&  p₄ == 1) ? true : false
    c₂ = (p₁ == 0 && p₂ == 1 && p₃ == 1 &&  p₄ == 0) ? true : false
    c₁ || c₂
end
