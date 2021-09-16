tV = SimpleRDArray(V)
tM = SimpleRDArray(M)
tT = SimpleRDArray(T)

@testset "Unary Operations: $f" for f in (:+, :-, :conj, :real, :imag)
    @eval begin
        @test $f(tV) == $f(V)
        @test $f(tM) == $f(M)
        @test $f(tT) == $f(T)
    end
end

@testset "Binary Operations: $f" for f in (:+, :-)
    @eval begin
        @test $f(tV, tV) == $f(tV, V) == $f(V, tV) == $f(V, V)
        @test $f(tM, tM) == $f(tM, M) == $f(M, tM) == $f(M, M)
        @test $f(tT, tT) == $f(tT, T) == $f(T, tT) == $f(T, T)
    end
end

@testset "N-ary Operations: $f" for f in (:+,)
    @eval begin
        @test $f(tV, tV, tV) == $f(V, V, V)
        @test $f(tM, tM, tM) == $f(M, M, M)
        @test $f(tT, tT, tT) == $f(T, T, T)
    end
end

@testset "Broadcast: $f" for f in (:+, :-, :*, :/, :\, :^)
    @eval begin
        @test $f.(tV, tV) == $f.(tV, V) == $f.(V, tV) == $f.(V, V)
    end
end

@testset "Linear Tlgebra: $f" for f in (transpose, adjoint)
    @eval @test $f(tV) == $f(V)
    @eval @test $f(tM) == $f(M)
    for bf in (:+, :-)
        @eval @test $bf($f(tV), $f(tV)) == $bf($f(V), $f(V))
        @eval @test $bf($f(tM), $f(tM)) == $bf($f(M), $f(M))
    end
    for bf in (:*,)
        @eval begin
            @test $bf($f(tV), tV) == $bf($f(V), V)
            @test $bf(tV, $f(tV)) == $bf(V, $f(V))
            @test $bf($f(tM), tM) == $bf($f(M), M)
            @test $bf(tM, $f(tM)) == $bf(M, $f(M))
        end
    end
end

@testset "Linear Tlgebra: M $f V and M $f M" for f in (:*, :\)
    @eval begin
        @test $f(tM, tV) == $f(tM, V) == $f(M, tV) == $f(M, V)
        @test $f(tM, tM) == $f(tM, M) == $f(M, tM) == $f(M, M)
    end
end