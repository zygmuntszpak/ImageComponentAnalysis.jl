import LeftChildRightSiblingTrees: print
"""
```
    ContourTopology <: AbstractComponentAnalysisAlgorithm
    ContourTopology()
    analyze_components(components, f::ContourTopology)
    analyze_components!(df::AbstractDataFrame, components, f::ContourTopology)
```
Takes as input an array of labelled connected components and returns a
`DataFrame` with columns that store the contours for each connected component,
as well as the component labels of parent and child contours.


# Example

```julia
using ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes

img = Gray.(testimage("blobs"))
img2 = binarize(img, Otsu())
components = label_components(img2, trues(3,3), 1)
measurements = analyze_components(components, ContourTopology())

```

"""
struct ContourTopology <: AbstractComponentAnalysisAlgorithm
end

abstract type AbstractContour end

@with_kw struct DigitalContour <: AbstractContour
    id::Int = 0
    is_outer::Bool = false
    pixels::Vector{CartesianIndex{2}} = Vector{CartesianIndex{2}}(undef, 0)
end


function(f::ContourTopology)(df::AbstractDataFrame, labels::AbstractArray{<:Integer})
    #out = measure_feature(f, df, labels)
    hierarchy = establish_contour_hierarchy(labels)
end

function establish_contour_hierarchy(labels::AbstractArray{<:Integer})
    N = maximum(labels)
    # By padding we will avoid having to do out-of-bounds checking when we
    # consider a pixel's neighbourhood.
    labels_padded = padarray(labels, Fill(0, (2,2)))
    f = map(x-> x > 0 ? 1 : 0, labels_padded)
    root = Node(DigitalContour(is_outer = false))
    # root = Node("Hole Frame")
    # Labeled neighbourhood used by the contour-tracking algorithm.
    # 1 2 3
    # 0 P 4
    # 7 6 5
    N₈ = OffsetVector(CartesianIndex.([(0, -1), (-1, -1), (-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1)]), 0:7)
    # Keeps track of which neighbours in the N₈ have already been considered. (Required in Step (3.4) of the algorithm)
    has_visited_neighbour = OffsetVector(MVector(false, false, false, false, false, false, false , false), 0:7)
    # Enumerate new border
    nbd = 1
    rows, cols = axes(labels_padded)
    node = root
    id_to_node = Dict(1 => root)
    for i = first(rows):last(rows)
        lnbd = 1
        for j = first(cols):last(cols)
            fᵢⱼ = f[i, j]
            # Rule 1(a)
            is_outer = fᵢⱼ  == 1 && f[i, j - 1] == 0
            is_hole =  fᵢⱼ  >= 1 && f[i, j + 1] == 0
            if is_outer
                nbd = nbd + 1
                ij = CartesianIndex(i, j)
                i₂j₂ = CartesianIndex(i, j - 1)
                contour = trace_border!(f, ij, i₂j₂, nbd, lnbd, N₈, has_visited_neighbour)
                # Add the contour to contour hierarchy
                digital_contour = DigitalContour(id = nbd, is_outer = true, pixels = contour)
                #digital_contour = DigitalContour(id = labels_padded[ij], is_outer = true, pixels = contour)
                # Step (2): Decide the parent of the current border.
                prev_node = id_to_node[lnbd]
                #assign_grandparent = (is_outer && occursin("Outer",node₀.data))  ? true : false
                #node = assign_grandparent ? addchild(node₀.parent, "Outer $nbd") : addchild(node₀, "Outer $nbd")
                assign_grandparent = (is_outer && prev_node.data.is_outer) ? true : false
                # TODO set id according to label
                #digital_contour = DigitalContour(id = nbd, is_outer = true, pixels = contour)
                #@show typeof(prev_node.parent), typeof(prev_node), typeof(new_node)
                node = assign_grandparent ? addchild(prev_node.parent, digital_contour) : addchild(prev_node, digital_contour)
                id_to_node[nbd] = node
            elseif is_hole
                nbd = nbd + 1
                ij = CartesianIndex(i, j)
                i₂j₂ = CartesianIndex(i, j + 1)
                lnbd = fᵢⱼ > 1 ? fᵢⱼ : lnbd
                contour = trace_border!(f, ij, i₂j₂, nbd, lnbd, N₈, has_visited_neighbour)
                # Add the contour to contour hierarchy.
                #digital_contour = DigitalContour(id = labels_padded[ij], is_outer = false, pixels = contour)
                digital_contour = DigitalContour(id = nbd, is_outer = false, pixels = contour)
                # Step (2): Decide the parent of the current border.
                #assign_grandparent ? addchild(tree.parent, digital_contour) : addsibling(tree.child, digital_contour)
                prev_node = id_to_node[lnbd]
                #assign_grandparent = (is_hole && !node₀.is_outer)  ? true : false
                # assign_grandparent = (is_hole && occursin("Hole",node₀.data))  ? true : false
                # node = assign_grandparent ? addchild(node₀.parent, "Hole $nbd") : addchild(node₀, "Hole $nbd")
                assign_grandparent = (is_hole && !prev_node.data.is_outer)  ? true : false
                node = assign_grandparent ? addchild(prev_node.parent, digital_contour) : addchild(prev_node, digital_contour)
                id_to_node[nbd] = node
            end

            # Step (4): Update lndb and resume raster scan.
            # Note that the paper states only the conditon "fᵢⱼ != 1", but
            # we actually need to add "fᵢⱼ != 0" to ensure that we are
            # considering a border element, and not the background, lest we
            # set lndb to zero.
            if fᵢⱼ != 1 && fᵢⱼ != 0
                lnbd = abs(fᵢⱼ)
            end
        end
    end
    return root
