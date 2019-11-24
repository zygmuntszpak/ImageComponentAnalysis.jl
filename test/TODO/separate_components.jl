
@testset "separate_components" begin

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})

        binary_image = T.(rand(Bool, 20, 20))
        binary_image_2 = copy(binary_image)

        thinned_image = thinning(.!Bool.(binary_image))
        thinned_image_2 = copy(thinned_image)

        endpoints = ImageComponentAnalysis.get_endpoints(thinned_image)

        @test typeof(endpoints) == Array{NTuple{2, Int}, 1}
        @test length(filter(e -> reduce(|, e .<= 0), endpoints)) == 0

        joined_line_segments = join_line_segments(thinned_image)
        @test thinned_image == thinned_image_2

        separated_components = separate_components(binary_image)
        @test binary_image == binary_image_2

        labelled_separated_components = label_separate_components(binary_image)
        @test binary_image == binary_image_2

        for Lp = -1:3, Rn = -1:3, Lc = -1:3

            joined_line_segments = join_line_segments(thinned_image; prolongation_length = Lp, search_radius = Rn, calculation_length = Lc)
            @test length(filter(p -> p != 0 && p!= 1, joined_line_segments)) == 0

            separated_components = separate_components(binary_image; prolongation_length = Lp, search_radius = Rn, calculation_length = Lc)
            @test length(filter(p -> p != 0 && p!= 1, separated_components)) == 0

            labelled_separated_components = label_separate_components(binary_image; prolongation_length = Lp, search_radius = Rn, calculation_length = Lc)
            @test length(filter(p -> p < 0, labelled_separated_components)) == 0
        end
    end

end
