# Link the endpoints from a thinned image.
function link_endpoints(thinned_image, endpoints, Lp, Rn, Lc)
    lines, increments = get_line_segments(thinned_image, endpoints, Lc)
    get_links(endpoints, lines, increments, Lp, Rn)
end

# Overlay the links on the binary image using apply_color.
function overlay_links(binary_image, links, match_color, apply_color)
    overlay_image = copy(binary_image)
    for s in CartesianIndices(binary_image)
        if links[s] == match_color
            overlay_image[s] = apply_color
        end
    end
    overlay_image
end

# Get line segments that are used to calculate the line prolongations.
function get_line_segments(thinned_image, endpoints, Lc)

    height, width = size(thinned_image)
    lines = zeros(Int, (height, width))
    increments = NTuple{2, Float64}[]

    for line_number = 1:length(endpoints)
        previous_x, previous_y = x, y = endpoints[line_number]

        for current_Lc = 1:Lc
            count = 0
            candidate_x, candidate_y = (0, 0)
            for (next_x, next_y) = get_neighbours((x, y), (previous_x, previous_y), (height, width))
                if thinned_image[next_x, next_y] == 1
                    candidate_x, candidate_y = next_x, next_y
                    count += 1
                end
            end

            if count != 1 break end

            previous_x, previous_y = x, y
            x, y = candidate_x, candidate_y

            lines[x, y] = line_number
        end

        push!(increments, calculate_increments(x, y, endpoints[line_number]...))
    end

    lines, increments
end

# Get the surrounding neighbours of a pixel within image boundaries.
function get_neighbours(center, image_size)
    neighbour_ranges = map((c, s) -> max(1,c-1):min(c+1,s), center, image_size)
    function remove_center(neighbour)
        neighbour != center
    end
    Iterators.filter(remove_center, Iterators.product(neighbour_ranges...))
end

# Get the surrounding neighbours of a pixel within image boundaries without previous_pixel.
function get_neighbours(center, previous_pixel, image_size)
    function remove_previous(neighbour)
        neighbour != previous_pixel
    end
    Iterators.filter(remove_previous, get_neighbours(center, image_size))
end

# Calculate the x and y increments between 2 points.
function calculate_increments(x₀, y₀, x₁, y₁)
    steps = max(abs(x₁ - x₀), abs(y₁ - y₀), 1)
    (x₁ - x₀)/steps, (y₁ - y₀)/steps
end

# Get the missing links between endpoints as a two-dimensional array.
function get_links(endpoints, lines, increments, Lp, Rn)

    height, width = size(lines)
    line_count = length(increments)
    links = zeros(Int, (height, width))

    for prolongation = 1:Lp, line = 1:line_count

        if endpoints[line] == (0, 0) continue end
        row, col = @. round(Int, endpoints[line] + increments[line] * prolongation)
        if !(1 <= row <= height && 1 <= col <= width) continue end

        for (x, y) = search_radius((row, col), Rn, (height, width))
            if 0 < lines[x, y] != line
                connect_endpoints!(line, lines[x, y], endpoints, links)
                endpoints[lines[x, y]] = endpoints[line] = (0, 0)
                replace!(lines, line => 0, lines[x, y] => 0)
                break
            else
                lines[row, col] = line
            end
        end
    end

    links
end

# Search the pixels within image boundaries and length radius from the center.
function search_radius(center, radius, image_size)
    radius_ranges = map((c, s) -> max(1,c-radius):min(c+radius,s), center, image_size)
    function filter_circle(neighbour)
        round(Int, hypot(map((n, c) -> n-c, neighbour, center)...)) <= radius && neighbour != center
    end
    Iterators.filter(filter_circle, Iterators.product(radius_ranges...))
end

# Label the pixels connecting two endpoints with 1s.
function connect_endpoints!(line_1, line_2, endpoints, links)

    x₀, y₀ = endpoints[line_1]
    x₁, y₁ = endpoints[line_2]

    x_increment, y_increment = calculate_increments(x₀, y₀, x₁, y₁)

    for step = 0:max(abs(x₁ - x₀), abs(y₁ - y₀))

        links[round(Int, x₀), round(Int, y₀)] = 1

        x₀ += x_increment
        y₀ += y_increment
    end
end
