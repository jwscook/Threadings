using Threadings, Base.Test
@testset "Threadings tests" begin
function f(x)
  # this bit takes about 10 seconds
  local a = 0.0
  for i in 1:10
    a += sum(cbrt.(sqrt.(rand(100_000))))
  end
  return x + 0 * a
end
itr = [i*collect(rand(5)) for i in 1:10]
a = Threadings.tmapreduce(f, +, zeros(5), itr)
b = mapreduce(f, +, zeros(5), itr)
ta = @elapsed Threadings.tmapreduce(f, +, zeros(5), itr)
tb = @elapsed mapreduce(f, +, zeros(5), itr)
@show ta, tb
@test ta < tb
for i in 1:5
  @test a[i] ≈ b[i] rtol=sqrt(eps()) atol=0.0
end

itr = 1:10
a = Threadings.tmap(f, itr)
b = map(f, itr)
ta = @elapsed Threadings.tmap(f, itr)
tb = @elapsed map(f, itr)
@show ta, tb
@test ta < tb
@test a ≈ b rtol=sqrt(eps()) atol=0.0
end
