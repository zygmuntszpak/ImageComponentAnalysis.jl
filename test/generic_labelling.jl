@testset "generic_labelling 2D" begin

   for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        for i = 1:20
            test_image = eval(Symbol("test_image_$(i)"))
            # Test using 8-connected neighbourhood
            labels = ImageComponentAnalysis.label_components(Generic(), test_image, trues(3,3))
            num_components = maximum(labels)
            @test num_components == test_image_results[i]
        end
    end
end

@testset "generic_labelling 3D" begin
    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
         for i = 1:20
             test_volume = eval(Symbol("test_volume_$(i)"))
             labels = ImageComponentAnalysis.label_components(Generic(), test_volume, trues(3,3,3))
             num_components = maximum(labels)
             @test num_components == test_volume_results[i]
         end
     end
end
