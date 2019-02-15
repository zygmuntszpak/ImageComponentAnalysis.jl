@testset "MooreInner" begin
    labels = [0 0 0 0 0 0;
              0 1 1 1 0 0;
              0 1 1 1 0 0;
              0 1 1 1 0 0;
              0 0 0 0 0 0;
              0 0 0 0 0 0]
    N = 1
    t1 = trace_boundary(MooreInner, labels, N)
    expected_result_t1 = [[(2, 2), (2, 3), (2, 4), (3, 4), (4, 4), (4, 3), (4, 2), (3, 2)]]
    @test compare(expected_result_t1, t1, N) == true

    labels = [0 0 0 0 0 0;
              0 1 1 1 0 0;
              0 1 1 1 0 0;
              0 0 1 1 1 0;
              0 0 1 1 1 0;
              0 0 0 0 0 0]
    N = 1
    t2 = trace_boundary(MooreInner, labels, N)
    expected_result_t2 = [[(2, 2), (2, 3), (2, 4), (3, 4), (4, 5), (5, 5), (5, 4), (5, 3), (4, 3), (3, 2)]]
    @test compare(expected_result_t2, t2, N) == true

    labels = [0 0 0 0 0 0;
              1 1 1 1 1 1;
              0 0 0 0 0 0;
              2 2 2 2 2 2;
              0 0 0 0 0 0]
    N = 2
    t3 = trace_boundary(MooreInner, labels, N)
    expected_result_t3 = [[(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6)], [(4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6)]]
    @test compare(expected_result_t3, t3, N) == true

    labels = [0 0 0 0 0 0;
              0 0 1 1 1 0;
              0 1 0 0 1 0;
              0 1 0 0 1 0;
              0 1 1 1 1 0;
              0 0 0 0 0 0]
    N = 1
    t4 = trace_boundary(MooreInner, labels, N)
    expected_result_t4 = [[(3, 2), (2, 3), (2, 4), (2, 5), (3, 5), (4, 5), (5, 5), (5, 4), (5, 3), (5, 2), (4, 2)]]
    @test compare(expected_result_t4, t4, N) == true

    labels = [1 1 0 0 2 2;
              1 1 0 0 2 2;
              0 0 0 0 0 0;
              3 3 0 0 4 4;
              3 3 0 0 4 4]
    N = 4
    t5 = trace_boundary(MooreInner, labels, N)
    expected_result_t5 = [[(1, 1), (1, 2), (2, 2), (2, 1)], [(1, 5), (1, 6), (2, 6), (2, 5)],
    [(5, 1), (5, 2), (6, 2), (6, 1)], [(5, 5), (5, 6), (6, 6), (6, 5)]]
    @test compare(expected_result_t5, t5, N) == true

    labels = [0 0 0 0;
              0 0 0 0;
              0 0 0 0;
              0 0 0 0]
    N = 0
    t6 = trace_boundary(MooreInner, labels, N)
    expected_result_t6 = []
    @test compare(expected_result_t6, t6, N) == true

    labels = [1 0 2 0 3 0;
              0 0 0 0 0 0;
              0 4 0 5 0 6]
    N = 6
    t7 = trace_boundary(MooreInner, labels, N)
    expected_result_t7 = [[(1, 1)], [(1, 3)], [(1, 5)], [(3, 2)], [(3, 4)], [(3, 6)]]
    @test compare(expected_result_t7, t7, N) == true

end

function compare(expected_result, test, N)
    for i in 1:N
        for a in CartesianIndices(test[i])
            tupleindex = test[i][a]
            tupleindex = Tuple(tupleindex)
            if tupleindex != expected_result[i][a]
                return false
            end
        end
    end
    return true
end
