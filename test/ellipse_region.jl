@testset "ellipse region" begin

    function geometric_to_algebraic(A::Number, B::Number, H::Number, K::Number, τ::Number)
        a = cos(τ)^2 / A^2 + sin(τ)^2/B^2
        b = (1/A^2 - 1/B^2)*sin(2*τ)
        c = cos(τ)^2/B^2 + sin(τ)^2/A^2
        d = (2*sin(τ)*(K*cos(τ) - H*sin(τ))) / B^2  -(2*cos(τ)^2 *(H + K*tan(τ))) / A^2
        e = (2*cos(τ)*(H*sin(τ) - K*cos(τ))) / B^2 - (2*sin(τ)*(H*cos(τ) + K*sin(τ))) / A^2
        f = (H*cos(τ) + K*sin(τ))^2 / A^2 + (K*cos(τ) - H*sin(τ))^2 / B^2 - 1
        return a, b, c, d, e, f
    end

    function generate_ellipse_region!(img, A::Number, B::Number, H::Number, K::Number, τ::Number)
        a, b, c, d, e, f = geometric_to_algebraic(A, B, H, K, τ)
        nrow, ncol = size(img)
        for y = 1:nrow
            for x = 1:ncol
                val = a*x^2 + b*x*y + c*y^2 + d*x + e*y + f
                img[y,x] =  val < 0 ? 1.0 : img[y,x]
            end
        end
    end

    img = zeros(80, 80)
    generate_ellipse_region!(img, 18, 10, 25, 25, deg2rad(135));
    generate_ellipse_region!(img, 18, 10, 50, 50, deg2rad(135));

    components = label_components(img, trues(3,3))
    measurements = analyze_components(components, EllipseRegion())

    @test all(round.(measurements[1,:].centroid) .== [25.0, 25.0])
    @test all(round.(measurements[2,:].centroid) .== [50.0, 50.0])

    @test all(round.(measurements[1,:].semiaxes) .== [10.0, 18.0])
    @test all(round.(measurements[2,:].semiaxes) .== [10.0, 18.0])

    @test round.(measurements[1,:].orientation) == -45
    @test round.(measurements[2,:].orientation) == - 45

    @test round.(measurements[1,:].eccentricity; digits = 2) == 0.83
    @test round.(measurements[2,:].eccentricity; digits = 2) == 0.83
end
