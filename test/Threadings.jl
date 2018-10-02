using Test
include("../src/Threadings.jl")
@testset "Threadings tests" begin
function f(x)
  # this bit takes about 10 seconds
  local a = 0.0
  for i in 1:10
    a += sum(cbrt.(sqrt.(rand(10_00_000))))
  end
  return x .+ 0 * a
end
itr = [i*collect(rand(5)) for i in 1:10]
a = Threadings.tmapreduce(f, +, itr, init=zeros(5))
b = mapreduce(f, +, itr, init=zeros(5))
ta = @elapsed Threadings.tmapreduce(f, +, itr, init=zeros(5))
tb = @elapsed mapreduce(f, +, itr, init=zeros(5))
@show ta, tb
Base.Threads.nthreads() == 1 && @test ta < 1.1*tb
Base.Threads.nthreads() > 1 && @test ta < tb
for i in 1:5
  @test a[i] ≈ b[i] rtol=sqrt(eps()) atol=0.0
end

itr = 1:10
a = Threadings.tmap(f, itr)
b = map(f, itr)
ta = @elapsed Threadings.tmap(f, itr)
tb = @elapsed map(f, itr)
@show ta, tb
Base.Threads.nthreads() == 1 && @test ta < 1.1*tb
Base.Threads.nthreads() > 1 && @test ta < tb
@test a ≈ b rtol=sqrt(eps()) atol=0.0
end
