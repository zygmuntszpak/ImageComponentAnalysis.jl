"""
```
get_endpoints(thinned_image)
```

Computes the endpoints of a thinned image.
"""
function get_endpoints(thinned_image::AbstractArray)

    @inbounds begin
        height, width = size(thinned_image)
        endpoints = NTuple{2, Int}[]

        for row = 1:height, col = 1:width
            if thinned_image[row, col] == 1
                count = 0
                for (x, y) = get_neighbours((row, col), (height, width))
                    if thinned_image[x, y] == 1
                        count += 1
                    end
                end

                if count != 1 continue end

                push!(endpoints, (row, col))
            end
        end

        endpoints
    end
end

"""
```
join_line_segments(thinned_image; prolongation_length, search_radius, calculation_length)
join_line_segments(thinned_image)
```

Joins the line segments of a thinned image.

# Output

Returns a two-dimensional array that represents the joined thinned image.

# Arguments

See [`separate_components`](@ref) for more details.
"""
function join_line_segments(thinned_image::AbstractArray; prolongation_length::Int = 50, search_radius::Int = 3, calculation_length::Int = 15)
    @inbounds begin
        endpoints = get_endpoints(thinned_image)
        links = link_endpoints(thinned_image, endpoints, prolongation_length, search_radius, calculation_length)
        overlay_links(thinned_image, links, 1, 1)
    end
end

"""
```
separate_components(binary_image; prolongation_length, search_radius, calculation_length)
separate_components(binary_image)
```

Separates the connected components of a binary image by gap-filling.

# Output

Returns a two-dimensional array that represents the separated components.

# Arguments

## `binary_image::AbstractArray`

The binary image made up of values 0 (black) and 1 (white).

## `prolongation_length::Int = 50`

The maximum length of line prolongation, typically the average length of a component.

## `search_radius::Int = 3`

The search radius for line prolongation, typically the average width of a component.

## `calculation_length::Int = 15`

The maximum length for calculating the direction from an endpoint.

# Reference

[1] M. Faessel, and F. Courtois, “Touching grain kernel separation by gap-filling”, Image Analysis and Stereology, vol. 28, no. 3, pp. 195-203, Nov. 2009. [doi:10.5566/ias.v28.p195-203](https://doi.org/10.5566/ias.v28.p195-203)
"""
function separate_components(binary_image::AbstractArray; prolongation_length::Int = 50, search_radius::Int = 3, calculation_length::Int = 15)
    @inbounds begin
        thinned_image = thinning(.!Bool.(binary_image))
        endpoints = get_endpoints(thinned_image)
        links = link_endpoints(thinned_image, endpoints, prolongation_length, search_radius, calculation_length)
        overlay_links(binary_image, links, 1, 0)
    end
end

"""
```
label_separate_components(binary_image; prolongation_length, search_radius, calculation_length)
label_separate_components(binary_image)
```

Same as [`separate_components`](@ref) except that it further computes the connected components using 4-connectivity.
"""
function label_separate_components(binary_image::AbstractArray; prolongation_length::Int = 50, search_radius::Int = 3, calculation_length::Int = 15)
    @inbounds begin
        separated_components = separate_components(binary_image; prolongation_length = prolongation_length, search_radius = search_radius, calculation_length = calculation_length)
        label_components(OneComponent2D(), separated_components, FourConnected())
    end
end
