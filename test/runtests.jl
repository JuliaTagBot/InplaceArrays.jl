module RunTests

using Test

@time @testset "Helpers" begin include("HelpersTests/runtests.jl") end

@time @testset "Inference" begin include("InferenceTests/runtests.jl") end

@time @testset "TensorValues" begin include("TensorValuesTests/runtests.jl") end

@time @testset "Arrays" begin include("ArraysTests/runtests.jl") end

@time @testset "Fields" begin include("FieldsTests/runtests.jl") end

@time @testset "Polynomials" begin include("PolynomialsTests/runtests.jl") end

include("../bench/runbenchs.jl")

end # module
