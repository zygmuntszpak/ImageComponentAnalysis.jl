"""
```
c = trace_contour(MooreTracing(), img)
```

Traces the inner countour of foreground components in a clockwise
motion. Note: Does not trace currently locate and trace any holes.

# Output

Returns a two-dimensional `Int` array of the coordinates of the outlines

## Reference
http://www.imageprocessingplace.com/downloads_V3/root_downloads/tutorials/contour_tracing_Abeer_George_Ghuneim/moore.html
"""

using PaddedViews

# Move from bottom to top and left to right to find the first boundary pixel.
# Sets up starting pixel and array of the boundary coordinates needed to
# begin finding the boundary.
function trace_contour()#algorithm::MooreTracing, img::AbstractArray{Int,2})
    img = [1 1 1 0 0 0 0;
           1 1 1 1 0 0 0;
           1 1 1 0 0 0 0;
           1 1 1 1 0 0 0;
           0 0 0 0 0 2 2;
           0 0 0 2 2 2 2;
           0 0 0 2 2 2 2;
           0 0 0 2 2 2 2]
    boundary = Array{Tuple{Int, Int}}(undef, 0)
    components = zeros(Int, maximum(img), 4)
    boundary_lengths = Array{Int}(undef, 0)
    components = bounding_box(img, components)

    for i in 1:size(components, 1)
        first_found = false
        box = view(img, components[i, 2]:components[i, 3], components[i, 1]:components[i, 4])
        pad_box_rows, pad_box_columns = size(box) .+ 2
        pad_box = PaddedView(0, box, (pad_box_rows, pad_box_columns), (2, 2))
        Base.display(pad_box)
        previous = (pad_box, 1)
        for c in 1:pad_box_columns
            for r in pad_box_rows:-1:1
                if pad_box[r, c] != 0 && first_found == false
                    push!(boundary_lengths, 1)
                    push!(boundary, (r, c))
                    starting_pixel = (r, c)
                    boundary = trace_moore(pad_box, boundary, previous, starting_pixel, boundary_lengths)
                    first_found = true
                end
                previous = (r, c)
            end
        end
    end
    boundary = restore(boundary, boundary_lengths, components)
    @show boundary
    return boundary
end

# Creates the bounds around each component
function bounding_box(img, components)
    for c in 1:size(img, 2)
        for r in size(img, 1):-1:1
            if img[r, c] != 0 && components[img[r, c], 1] != 0
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

# When a foreground pixel is detected, backtrack to the previous active pixel and
# move clockwise around the eight neighbourhood pixels until another foreground
# pixel is detected. return when starting pixel has been reached.
function trace_moore(pad_box, boundary, previous, starting_pixel, boundary_lengths)
    steps = 0
    # First step requires us to backtrace to the previous pixel.
    current_pixel = previous
    # Pixel boundary is the pixel that has been identified as a boundary, and is
    # the centrepiece of the Moore neighbourhood.
    pixel_boundary = boundary[length(boundary)]
    while steps < 8
        if current_pixel != starting_pixel
            if (south_or_southeast(current_pixel, pixel_boundary)
                && is_pixel_background(pad_box, current_pixel))
                previous = current_pixel
                current_pixel = current_pixel .+ (0,-1)
            elseif (west_or_southwest(current_pixel, pixel_boundary)
                && is_pixel_background(pad_box, current_pixel))
                previous = current_pixel
                current_pixel = current_pixel .+ (-1, 0)
            elseif (north_or_northwest(current_pixel, pixel_boundary)
                && is_pixel_background(pad_box, current_pixel))
                previous = current_pixel
                current_pixel = current_pixel .+ (0, 1)
            elseif (east_or_northeast(current_pixel, pixel_boundary)
                && is_pixel_background(pad_box, current_pixel))
                previous = current_pixel
                current_pixel = current_pixel .+ (1, 0)
            else
                boundary_lengths[length(boundary_lengths)] += 1
                push!(boundary, current_pixel)
                trace_moore(pad_box, boundary, previous, starting_pixel, boundary_lengths)
                return boundary
            end
            steps += 1
        else
            return boundary
        end
    end
end

# Coordinate functions are used to identify where the current pixel is with
# respect to the last boundary pixel.
function south_or_southeast(current_pixel, pixel_boundary)
    if ( Tuple(current_pixel) == pixel_boundary .+ (1,0)
        || Tuple(current_pixel) ==  pixel_boundary .+ (1,1) )
        return true
    else
        return false
    end
end

function west_or_southwest(current_pixel, pixel_boundary)
    if ( Tuple(current_pixel) == pixel_boundary .+ (1, -1)
        || Tuple(current_pixel) == pixel_boundary .+ (0, -1) )
        return true
    else
        return false
    end
end

function north_or_northwest(current_pixel, pixel_boundary)
    if ( Tuple(current_pixel) == pixel_boundary .+ (-1, 0)
        || Tuple(current_pixel) == pixel_boundary .+ (-1,-1) )
        return true
    else
        return false
    end
end

function east_or_northeast(current_pixel, pixel_boundary)
    if ( Tuple(current_pixel) == pixel_boundary .+ (-1, 1)
        || Tuple(current_pixel) == pixel_boundary .+ (0, 1) )
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
function restore(boundary, boundary_lengths, components)
    start = 1
    for i in 1:length(boundary_lengths)
        for j in start:start+boundary_lengths[i]-1
            boundary[j] = boundary[j] .+ (components[i, 2]-2, components[i, 1]-2)
        end
        start += boundary_lengths[i]
    end
    return boundary
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
