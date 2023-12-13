@testset "minimum oriented bounding box" begin
    expected_vertices = [SVector(30.0, 100.0), SVector(60.0, 100.0), SVector(60.0, 50.0), SVector(30.0, 50.0)]
    expected_area = 1500.0
    expected_aspect_ratio = 50/30
    img = zeros(Gray{Float64},(200,200))
    for r = 30:60
        for c = 50:100
            img[r,c] = 1.0
        end
    end
    labels = label_components(img)
    t = analyze_components(labels, MinimumOrientedBoundingBox())
    oriented_boxes = t.oriented_box
    oriented_box_areas = t.oriented_box_area
    oriented_box_aspect_ratios = t.oriented_box_aspect_ratio
    @test all(first(oriented_boxes) .== expected_vertices)
    @test first(oriented_box_areas) ≈ expected_area
    @test first(oriented_box_aspect_ratios) ≈ expected_aspect_ratio
end
