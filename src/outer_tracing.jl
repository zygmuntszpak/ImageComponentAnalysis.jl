"""
```
c = trace_contour(OuterTracing(), img)
```

Traces the outer countour of foreground components in a counter clockwise
motion. Note: Does not trace currently locate and trace any holes. Images with
components touching the edge of the image will have the outer pixels trimmed.
Closed contours will have the same starting and ending pixel

# Output

Returns a two-dimensional `Int` array of the coordinates of the outlines

## Reference

"""
using PaddedViews

function trace_contour(algorithm::OuterTracing, img::AbstractArray{Int,2})
    img = trim_sides(img)
    boundary = Array{Tuple{Int, Int}}(undef, 0)
    components = zeros(Int, maximum(img), 4)
    boundary_lengths = zeros(Int, 1, size(components, 1))
    previous = (1, 1)
    components = bounding_box(img, components)

    # Creates a padded view of the component and searches for the first pixel to
    # start tracing
    for i in 1:size(components, 1)
        pₙ = (0, 0)
        first_found = false
        box = view(img, components[i, 2]:components[i, 3], components[i, 1]:components[i, 4])
        pad_box_rows, pad_box_columns = size(box) .+ 4
        pad_box = PaddedView(0, box, (pad_box_rows, pad_box_columns), (3, 3))
        for r in 1:size(pad_box, 1)
            for c in 1:size(pad_box, 2)
                if pad_box[r, c] != 0 && first_found == false
                    boundary = trace(pad_box, previous, boundary, boundary_lengths, pₙ, i)
                    first_found = true
                end
                previous = (r, c)
            end
        end
    end
    boundary = restore(boundary, boundary_lengths, components)
    draw(boundary, img)
    return boundary
end

function trim_sides(img)
    height = size(img, 1)
    width = size(img, 2)
    for r in 1:height
        if img[r, 1] != 0
            img[r, 1] = 0
        end
    end
    for r in 1:height
        if img[r, width] != 0
            img[r, width] = 0
        end
    end
    for c in 1:width
        if img[1, c] != 0
            img[1, c] = 0
        end
    end
    for c in 1:width
        if img[height, c] != 0
            img[height, c] = 0
        end
    end
    return img
end

function draw(boundary, img)
    contour_image = zeros(Int, size(img, 1), size(img, 2))
    for i in 1:length(boundary)
        if (boundary[i][1] >= 1 && boundary[i][2] >= 1) && (boundary[i][1] <= size(img, 1) && boundary[i][2] <= size(img, 2))
            contour_image[CartesianIndex(boundary[i])] = 1
        end
    end
end

function trace(pad_box, previous, boundary, boundary_lengths, pₙ, i)
    boundary_lengths[i] = 1
    push!(boundary, previous)
    next_pixel = set_next_pixel(pad_box, boundary)
    dcₙ = mask(Tuple(next_pixel), previous)
    push!(boundary, next_pixel)
    boundary_lengths[i] += 1
    if i == 1
        starter = 1
    else
        starter = boundary_lengths[i-1] + 1
    end
    while pₙ != boundary[starter]
        dₚc = dcₙ
        pₙ, dcₙ = find_next(boundary[length(boundary)], dₚc, next_pixel, dcₙ, pad_box)
        push!(boundary, pₙ)
        boundary_lengths[i] += 1
    end
    return boundary
end

function set_next_pixel(pad_box, boundary)
    if pad_box[CartesianIndex(boundary[length(boundary)] .+ (1, -1))] != 0
        next_pixel = boundary[length(boundary)] .+ (0, -1)
    elseif pad_box[CartesianIndex(boundary[length(boundary)] .+ (1, 0))] != 0
        next_pixel = boundary[length(boundary)] .+ (1, -1)
    elseif pad_box[CartesianIndex(boundary[length(boundary)] .+ (1, 1))] != 0
        next_pixel = boundary[length(boundary)] .+ (1, 0)
    elseif pad_box[CartesianIndex(boundary[length(boundary)] .+ (0, 1))] != 0
        next_pixel = boundary[length(boundary)] .+ (1, 1)
    end
    return next_pixel
