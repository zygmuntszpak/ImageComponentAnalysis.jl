"""
```
label_components(ContourTracing(), binary_image)
```

Computes the connected components of a binary image using 8-connectivity.

# Output

Returns a two-dimensional `Int` array that represents the label of every pixel.

# Example

Computes the labels for the "blobs" image in the `TestImages` package.

```julia
using Images, TestImages, ImageBinarization, ImageComponentAnalysis

image = testimage("blobs")
binary_image = binarize(MinimumError(), image)

labels = label_components(ContourTracing(), binary_image)
```

# Reference

[1] F. Chang, C.-J. Chen, and C.-J. Lu, “A linear-time component-labeling algorithm using contour tracing technique”, Computer Vision and Image Understanding, vol. 93, no. 2, pp. 206–220, Feb. 2004. [doi:10.1016/j.cviu.2003.09.002](https://doi.org/10.1016/j.cviu.2003.09.002)
"""
function label_components(algorithm::ContourTracing, binary_image::AbstractArray)

  @inbounds begin
    height, width = size(binary_image)
    add_dummy_row = false

    # Check if all of the pixels are black in the first row.
    for col = 1:width
      if (add_dummy_row = binary_image[1, col] == 1) break end
    end

    # Add a dummy row on top if there is at least one white pixel in the first row.
    if add_dummy_row
      dummy_row = zeros(eltype(binary_image), (1, width))
      binary_image = vcat(dummy_row, binary_image)
      height += 1
    end

    labels = zeros(Int, (height, width))
    labelindex = 1

    # Assign label and perform contour checks for each white pixel.
    for row = 1:height
      for col = 1:width
        if (binary_image[row, col] == 1)

          # Assign current label, perform contour tracing and increment
          # the current label by one if it is an external contour.
          if (external_contour_check(algorithm, row, col, height, width, binary_image, labels))
            labels[row, col] = labelindex
            external_contour_tracing(algorithm, row, col, height, width, binary_image, labels, labelindex)
            labelindex += 1
          end

          # Perform contour tracing if it is an internal contour.
          if (internal_contour_check(algorithm, row, col, height, width, binary_image))
            # Assign the west neighbour's label if the current pixel is not an external contour.
            if (labels[row, col] == 0)
              assign_west_label(algorithm, row, col, height, width, labels)
            end
            internal_contour_tracing(algorithm, row, col, height, width, binary_image, labels)
          end

          # Assign the west neighbour's label if the current pixel is not a contour point.
          if (labels[row, col] == 0)
            assign_west_label(algorithm, row, col, height, width, labels)
          end

        end
      end
    end

    # Remove the dummy row if it was added.
    if add_dummy_row
      labels = labels[2:end, :]
    end

    # Set all background pixels to 0.
    replace!(labels, -1 => 0)
  end

  labels
end

# Perform contour tracing from northeast (index 7) with current label index.
function external_contour_tracing(algorithm, row, col, height, width, binary_image, labels, labelindex)
  contour_tracing(7, algorithm, row, col, height, width, binary_image, labels, labelindex)
end

# Check if the pixel is unlabelled and the north neighbour is black and in bounds.
function external_contour_check(algorithm, row, col, height, width, binary_image, labels)
  north_neighbour = get_north_neighbour(algorithm, row, col, height, width)
  if (labels[row, col] != 0) return false end
  return north_neighbour != (0, 0) && binary_image[north_neighbour...] == 0
end

# Perform contour tracing from southwest (index 3) with current pixel's label.
function internal_contour_tracing(algorithm, row, col, height, width, binary_image, labels)
  contour_tracing(3, algorithm, row, col, height, width, binary_image, labels, labels[row, col])
end

# Check if south neighbour is black and in bounds.
function internal_contour_check(algorithm, row, col, height, width, binary_image)
  south_neighbour = get_south_neighbour(algorithm, row, col, height, width)
  return south_neighbour != (0, 0) && binary_image[south_neighbour...] == 0
end

# Assign the west neighbour's label if the current pixel is unlabelled.
function assign_west_label(algorithm, row, col, height, width, labels)
  if ((west_neighbour = get_west_neighbour(algorithm, row, col, height, width)) != (0, 0))
    labels[row, col] = labels[west_neighbour...]
  end
end

# Get the neighbour to the north (index 6).
function get_north_neighbour(algorithm, row, col, height, width)
  north_neighbour = get_neighbour(6, algorithm, row, col, height, width)
end

# Get the neighbour to the south (index 2).
function get_south_neighbour(algorithm, row, col, height, width)
  south_neighbour = get_neighbour(2, algorithm, row, col, height, width)
end

# Get the neighbour to the west (index 4).
function get_west_neighbour(algorithm, row, col, height, width)
  west_neighbour = get_neighbour(4, algorithm, row, col, height, width)
end

# Return a neighbour by the index or (0, 0) if out of bounds.
function get_neighbour(index, algorithm::ContourTracing, row, col, height, width)

  if (1 <= index <= 3) row += 1 end
  if (3 <= index <= 5) col -= 1 end
  if (5 <= index <= 7) row -= 1 end
  if (index == 7|| 0 <= index <= 1) col += 1 end

  inbounds(algorithm, row, col, height, width) ? (row, col) : (0, 0)
end

# Check if the current pixel is in bounds.
function inbounds(algorithm::ContourTracing, row, col, height, width)
  return 1 <= row <= height && 1 <= col <= width
end

# Trace an external or internal contour.
function contour_tracing(search_index, algorithm, row, col, height, width, binary_image, labels, labelindex)

  initial_position = (row, col)
  previous_index = 0

  while (row, col) != (0, 0)
    row, col, previous_index = tracer(search_index, algorithm, row, col, height, width, binary_image, labels, labelindex)
    # Stop tracing if the tracer has returned to the starting point.
    if ((row, col) == initial_position) break end

    # Increase search index by two around the pixel.
    search_index = (previous_index + 2) % 8
  end
end

# Search the pixel's neighbours and assign labels starting from search_index.
function tracer(search_index, algorithm, row, col, height, width, binary_image, labels, labelindex)

  for search_iteration = 1:8

    neighbour = get_neighbour(search_index, algorithm, row, col, height, width)

    # Look for the next neighbour if the current neighbour is out of bounds.
    if (neighbour == (0, 0))
      # Increase search index by one around the pixel.
      search_index = (search_index + 1) % 8
      continue
    end

    # Assign label if the neighbour is white and -1 if it is black.
    if (binary_image[neighbour...] == 1)
      labels[neighbour...] = labelindex
      # Return the neighbour's position and the index relative to the current pixel.
      return (neighbour..., (search_index + 4) % 8)
    else
      labels[neighbour...] = -1
      # Increase search index by one around the pixel.
      search_index = (search_index + 1) % 8
    end
  end
  # Return zeros if the pixel is an isolated point.
  (0, 0, 0)
end
