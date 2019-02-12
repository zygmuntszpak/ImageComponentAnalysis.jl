"""
```
c = trace_contour(MooreTracing(), img)
```

Traces the inner countour of foreground component_bbox in a clockwise
motion. Note: Does not trace currently locate and trace any holes.

# Output

Returns a two-dimensional `Int` array of the coordinates of the outlines

## Reference
http://www.imageprocessingplace.com/downloads_V3/root_downloads/tutorials/contour_tracing_Abeer_George_Ghuneim/moore.html
"""
function trace_contour()#algorithm::MooreTracing, img::AbstractArray{Int,2})
    img = [1 1 1 1 1 1 1;
           1 1 0 0 0 1 1;
           1 1 0 0 0 1 1;
           1 1 0 0 0 1 1;
           0 1 1 0 1 1 0;
           0 1 1 0 1 1 0;
           0 1 1 1 1 1 0;
           0 1 1 1 1 1 0]
    component_bbox = zeros(Int, maximum(img), 4)
    hole_bbox_coordinates = Array{Int}(undef, 4)
    component_boundaries = Array{Array{Tuple{Int, Int}}}(undef, size(component_bbox, 1))
    previous = (1, 1)

    for i in 1:size(component_bbox, 1)
        component_bbox = bounding_box(img, component_bbox)
        boundary = Array{Tuple{Int, Int}}(undef, 0)
        inner_boundary = Array{Tuple{Int, Int}}(undef, 0)
        first_found = false
        hole_found = false
        box = view(img, component_bbox[i, 2]:component_bbox[i, 3], component_bbox[i, 1]:component_bbox[i, 4])
        pad_box_rows, pad_box_columns = size(box) .+ 2
        pad_box = PaddedView(0, box, (pad_box_rows, pad_box_columns), (2, 2))
        for c in 1:pad_box_columns
            for r in pad_box_rows:-1:1
                if pad_box[r, c] != 0 && first_found == false
                    push!(boundary, (r, c))
                    println("main ", boundary)
                    starting_pixel = (r, c)
                    boundary = trace_moore(pad_box, boundary, previous, starting_pixel)
                    first_found = true
                    @show pause
                elseif pad_box[r, c] == 0 && is_pixel_hole(pad_box, r, c, i) && hole_found == false
                    hole_bbox_coordinates[1] = c
                    hole_bbox_coordinates[2] = r
                    hole_bbox_coordinates[3] = r
                    hole_bbox_coordinates[4] = c
                    inner_boundary = find_hole_contour(pad_box, hole_bbox_coordinates, inner_boundary, previous, i)
                    println("inner ", inner_boundary)
                    inner_boundary = restore_inner(inner_boundary, hole_bbox_coordinates)
                    hole_found = true
                end
                previous = (r, c)
            end
        end
        append!(boundary, inner_boundary)
        component_boundaries[i] = boundary
    end
    component_boundaries = restore(component_boundaries, component_bbox)
    @show component_boundaries
    return component_boundaries
end

# Creates the bounds around each component
function bounding_box(img, component_bbox)
    for c in 1:size(img, 2)
        for r in size(img, 1):-1:1
            if img[r, c] != 0 && component_bbox[img[r, c], 1] != 0
                component_bbox[img[r, c], 2] = compare_top(component_bbox[img[r, c], 2], r)
                component_bbox[img[r, c], 3] = compare_bottom(component_bbox[img[r, c], 3], r)
                component_bbox[img[r, c], 4] = compare_right(component_bbox[img[r, c], 4], c)
            elseif img[r, c] != 0 && component_bbox[img[r, c], 1] == 0
                component_bbox[img[r, c], 1] = c
                component_bbox[img[r, c], 2] = r
                component_bbox[img[r, c], 3] = r
                component_bbox[img[r, c], 4] = c
            end
        end
    end
    return component_bbox
end

function inner_bounding_box(img, component_bbox, i)
    for c in 1:size(img, 2)
        for r in size(img, 2):-1:1
            if img[r, c] == 0 && is_pixel_hole(img, r, c, i) && component_bbox[1] == 0
                component_bbox[1] = c
                component_bbox[2] = r
                component_bbox[3] = r
                component_bbox[4] = c
            elseif img[r, c] == 0 && is_pixel_hole(img, r, c, i) && component_bbox[1] != 0
                component_bbox[2] = compare_top(component_bbox[2], r)
                component_bbox[3] = compare_bottom(component_bbox[3], r)
                component_bbox[4] = compare_right(component_bbox[4], c)
            end
        end
    end
    return component_bbox
end

function is_pixel_hole(pad_box, r, c, i)
    nrow, ncol = size(pad_box)
    topSum = 0
    bottomSum = 0
    leftSum = 0
    rightSum = 0
    for j in 1:r
        if pad_box[j, c] == i
            topSum += 1
        end
    end
    for j in r:size(pad_box, 1)
        if pad_box[j, c] == i
            bottomSum += 1
        end
    end
    for j in 1:c
        if pad_box[r, j] == i
            leftSum += 1
        end
    end
    for j in c:size(pad_box, 2)
        if pad_box[r, j] == i
            rightSum += 1
        end
    end
    if leftSum > 0 && rightSum > 0 && topSum > 0 && bottomSum > 0
        return true
    else
        return false
    end
end

