# [1] Pratt, William K., Digital Image Processing, New York, John Wiley & Sons, Inc., 1991, p. 634.
function measure_feature(property::Boundary, t::IndexedTable, labels::AbstractArray, N::Int = 0)
    fill_properties(property, t, labels)
end

function fill_properties(property::Boundary, t::IndexedTable, labels::AbstractArray)
    t = property.inner ? compute_inner_contour(t, labels) : t
    t = property.outer ? compute_outer_contour(t, labels) : t
end

function compute_inner_contour(t::IndexedTable, labels::AbstractArray)
    boundaries = trace_boundary(MooreInner(), labels)
    t = transform(t, :inner_boundary => boundaries)
end

function compute_outer_contour(t::IndexedTable, labels::AbstractArray)
    boundaries = trace_boundary(CostaOuter(), labels)
    t = transform(t, :outer_boundary => boundaries)
end
