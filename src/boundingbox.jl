function measure_feature(property::BoundingBox, t::IndexedTable, labels::AbstractArray, N::Int = 0)
    N = N == 0 ? maximum(labels) : N
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
    t = pushcol(t, :r => view(coords_matrix,1,:), :c => view(coords_matrix,2,:))
    fill_properties(property, t)

end

function fill_properties(property::BoundingBox, t::IndexedTable)
    t = property.box_area ? compute_box_area(t) : t
end

function compute_box_area(t::IndexedTable)
    @transform t {box_area = length(:r) *  length(:c)}
end