function find_hole_contour(pad_box, hole_bbox_coordinates, inner_boundary, previous, i)
    hole_bbox_coordinates = inner_bounding_box(pad_box, hole_bbox_coordinates, i)
    hole_bbox = view(pad_box, hole_bbox_coordinates[2]:hole_bbox_coordinates[3], hole_bbox_coordinates[1]:hole_bbox_coordinates[4])
    pad_hole_box = PaddedView(i, hole_bbox, size(hole_bbox) .+ 2, (2, 2))
    pad_hole_box = PaddedView(0, pad_hole_box, size(pad_hole_box) .+ 2, (2 ,2))
    Base.display(pad_hole_box)
    pad_hole_rows, pad_hole_columns = size(pad_hole_box)
    for hole_c in 1:pad_hole_columns
        for hole_r in pad_hole_rows:-1:1
            if pad_hole_box[hole_r, hole_c] == 0 && is_pixel_hole(pad_hole_box, hole_r, hole_c, i)
                push!(inner_boundary, previous)
                println("inner contour ", inner_boundary)
                starting_pixel = (hole_r, hole_c)
                inner_boundary = inner_trace_moore(pad_hole_box, inner_boundary, previous, starting_pixel)
            end
            previous = hole_r, hole_c
        end
    end
    return inner_boundary
end

function inner_trace_moore(pad_hole_box, inner_boundary, previous, starting_pixel)
    steps = 0
    current_pixel = previous
    if length(inner_boundary) == 1
        previous, current_pixel = complete_moore_circle(current_pixel, starting_pixel, pad_hole_box, previous, false, inner_boundary)
    else
        starting_pixel = inner_boundary[1]
        while steps < 8
            if current_pixel != starting_pixel
                previous, current_pixel = complete_moore_circle(current_pixel, inner_boundary[length(inner_boundary)], pad_hole_box, previous, false, inner_boundary)
                steps += 1
            end
        end
    end
    return inner_boundary
end

# When a foreground pixel is detected, backtrack to the previous active pixel and
# move clockwise around the eight neighbourhood pixels until another foreground
# pixel is detected. return when starting pixel has been reached.
function trace_moore(pad_box, boundary, previous, starting_pixel)
    steps = 0
    # First step requires us to backtrace to the previous pixel.
    current_pixel = previous
    # Pixel boundary is the pixel that has been identified as a boundary, and is
    # the centrepiece of the Moore neighbourhood.
    pixel_boundary = boundary[length(boundary)]
    while steps < 8
        if current_pixel != starting_pixel
            previous, current_pixel, boundary = complete_moore_circle(current_pixel, pixel_boundary, pad_box, previous, true, boundary)
            @show boundary
            steps += 1
        else
            return boundary
        end
    end
    return boundary
end

function complete_moore_circle(current_pixel, anchor, box, previous, tracing_outer, boundary)
    @show current_pixel
    if (south_or_southeast(current_pixel, anchor)
        && is_pixel_background(box, current_pixel))
        previous = current_pixel
        current_pixel = current_pixel .+ (0,-1)
    elseif (west_or_southwest(current_pixel, anchor)
        && is_pixel_background(box, current_pixel))
        previous = current_pixel
        current_pixel = current_pixel .+ (-1, 0)
    elseif (north_or_northwest(current_pixel, anchor)
        && is_pixel_background(box, current_pixel))
        previous = current_pixel
        current_pixel = current_pixel .+ (0, 1)
    elseif (east_or_northeast(current_pixel, anchor)
        && is_pixel_background(box, current_pixel))
        previous = current_pixel
        current_pixel = current_pixel .+ (1, 0)
    else
        push!(boundary, current_pixel)
        println("moore circle ", boundary)
        current_pixel = previous
        return previous, current_pixel, boundary
    end
    return previous, current_pixel, boundary
end

# Coordinate functions are used to identify where the current pixel is with
# respect to the last boundary pixel.
function south_or_southeast(current_pixel, anchor_pixel)
    if ( Tuple(current_pixel) == anchor_pixel .+ (1,0)
        || Tuple(current_pixel) ==  anchor_pixel .+ (1,1) )
        return true
    else
        return false
    end
end

function west_or_southwest(current_pixel, anchor_pixel)
    if ( Tuple(current_pixel) == anchor_pixel .+ (1, -1)
        || Tuple(current_pixel) == anchor_pixel .+ (0, -1) )
        return true
    else
        return false
    end
end

function north_or_northwest(current_pixel, anchor_pixel)
    if ( Tuple(current_pixel) == anchor_pixel .+ (-1, 0)
        || Tuple(current_pixel) == anchor_pixel .+ (-1,-1) )
        return true
    else
        return false
    end
end

function east_or_northeast(current_pixel, anchor_pixel)
    if ( Tuple(current_pixel) == anchor_pixel .+ (-1, 1)
        || Tuple(current_pixel) == anchor_pixel .+ (0, 1) )
        return true
    else
        return false
    end
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
function restore(component_boundaries, component_bbox)
    for i in 1:size(component_bbox, 1)
        for j in 1:length(component_boundaries[i])
            component_boundaries[i][j] = component_boundaries[i][j] .+ (component_bbox[i, 2]-2, component_bbox[i, 1]-2)
        end
    end
    return component_boundaries
end

function restore_inner(component_boundaries, bbox)
    for j in 1:length(bbox)
        component_boundaries[j] = component_boundaries[j] .+ (bbox[2] - 2, bbox[1] - 2)
    end
    return component_boundaries
end

# The compare functions are to expand the bounding box only where necessary
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
