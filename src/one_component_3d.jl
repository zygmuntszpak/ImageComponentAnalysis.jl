"""
```
label_components(OneComponent3D(), binary_volume, local_window)
```

Computes the connected components of a binary volume using 26-connectivity.

# Output

Returns a three-dimensional `Int` array that represents the label of every voxel.

# Arguments

## `binary_volume::AbstractArray`

The binary volume made up of values 0 (black) and 1 (white).

## `local_window::NTuple{3, Int}`

The size of the local window for each iteration.

# Example

Computes the labels for a randomly generated 20 x 20 x 20 array using 5 x 7 x 7 local window.

```julia
using ImageComponentAnalysis

binary_volume = Int.(rand(Bool, 20, 20, 20))

labels = label_components(OneComponent3D(), binary_volume, (5, 7, 7))
```

# Reference

[1] Q. Hu, G. Qian, and W.L. Nowinski, “Fast connected-component labelling in three-dimensional binary images based on iterative recursion”, Computer Vision and Image Understanding, vol. 99, no. 3, pp. 414–434, Sep. 2005. [doi:10.1016/j.cviu.2005.04.001](https://doi.org/10.1016/j.cviu.2005.04.001)
"""
function label_components(algorithm::OneComponent3D, binary_volume::AbstractArray, local_window::NTuple{3, Int})

    @inbounds begin
        height, width, length = size(binary_volume)
        queue = Queue{NTuple{3, Int}}()

        n₁, n₂, n₃ = map((b, l) -> ceil(Int, (max(1, min(b, l)-1)/2)), size(binary_volume), local_window)
        labels = padarray(Int, binary_volume, Fill(0, (n₁ + 1, n₂ + 1, n₃ + 1)))
        labelindex = 3

        for x = 1:height, y = 1:width, z = 1:length
            if (labels[x, y, z] == 1)
                enqueue!(queue, (x, y, z))
                while !isempty(queue)
                    vᵢx, vᵢy, vᵢz = dequeue!(queue)
                    label_subvolume!(algorithm, vᵢx, vᵢy, vᵢz, n₁, n₂, n₃, queue, labels, labelindex)
                end
                labelindex += 1
            end
        end

        labels = view(labels, 1:height, 1:width, 1:length)
        replace!(s -> s >= 3 ? s-2 : 0, labels)
    end
end

# Label 26-connected voxels in the subvolume with the labelindex.
function label_subvolume!(algorithm, vᵢx, vᵢy, vᵢz, n₁, n₂, n₃, queue, labels, labelindex)

    window_size = 0
    center = (vᵢx, vᵢy, vᵢz)

    # Set center voxel of subvolume as labelindex.
    labels[vᵢx, vᵢy, vᵢz] = labelindex

    # Label 3 x 3 x 3 neighbourhood of center voxel.
    for (x, y, z) = get_neighbours(algorithm, 1, center, (n₁, n₂, n₃))
        if (labels[x, y, z] == 1)
            labels[x, y, z] = -10
        end
    end

    # Grow window size to local window.
    while window_size != max(n₁, n₂, n₃) + 1
        for (vx, vy, vz) = get_neighbours(algorithm, window_size, center, (n₁, n₂, n₃))

            # Label object voxels with distance of window_size.
            if (labels[vx, vy, vz] == -10)
                if (abs(vx - vᵢx) == n₁ || abs(vy - vᵢy) == n₂ || abs(vz - vᵢz) == n₃)
                    enqueue!(queue, (vx, vy, vz))
                end

                # Label 3 x 3 x 3 neighbourhood of current object voxel.
                for (x, y, z) = get_neighbours(algorithm, 1, (vx, vy, vz), (n₁, n₂, n₃), center)
                    if (labels[x, y, z] == 1)
                        labels[x, y, z] = -10
                        if (abs(x - vᵢx) == n₁ || abs(y - vᵢy) == n₂ || abs(z - vᵢz) == n₃)
                            enqueue!(queue, (x, y, z))
                        end
                    end
                end

                labels[vx, vy, vz] = labelindex
            end
        end
        window_size += 1
    end

    # Replace and queue all object voxels with label -10.
    for (x, y, z) = Iterators.product(vᵢx-n₁:vᵢx+n₁, vᵢy-n₂:vᵢy+n₂, vᵢz-n₃:vᵢz+n₃)
        if labels[x, y, z] == -10
            enqueue!(queue, (x, y, z))
            labels[x, y, z] = labelindex
        end
    end
end

# Get the neighbourhood of the center voxel.
function get_neighbours(algorithm::OneComponent3D, distance, center, n, truecenter = center)

    neighbour_ranges = map((c, n, t) -> max(t-n,c-distance):min(t+n,c+distance), center, n, truecenter)

    function select_neighbours((x, y, z))
        max(abs(x-center[1]), abs(y-center[2]), abs(z-center[3])) == distance
    end

    Iterators.filter(select_neighbours, Iterators.product(neighbour_ranges...))
end