end

# function measure_feature(property::ContourTopology, df::AbstractDataFrame, labels::AbstractArray{<:Integer})
#     #frame = DigitalContour(nothing, nothing, 0)
#     N = maximum(labels)
#     # By padding we will avoid having to do out-of-bounds checking when we
#     # consider a pixel's neighbourhood.
#     labels_padded = padarray(labels, Fill(0, (2,2)))
#     f = map(x-> x > 0 ? 1 : 0, labels_padded)
#     #tree = Node(DigitalContour(is_outer = true))
#     root = Node("Hole Frame")
#     # Labeled neighbourhood used by the contour-tracking algorithm.
#     # 1 2 3
#     # 0 P 4
#     # 7 6 5
#     N₈ = OffsetVector(CartesianIndex.([(0, -1), (-1, -1), (-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1)]), 0:7)
#     # Keeps track of which neighbours in the N₈ have already been considered. (Required in Step (3.4) of the algorithm)
#     has_visited_neighbour = OffsetVector(MVector(false, false, false, false, false, false, false , false), 0:7)
#     # Enumerate new border
#     nbd = 1
#     rows, cols = axes(labels_padded)
#     node = root
#     dict = Dict(1 => root)
#     for i = first(rows):last(rows)
#         lnbd = 1
#         for j = first(cols):last(cols)
#             fᵢⱼ = f[i, j]
#             # Rule 1(a)
#             is_outer = f[i, j] == 1 && f[i, j - 1] == 0
#             is_hole = f[i, j] >= 1 && f[i, j + 1] == 0
#             if is_outer
#                 nbd = nbd + 1
#                 ij = CartesianIndex(i, j)
#                 i₂j₂ = CartesianIndex(i, j - 1)
#                 contour = trace_border!(f, ij, i₂j₂, nbd, lnbd, N₈, has_visited_neighbour)
#                 # Add the contour to contour hierarchy
#                 digital_contour = DigitalContour(id = labels_padded[ij], is_outer = true, pixels = contour)
#                 # Step (2): Decide the parent of the current border.
#                 node₀ = dict[lnbd]
#                 assign_grandparent = (is_outer && occursin("Outer",node₀.data))  ? true : false
#                 node = assign_grandparent ? addchild(node₀.parent, "Outer $nbd") : addchild(node₀, "Outer $nbd")
#                 dict[nbd] = node
#                 @show lnbd, node₀, node₀.parent, node, nbd
#             elseif is_hole
#                 nbd = nbd + 1
#                 ij = CartesianIndex(i, j)
#                 i₂j₂ = CartesianIndex(i, j + 1)
#                 lnbd = fᵢⱼ > 1 ? fᵢⱼ : lnbd
#                 contour = trace_border!(f, ij, i₂j₂, nbd, lnbd, N₈, has_visited_neighbour)
#                 # Add the contour to contour hierarchy.
#                 digital_contour = DigitalContour(id = labels_padded[ij], is_outer = false, pixels = contour)
#                 # Step (2): Decide the parent of the current border.
#                 #assign_grandparent ? addchild(tree.parent, digital_contour) : addsibling(tree.child, digital_contour)
#                 node₀ = dict[lnbd]
#                 #assign_grandparent = (is_hole && !node₀.is_outer)  ? true : false
#                 assign_grandparent = (is_hole && occursin("Hole",node₀.data))  ? true : false
#                 node = assign_grandparent ? addchild(node₀.parent, "Hole $nbd") : addchild(node₀, "Hole $nbd")
#                 dict[nbd] = node
#                 @show lnbd, node₀, node₀.parent, node, nbd
#             end
#
#             # Step (4): Update lndb and resume raster scan.
#             # Note that the paper states only the conditon "fᵢⱼ != 1", but
#             # we actually need to add "fᵢⱼ != 0" to ensure that we are
#             # considering a border element, and not the background, lest we
#             # set lndb to zero.
#             if fᵢⱼ != 1 && fᵢⱼ != 0
#                 lnbd = abs(fᵢⱼ)
#             end
#         end
#     end
#     return f, root
# end

