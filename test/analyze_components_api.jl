@testset "analyze components api" begin
    symbols = [:l
               :Q₀
               :Q₁
               :Q₂
               :Q₃
               :Q₄
               :Qₓ
               :area
               :perimeter₀
               :perimeter₁
               :holes
               :euler₄
               :euler₈
               :box_indices
               :box_area
               :outer_contour
               :hole_contour
               :oriented_box
               :oriented_box_area
               :oriented_box_aspect_ratio
               :M₀₀
               :M₁₀
               :M₀₁
               :M₁₁
               :M₂₀
               :M₀₂
               :centroid
               :semiaxes
               :orientation
               :eccentricity]

    img = [0 0 0 0 0;
           0 1 0 1 0;
           0 1 1 0 0;
           0 0 0 0 0]

    components = label_components(img, trues(3,3), 1)
    algorithms = tuple(BasicMeasurement(),
                       BasicTopology(),
                       BoundingBox(),
                       Contour(),
                       MinimumOrientedBoundingBox(),
                       EllipseRegion())
    measurements = analyze_components(components, algorithms)

    @test all(Symbol.(names(measurements)) .== symbols)

end