end

# Translates coordinates to a number in reference to the previous pixel.
function mask(next, previous)
    if next == Tuple(previous) .+ (0, 1)
        return 0
    elseif next == Tuple(previous) .+ (-1, 1)
        return 1
    elseif next == Tuple(previous) .+ (-1, 0)
        return 2
    elseif next == Tuple(previous) .+ (-1, -1)
        return 3
    elseif next == Tuple(previous) .+ (0, -1)
        return 4
    elseif next == Tuple(previous) .+ (1, -1)
        return 5
    elseif next == Tuple(previous) .+ (1, 0)
        return  6
    elseif next == Tuple(previous) .+ (1, 1)
        return 7
    end
end

function invert(dₚc)
    if dₚc >= 4
        return dₚc - 4
    else
        return dₚc + 4
    end
end

function find_next(pc, dₚc, pₙ, dcₙ, pad_box)
    dcₚ = invert(dₚc)
    for r in 0:6
        dₑ = mod(dcₚ + r, 8)
        dᵢ = mod(dcₚ + r + 1, 8)
        pₑ = chainpoint(pc, dₑ)
        pᵢ = chainpoint(pc, dᵢ)
        if is_pixel_background(pad_box, pₑ) && !is_pixel_background(pad_box, pᵢ)
            pₙ = pₑ
            dcₙ = dₑ
        end
    end
    return pₙ, dcₙ
end

# Translates the mod calculation to coordinates.
function chainpoint(p, d)
    if d == 0
        return p .+ (0, 1)
    elseif d == 1
        return p .+ (-1, 1)
    elseif d == 2
        return p .+ (-1, 0)
    elseif d == 3
        return p .+ (-1, -1)
    elseif d == 4
        return p .+ (0, -1)
    elseif d == 5
        return p .+ (1, -1)
    elseif d == 6
        return p .+ (1, 0)
    elseif d == 7
        return p .+ (1, 1)
    end
end

# Creates the bounds around each component.
function bounding_box(img, components)
    for r in 1:size(img, 1)
        for c in 1:size(img, 2)
            if img[r, c] != 0 && components[img[r, c], 1] != 0
                components[img[r, c], 1] = compare_left(components[img[r, c], 1], c)
                components[img[r, c], 2] = compare_top(components[img[r, c], 2], r)
                components[img[r, c], 3] = compare_bottom(components[img[r, c], 3], r)
                components[img[r, c], 4] = compare_right(components[img[r, c], 4], c)
            elseif img[r, c] != 0 && components[img[r, c], 1] == 0
                components[img[r, c], 1] = c
                components[img[r, c], 2] = r
                components[img[r, c], 3] = r
                components[img[r, c], 4] = c
            end
        end
    end
    return components
end

function is_pixel_background(pad_box, current_pixel)
    if (pad_box[CartesianIndex(current_pixel)] == 0)
        return true
    else
        return false
    end
end

# Removes the padding from the bounding boxes and restores the view to the
# original array.
function restore(boundary, boundary_lengths, components)
    start = 1
    for i in 1:length(boundary_lengths)
        for j in start:start+boundary_lengths[i]-1
            boundary[j] = boundary[j] .+ (components[i, 2] - 3, components[i, 1] - 3)
        end
        start += boundary_lengths[i]
    end
    return boundary
end

# The compare functions are to expand the bounding box only where necessary.
function compare_left(current_left, new_left)
    if new_left < current_left
        return new_left
    else
        return current_left
    end
end

function compare_top(current_top, new_top)
    if new_top < current_top
        return new_top
    else
        return current_top
    end
end

function compare_bottom(current_bottom, new_bottom)
    if new_bottom > current_bottom
        return new_bottom
    else
        return current_bottom
    end
end

function compare_right(current_right, new_right)
    if new_right > current_right
        return new_right
    else
        return current_right
    end
end