# Executes step (3) of Appendix 1 which involves tracing the detected border.
function trace_border!(f::AbstractArray, ij::CartesianIndex{2}, i₂j₂::CartesianIndex{2}, nbd::Integer, lndb::Integer, N₈::AbstractVector, has_visited_neighbour::AbstractVector)
    contour = Vector{CartesianIndex{2}}()
    # Step (3.1): clockwise search.
    found_nonzero, i₁j₁ = clockwise_search(f, ij, i₂j₂, N₈)
    if !found_nonzero
        f[ij] = -nbd
        # Go to Step (4).
        push!(contour, ij)
        return contour
    end
    # Step (3.2)
    i₂j₂ = i₁j₁
    i₃j₃ = ij
    has_finished_tracing = false
    while !has_finished_tracing
        # Step (3.3): counterclockwise search
        found_nonzero, i₄j₄ = counterclockwise_search(has_visited_neighbour, f, i₂j₂, i₃j₃, N₈)
        if !found_nonzero
            # This condition should never happen if the algorithm is implemented correctly.
            error("Step (3.3) of the Suzuki border tracing algorithm failed to find a non-zero pixel.")
        end
        # Step (3.4)
        direction = determine_direction(CartesianIndex(0, 1), N₈)
        if has_visited_neighbour[direction]
            f[i₃j₃] = -nbd
        elseif !has_visited_neighbour[direction] && f[i₃j₃] == 1
            f[i₃j₃] = nbd
        end
        #Step (3.5)
        push!(contour, i₃j₃)
        if (i₄j₄ == ij) && (i₃j₃ == i₁j₁)
            # We have reached the starting point.
            has_finished_tracing = true
        else
            i₂j₂ = i₃j₃
            i₃j₃ = i₄j₄
        end
        has_visited_neighbour .= false
    end

    return contour
end

# Executes part of Step (3.1) of Appendix 1.
function clockwise_search(f::AbstractArray, ij::CartesianIndex{2}, i₂j₂::CartesianIndex{2}, N₈::AbstractVector)
    # Assume that we won't find a non-zero pixel.
    found_nonzero = false
    i₁j₁ = ij
    # Search for the first non-zero pixel.
    Δij = i₂j₂ - ij
    direction = determine_direction(Δij, N₈)
    for d in range(direction; step = 1, stop = direction + 7)
        i₁j₁ = ij + N₈[mod(d, 8)]
        if f[i₁j₁] != 0
            found_nonzero = true
            break
        end
    end
    return found_nonzero, i₁j₁
end

# Executes part of Step (3.3) of Appendix 1.
function counterclockwise_search(visited_neighbours::AbstractVector, f::AbstractArray, i₂j₂::CartesianIndex{2}, i₃j₃::CartesianIndex{2}, N₈::AbstractVector)
    # Assume that we won't find a non-zero pixel.
    found_nonzero = false
    i₄j₄ = i₂j₂
    # Search for the first non-zero pixel.
    Δij =  i₂j₂ - i₃j₃
    direction = determine_direction(Δij, N₈)
    for d in Iterators.reverse(range(direction; step = 1, stop = direction + 7))
        i₄j₄ = i₃j₃ + N₈[mod(d, 8)]
        if f[i₄j₄] != 0
            found_nonzero = true
            break
        else
            visited_neighbours[mod(d, 8)] = true
        end
    end
    return found_nonzero, i₄j₄
end

function determine_direction(Δij::CartesianIndex{2}, N₈::AbstractVector)
    index = findfirst(x-> x == Δij, N₈)
    return index
end
