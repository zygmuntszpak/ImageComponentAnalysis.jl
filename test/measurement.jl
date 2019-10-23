@testset "area measurement" begin

    img = [0 0 0 0 0;
           0 1 0 1 0;
           0 1 1 0 0;
           0 0 0 0 0]

    labels  = label_components(Generic(), img, trues(3,3))
    t = measure_components((Measurement(),), labels)
    @test length(t) == 1

    row₁ = t[1]
    @test row₁.area == 4.375

    test_image_areas = ([0], [25], [1], [1, 1, 1, 1], [17], [16], [8.5],
                        [9.25], [4, 4], [21.25], [19.25], [20], [19.875],
                        [21.5], [17], [20.75, 8.5, 12.5], [38.5], [19.625, 8.75],
                        [25.5, 11], [31.5, 11.5])

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        for i = 1:20
            test_image = eval(Symbol("test_image_$(i)"))
            labels = label_components(Generic(), test_image, trues(3,3))
            t = measure_components((Measurement(),), labels)
            i == 1 ? (@test isempty(t)) : (@test all(select(t,:area) .== test_image_areas[i]))
        end
    end
end

@testset "perimeter" begin

    test_image_perimeters = ([0], [20], [4], [4, 4, 4, 4], [52], [48], [16],
                        [20], [10, 10], [28], [32], [34], [32],
                        [28], [30], [40, 16, 24], [76], [40, 24],
                        [72, 28], [64, 30])

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        for i = 1:20
            test_image = eval(Symbol("test_image_$(i)"))
            labels = label_components(Generic(), test_image, trues(3,3))
            t = measure_components((Measurement(),), labels)
            i == 1 ? (@test isempty(t)) : (@test all(select(t,:perimeter₁) .== test_image_perimeters[i]))
        end
    end
end
