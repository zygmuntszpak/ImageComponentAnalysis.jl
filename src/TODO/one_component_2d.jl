"""
```
label_components(OneComponent2D(), binary_image, connectivity)
label_components(OneComponent2D(), binary_image)
```

Computes the connected components of a binary image using the connectivity specified.

# Output

Returns a two-dimensional `Int` array that represents the label of every pixel.

# Arguments

## `binary_image::AbstractArray`

The binary image made up of values 0 (black) and 1 (white).

## `connectivity::Union{FourConnected, EightConnected}`

The connectivity used to compute the connected components. EightConnected is used if connectivity is not specified.

# Example

Computes the labels for the "blobs" image in the `TestImages` package using 4-connectivity.

```julia
using Images, TestImages, ImageBinarization, ImageComponentAnalysis

image = testimage("blobs")
binary_image = binarize(MinimumError(), image)

labels = label_components(OneComponent2D(), binary_image, FourConnected())
```
"""
function label_components(algorithm::OneComponent2D, binary_image::AbstractArray, connectivity::Union{FourConnected, EightConnected})

    @inbounds begin
        height, width = size(binary_image)
        queue = Tuple{Int, Int}[]

        labels = zeros(Int, (height, width))
        labelindex = 0

        neighbourhood = (typeof(connectivity) <: FourConnected) ? 4 : 8

        for row = 1:height, col = 1:width
            # Assign label to an unlabelled white pixel and push it to the queue.
            if (binary_image[row, col] == 1 && labels[row, col] == 0)
                labelindex += 1
                labels[row, col] = labelindex
                push!(queue, (row, col))
            end

            # Pop an element and search its neighbours until the queue is empty.
            while length(queue) != 0
                (neighbour_row, neighbour_col) = pop!(queue)
                search_neighbour(algorithm, neighbour_row, neighbour_col, height, width, binary_image, labels, labelindex, queue, neighbourhood)
            end
        end
        labels
    end
end

# Search a pixel's neighbour using the connectivity specified.
function search_neighbour(algorithm, row, col, height, width, binary_image, labels, labelindex, queue, neighbourhood)
    for search_index = 1:neighbourhood
        if ((neighbour = get_neighbour(algorithm, search_index, row, col, height, width)) != (0, 0))
            # Assign label to an unlabelled white pixel and push it to the queue.
            if (binary_image[neighbour...] == 1 && labels[neighbour...] == 0)
                labels[neighbour...] = labelindex
                push!(queue, neighbour)
            end
        end
    end
end

# Return a neighbour by the index or (0, 0) if out of bounds.
function get_neighbour(algorithm::OneComponent2D, index, row, col, height, width)

    if (index in @SVector [1, 5, 6]) row -= 1 end
    if (index in @SVector [2, 6, 7]) col += 1 end
    if (index in @SVector [3, 7, 8]) row += 1 end
    if (index in @SVector [4, 5, 8]) col -= 1 end

    inbounds(algorithm, row, col, height, width) ? (row, col) : (0, 0)
end

# Check if the current pixel is in bounds.
function inbounds(algorithm, row, col, height, width)
    return 1 <= row <= height && 1 <= col <= width
end

# Call the main function with EightConnected if connectivity is not specified.
function label_components(algorithm::OneComponent2D, binary_image::AbstractArray)
    label_components(algorithm, binary_image, EightConnected())
end
