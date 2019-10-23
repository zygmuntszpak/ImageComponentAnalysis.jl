@testset "ellipse minor axis length" begin

    test_image_minor_axes_lengths = ([0], [5.773503], [1.154701],
                        [1.154701, 1.154701, 1.154701, 1.154701], [5.982882],
                        [5.537749], [3.651484], [3.944053], [1.154701, 1.154701], [5.341660],
                        [5.617433], [5.272805], [6.323095], [6.070635], [5.033223],
                        [4.570858, 3.651484, 5.163978], [10.105787],
                        [5.341433, 4.435154],
                        [11.796250 , 4.953113], [11.012302, 3.909324])

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        for i = 1:20
            test_image = eval(Symbol("test_image_$(i)"))
            labels = label_components(Generic(), test_image,trues(3,3))
            t = measure_components((RegionEllipse(),), labels)
            if i > 1
                semi_axes = select(t,:semi_axes)
                a = first.(collect(semi_axes)) * 2
                @test all(isapprox(a, test_image_minor_axes_lengths[i]; atol = 1e-5))
            end
        end
    end
end

@testset "ellipse major axis length" begin

    test_image_major_axes_lengths = ([0], [5.773503], [1.154701],
                        [1.154701, 1.154701, 1.154701, 1.154701], [5.982882],
                        [5.537749], [3.651484], [4.760952], [4.618802, 4.618802], [5.773503],
                        [5.925463], [5.925463], [6.461763], [6.218253], [6.110101],
                        [9.988690, 3.651484, 5.163978], [10.479679],
                        [8.610212, 5.171661],
                        [12.170053 , 5.773503], [12.078644, 6.426807])

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        for i = 1:20
            test_image = eval(Symbol("test_image_$(i)"))
            labels = label_components(Generic(), test_image,trues(3,3))
            t = measure_components((RegionEllipse(),), labels)
            if i > 1
                semi_axes = select(t,:semi_axes)
                b = last.(collect(semi_axes)) * 2
                @test all(isapprox(b, test_image_major_axes_lengths[i]; atol = 1e-5))
            end
        end
    end
end

@testset "ellipse centroid" begin

    test_image_centroids = ([(0,0)], [(3, 3)],
                        [(3, 3)],
                        [(2, 2), (4, 2), (2, 4), (4, 4)],
                        [(3, 3)],
                        [(3, 3)], [(3, 3)],
                        [(3.333333, 3)], [(2, 2.5), (4, 3.5)],
                        [(3, 3)],
                        [(3, 3)], [(2.888889, 3)],
                        [(3.052632, 3.052632)], [(2.904762, 3.095238)],
                        [(3.5, 3)],
                        [(3.25, 5.25), (8, 3), (7.5, 7.5)],
                        [(5.333333, 5.444444)],
                        [(3.833333, 4.333333), (8.5, 7.625)],
                        [(5.909091, 5.500000) , (6, 5.5)],
                        [(4.633333, 5.633333), (7.8, 5.3)])

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        for i = 1:20
            test_image = eval(Symbol("test_image_$(i)"))
            labels = label_components(Generic(), test_image,trues(3,3))
            t = measure_components((RegionEllipse(),), labels)
            if i > 1
                semi_axes = select(t,:centroid)
                c = collect.(semi_axes)
                @test all(isapprox(c, collect.(test_image_centroids[i]); atol = 1e-5))
            end
        end
    end
end

@testset "eccentricity" begin

    test_ellipse_image_eccentricities = ([3.650024149988857e-8],
                                         [0.7323338372368249],
                                         [0.8694282672026615],
                                         [5.960464477539063e-8],
                                         [0.9428090415820629])

    for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
        j = 1
        for i = 10:14
            test_image = eval(Symbol("test_ellipse_$(i)"))
            labels = label_components(Generic(), test_image,trues(3,3))
            t = measure_components((RegionEllipse(),), labels)
            e = select(t,:eccentricity)
            @test isapprox(e, test_ellipse_image_eccentricities[j]; atol = 1e-5)
            j += 1
        end
    end
end


# # TODO Revisit tests once we change the convention with which we represent the
# # ellipse orientation.
# @testset "ellipse orientation" begin
#
#     # test_image_orientations = ([0], [0],
#     #                     [0],
#     #                     [0, 0, 0, 0],
#     #                     [0],
#     #                     [0], [0],
#     #                     [0], [90],
#     #                     [0],
#     #                     [0], [0],
#     #                     [45], [-45],
#     #                     [0],
#     #                     [6.595305, 0, 0],
#     #                     [85.571021],
#     #                     [38.523618 , -28.997308],
#     #                     [90.000000 , 90.000000],
#     #                     [-2.443658, -62.871225])
#
#     for T in (Int, Bool, Gray{Bool}, Gray{N0f8}, Gray{N0f16}, Gray{N0f32}, Gray{Float64})
#         for i = 1:9
#             test_image = eval(Symbol("test_ellipse_$(i)"))
#             labels = Images.label_components(test_image,trues(3,3))
#             t = measure_components((RegionEllipse(),), labels)
#             θ = select(t,:orientation)
#             println(" $i => ")
#             Base.display(θ)
#             #Base.display(test_image_orientations[i])
#             println(" \n ")
#             #@test all(isapprox(θ, test_image_orientations[i]); atol = 5)
#         end
#     end
# end
