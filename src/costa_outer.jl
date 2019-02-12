# Based on the the "Contour Following Algorithm" described in Chapter 5 of
# Costa, L., Cesar, Jr., R., Laplante, P. (2009). Shape Classification and Analysis. Boca Raton: CRC Press, https://doi.org/10.1201/9780849379406
function trace_boundary(t::CostaOuter, labels::AbstractArray, N::Int = 0)
    N = N == 0 ? maximum(labels) : N
    boundary = [Vector{CartesianIndex{2}}(undef, 0) for n = 1:N]
    # By padding we will avoid having to do out-of-bounds checking when we
    # consider a pixel's neighbourhood.
    labels_padded = padarray(labels, Fill(0, (2,2)))
    # Labeled neighbourhood used by the contour-tracking algorithm which follows
    # the Freeman chain-code convention.
    # 3 2 1
    # 4 P 0
    # 5 6 7
    N₈ = OffsetVector(CartesianIndex.([(0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1), (1, 0), (1, 1)]), 0:7)
    invert = OffsetVector([4, 5, 6, 7, 0, 1, 2, 3], 0:7)
    isfirst = fill(true, N)
    nrow, ncol = size(labels)
    for p in CartesianIndices((0:nrow + 1, 0:ncol + 1))
        l = labels_padded[p]
        l₀ = labels_padded[p + N₈[0]]
        if l == 0 && l₀ != 0 && isfirst[l₀]
            B₁ = p
            push!(boundary[l₀], B₁)
            isfirst[l₀] = false
            pₙ₊₁, curr2next  = find_second_outer(p, N₈, labels_padded, l₀)
            while pₙ₊₁ != B₁
                push!(boundary[l₀], pₙ₊₁)
                prev2curr = curr2next
                pₙ₊₁, curr2next = find_next_outer(pₙ₊₁, prev2curr, N₈, labels_padded, l₀, invert)
            end
        end
    end
    boundary
end


function find_second_outer(p, N₈, labels, l)
    # Because we are tracing an outer contour, once we find the first pixel
    # there *must* be second pixel so we can be sure that this function will
    # always return from within the "if" statement.
    for r = 4:9
        pₙ₊₁ = p + N₈[mod(r, 8)]
        pₙ₊₂ = p + N₈[mod(r + 1, 8)]
        if labels[pₙ₊₁] == 0 && labels[pₙ₊₂] == l
            return pₙ₊₁, r
        end
    end
end

function find_next_outer(p, prev2curr, N₈, labels, l, invert)
    # These initial values will be overwritten in the loop.
    pₙ₊₁ = p
    curr2next = prev2curr

    curr2prev = invert[prev2curr]
    for r = 0:6
        dₑ =  mod(curr2prev + r, 8)
        dₗ =  mod(curr2prev + r + 1, 8)
        pₑ = p + N₈[dₑ]
        pₗ = p + N₈[dₗ]
        if labels[pₑ] == 0 && labels[pₗ] == l
            pₙ₊₁ =  pₑ
            curr2next = dₑ
        end
    end
    pₙ₊₁, curr2next
end
