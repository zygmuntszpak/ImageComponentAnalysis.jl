@testset "contour hierarchy" begin
    img1 = [0 0 0 0 0 0 0 0 0 0;
            0 1 1 1 1 1 1 1 0 0;
            0 1 0 0 0 0 0 1 0 0;
            0 1 0 1 1 1 0 1 0 0;
            0 1 0 1 0 1 0 1 0 0;
            0 1 0 1 1 1 0 1 0 0;
            0 1 0 0 0 0 0 1 0 0;
            0 1 1 1 1 1 1 1 0 0;]

    img2 =  [0 0 0 0 0 0 0 0 0 0;
             0 1 1 1 1 1 1 1 0 0;
             0 1 0 0 0 0 0 1 0 0;
             0 1 0 1 1 1 0 1 0 0;
             0 1 0 1 0 1 0 1 0 0;
             0 1 0 1 1 1 0 1 0 0;
             0 1 0 0 0 0 0 1 0 0;
             0 1 1 1 1 1 1 1 0 0;]

    img = hcat(img1, img2)
    component_labels = ImageComponentAnalysis.label_components(img, trues(3,3))
    tree = establish_contour_hierarchy(component_labels)
    expected_id = [2, 2, 1, 1, 4, 4, 3, 3, 0]
    expected_pixels = [[CartesianIndex(5, 4), CartesianIndex(4, 5), CartesianIndex(5, 6), CartesianIndex(6, 5)],
                       [CartesianIndex(4, 4), CartesianIndex(5, 4), CartesianIndex(6, 4), CartesianIndex(6, 5),
                        CartesianIndex(6, 6), CartesianIndex(5, 6), CartesianIndex(4, 6), CartesianIndex(4, 5)],
                       [CartesianIndex(3, 2), CartesianIndex(2, 3), CartesianIndex(2, 4), CartesianIndex(2, 5),
                        CartesianIndex(2, 6), CartesianIndex(2, 7), CartesianIndex(3, 8), CartesianIndex(4, 8),
                        CartesianIndex(5, 8), CartesianIndex(6, 8), CartesianIndex(7, 8), CartesianIndex(8, 7),
                        CartesianIndex(8, 6), CartesianIndex(8, 5), CartesianIndex(8, 4), CartesianIndex(8, 3),
                        CartesianIndex(7, 2), CartesianIndex(6, 2), CartesianIndex(5, 2), CartesianIndex(4, 2)],
                       [CartesianIndex(2, 2), CartesianIndex(3, 2), CartesianIndex(4, 2), CartesianIndex(5, 2),
                        CartesianIndex(6, 2), CartesianIndex(7, 2), CartesianIndex(8, 2), CartesianIndex(8, 3),
                        CartesianIndex(8, 4), CartesianIndex(8, 5), CartesianIndex(8, 6), CartesianIndex(8, 7),
                        CartesianIndex(8, 8), CartesianIndex(7, 8), CartesianIndex(6, 8), CartesianIndex(5, 8),
                        CartesianIndex(4, 8), CartesianIndex(3, 8), CartesianIndex(2, 8), CartesianIndex(2, 7),
                        CartesianIndex(2, 6), CartesianIndex(2, 5), CartesianIndex(2, 4), CartesianIndex(2, 3)],
                       [CartesianIndex(5, 14), CartesianIndex(4, 15), CartesianIndex(5, 16), CartesianIndex(6, 15)],
                       [CartesianIndex(4, 14), CartesianIndex(5, 14), CartesianIndex(6, 14), CartesianIndex(6, 15),
                        CartesianIndex(6, 16), CartesianIndex(5, 16), CartesianIndex(4, 16), CartesianIndex(4, 15)],
                       [CartesianIndex(3, 12), CartesianIndex(2, 13), CartesianIndex(2, 14), CartesianIndex(2, 15),
                        CartesianIndex(2, 16), CartesianIndex(2, 17), CartesianIndex(3, 18), CartesianIndex(4, 18),
                        CartesianIndex(5, 18), CartesianIndex(6, 18), CartesianIndex(7, 18), CartesianIndex(8, 17),
                        CartesianIndex(8, 16), CartesianIndex(8, 15), CartesianIndex(8, 14), CartesianIndex(8, 13),
                        CartesianIndex(7, 12), CartesianIndex(6, 12), CartesianIndex(5, 12), CartesianIndex(4, 12)],
                        [CartesianIndex(2, 12), CartesianIndex(3, 12), CartesianIndex(4, 12), CartesianIndex(5, 12),
                         CartesianIndex(6, 12), CartesianIndex(7, 12), CartesianIndex(8, 12), CartesianIndex(8, 13),
                         CartesianIndex(8, 14), CartesianIndex(8, 15), CartesianIndex(8, 16), CartesianIndex(8, 17),
                         CartesianIndex(8, 18), CartesianIndex(7, 18), CartesianIndex(6, 18), CartesianIndex(5, 18),
                         CartesianIndex(4, 18), CartesianIndex(3, 18), CartesianIndex(2, 18), CartesianIndex(2, 17),
                         CartesianIndex(2, 16), CartesianIndex(2, 15), CartesianIndex(2, 14), CartesianIndex(2, 13)],
                         []]
    for (k,i) in enumerate(PostOrderDFS(tree))
        @test i.data.id == expected_id[k]
        if k != 9
            @test all(i.data.pixels .== expected_pixels[k])
        end
    end
end
