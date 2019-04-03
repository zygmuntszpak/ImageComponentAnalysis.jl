@testset "CostaOuter" begin
    labels = [0 0 0 0 0 0;
              0 1 1 1 0 0;
              0 1 1 1 0 0;
              0 1 1 1 0 0;
              0 0 0 0 0 0;
              0 0 0 0 0 0]
    N = 1
    t1 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t1 = [[(2, 1), (3, 1), (4, 1), (5, 2), (5, 3), (5, 4), (4, 5), (3, 5), (2, 5), (1, 4), (1, 3), (1, 2)]]
    @test compare(expected_result_t1, t1, N) == true

    labels = [0 0 0 0 0 0;
              0 1 1 1 0 0;
              0 1 1 1 0 0;
              0 0 1 1 1 0;
              0 0 1 1 1 0;
              0 0 0 0 0 0]
    N = 1
    t2 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t2 = [[(2, 1), (3, 1), (4, 2), (5, 2), (6, 3), (6, 4), (6, 5), (5, 6), (4, 6), (3, 5), (2, 5), (1, 4), (1, 3), (1, 2)]]
    @test compare(expected_result_t2, t2, N) == true

    labels = [0 0 0 0 0 0;
              0 1 1 1 1 0;
              0 0 0 0 0 0;
              0 2 2 2 2 0;
              0 0 0 0 0 0]
    N = 2
    t3 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t3 = [[(2, 1), (3, 2), (3, 3), (3, 4), (3, 5), (2, 6), (1, 5), (1, 4), (1, 3), (1, 2)],
                          [(4, 1), (5, 2), (5, 3), (5, 4), (5, 5), (4, 6), (3, 5), (3, 4), (3, 3), (3, 2)]]
    @test compare(expected_result_t3, t3, N) == true

    labels = [0 0 0 0 0 0;
              0 0 1 1 1 0;
              0 1 0 0 1 0;
              0 1 0 0 1 0;
              0 1 1 1 1 0;
              0 0 0 0 0 0]
    N = 1
    t4 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t4 = [[(3, 1), (4, 1), (5, 1), (6, 2), (6, 3), (6, 4), (6, 5), (5, 6), (4, 6), (3, 6), (2, 6), (1, 5), (1, 4), (1, 3), (2, 2), (3, 3), (3, 4), (4, 4), (4, 3), (3, 3), (2, 2)]]
    @test compare(expected_result_t4, t4, N) == true

    labels = [0 0 0 0 0 0;
              0 1 1 1 1 0;
              0 1 0 0 1 0;
              0 1 0 0 1 0;
              0 1 1 1 1 0;
              0 0 0 0 0 0]
    N = 1
    t5 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t5 = [[(2, 1), (3, 1), (4, 1), (5, 1), (6, 2), (6, 3), (6, 4), (6, 5), (5, 6), (4, 6), (3, 6), (2, 6), (1, 5), (1, 4), (1, 3), (1, 2)]]
    @test compare(expected_result_t5, t5, N) == true

    labels = [0 0 0 0;
              0 0 0 0;
              0 0 0 0;
              0 0 0 0]
    N = 0
    t6 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t6 = []
    @test compare(expected_result_t6, t6, N) == true

    labels = [0 0 0 0 0 0;
              0 1 0 2 0 0;
              0 0 0 0 0 0;
              0 0 3 0 4 0;
              0 0 0 0 0 0]
    N = 4
    t7 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t7 = [[(2,1), (3,2), (2,3), (1,2)], [(2,3), (3,4), (2,5), (1,4)],
                            [(4,2), (5,3), (4,4), (3,3)], [(4,4), (5,5), (4,6), (3,5)]]
    @test compare(expected_result_t7, t7, N) == true

    labels = [1 1 1 1;
              1 1 1 1;
              1 1 1 1;
              1 1 1 1]
    N = 1
    t8 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t8 = [[(1,0), (2,0), (3,0), (4,0), (5,1), (5,2), (5,3), (5,4), (4,5), (3,5), (2,5), (1,5), (0,4), (0,3), (0,2), (0,1)]]
    @test compare(expected_result_t8, t8, N) == true


    labels = [1 0 1 0 1;
              0 1 0 1 0;
              1 0 1 0 1;
              0 1 0 1 0]
    N = 1
    t9 = trace_boundary(CostaOuter(), labels, N)
    expected_result_t9 = [[(1,0), (2,1), (1,2), (0,1)]]
    @test_broken compare(expected_result_t9, t9, N) == false

end
