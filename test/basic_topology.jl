@testset "euler number" begin

    euler_numbers = ([0], [1], [1], [1,1,1,1], [-3], [-4], [0],
                        [1], [1,1], [0], [0], [-1], [0],
                        [0], [-1], [0,0,0], [0], [0,1],
                        [0,0], [0,0])

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        for i = 1:20
            test_image = eval(Symbol("test_image_$(i)"))
            labels = label_components(test_image, trues(3,3))
            t = analyze_components(labels, BasicTopology())
            i == 1 ? (@test isempty(t)) : (@test all(t.euler₈ .== euler_numbers[i]))
        end
    end
end

@testset "holes" begin

    img = [
    0 0 1 1 1 ;
    1 1 1 0 1 ;
    1 0 1 1 1 ;
    1 1 1 0 1 ;
    0 0 1 1 1]

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        labels = label_components(img)
        t = analyze_components(labels, BasicTopology())
        @test size(t, 1) == 1
        @test t.holes[1] == 3
    end
end
