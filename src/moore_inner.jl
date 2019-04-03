function trace_boundary(t::MooreInner, labels::AbstractArray, N::Int = 0)
    N = N == 0 ? maximum(labels) : N
    boundary = [Vector{CartesianIndex{2}}(undef, 0) for n = 1:N]
    # By padding we will avoid having to do out-of-bounds checking when we
    # consider a pixel's neighbourhood.
    labels_padded = padarray(labels, Fill(0, (1,1)))
    # Labeled neighbourhood used by the contour-tracking algorithm which follows
    # the Freeman chaincode convention.
    # 3 2 1
    # 4 P 0
    # 5 6 7
    N₈ = OffsetVector(CartesianIndex.([(0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1), (1, 0), (1, 1)]), 0:7)
    stroke_direction = OffsetVector([6, 6, 0, 0, 2, 2, 4, 4], 0:7)
    isfirst = fill(true, N)
    # CartesianIndices(labels) will loop over the "interior" of labels_padded.
    for p in CartesianIndices(labels)
        l = labels_padded[p]
        l₄ = labels_padded[p + N₈[4]]
        if l != 0 &&  l₄ == 0 && isfirst[l]
            isfirst[l] = false
            # We will pretend that the second contour pixel is actually the first
            # one that we have found. This pretence will help in implementing
            # Jacobs stopping criteria. Once we trace around the contour we
            # will have included the true "first" boundary point anyway.
            p₁, direction₁  = find_second_inner(p, N₈, labels_padded, l, stroke_direction)
            # In this instance the component must just be a single pixel so there is nothing to trace.
            if p₁ == p
                push!(boundary[l], p₁)
                continue
            end

            push!(boundary[l], p₁)
            # Jacobs stopping criteria means we stop if we enter the starting
            # boundary pixel in the same manner in which we entered it initially.
            # Conceptually, when tracing a moore neighbourhood
            # as a "circle" we will stop at a pixel either on an "up", "down", "left" or
            # "right" stroke.

            pₙ₊₁, directionₙ₊₁ = find_next_inner(p₁, direction₁, N₈, labels_padded, l, stroke_direction)
            while !(pₙ₊₁ == p₁ && directionₙ₊₁ == direction₁)
                push!(boundary[l], pₙ₊₁)
                directionₙ = directionₙ₊₁
                pₙ₊₁, directionₙ₊₁ = find_next_inner(pₙ₊₁, directionₙ, N₈, labels_padded, l, stroke_direction)
            end
        end
    end
    boundary
end

function find_second_inner(p, N₈, labels, l, stroke_direction)
    pₙ₊₁ = p
    current = 4
    for r = current:12
        if labels[p + N₈[mod(r, 8)]] == l
            pₙ₊₁ = p + N₈[mod(r, 8)]
            current = mod(r, 8)
            break
        end
    end
    pₙ₊₁, stroke_direction[current]
end

function find_next_inner(p, previous, N₈, labels, l, stroke_direction)
    # These initial values will be overwritten in the loop.
    pₙ₊₁ = p
    current = previous
    for r = 0:7
        dₜ =  mod(previous + r, 8)
        pₜ = p + N₈[dₜ]
        if labels[pₜ] == l
            pₙ₊₁ =  pₜ
            current = dₜ
            break
        end
    end
    pₙ₊₁, stroke_direction[current]
end
