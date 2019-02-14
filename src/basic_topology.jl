function measure_feature(property::BasicTopology, t::IndexedTable, labels::AbstractArray, N::Int = 0)
    N = N == 0 ? maximum(labels) : N
    fill_properties(property, t)
end

function fill_properties(property::BasicTopology, t::IndexedTable)
    t = property.holes ? determine_holes(t) : t
    t = property.euler_number ? compute_euler_number(t) : t
end

function compute_euler_number(t)
    @transform t {euler₄ = (1/4)*(:Q₁ - :Q₃ + 2*:Qₓ), euler₈ = (1/4)*(:Q₁ - :Q₃ - 2*:Qₓ)}
end

function determine_holes(t)
    # Number of holes equals the number of connected components (i.e. 1) minus
    # the Euler number.
    @transform t {holes = 1 - (1/4)*(:Q₁ - :Q₃ - 2*:Qₓ)}
end
