
@testset "contour_tracing" begin

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        for i = 1:20
            test_image = eval(Symbol("test_image_$(i)"))

            # Call contour tracing algorithm and compare the number of components
            labels = ImageComponentAnalysis.label_components(ContourTracing(), test_image)
            num_components = maximum(labels)

            @test num_components == test_image_results[i]
        end
    end

end
