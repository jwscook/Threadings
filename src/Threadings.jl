module Threadings
using Base.Threads
export tmapreduce, tmap!, tmap

function tmapreduce(f::T, op, itr; init=nothing) where {T<:Function}
  @assert length(itr) > 0
  spinlock = SpinLock()
  popable_itr = Vector(deepcopy(itr)) # vector is poppable
  output = deepcopy(init) # make a deepcopy of starting value
  if output == nothing
    output = f(pop!(popable_itr))
  end
  # array of input arguments to f, to store input for each thread
  inputs = Vector{typeof(itr[1])}(undef, nthreads()) # deprecated soon?
  @threads for i ∈ eachindex(itr)
    lock(spinlock)
    inputs[threadid()] = pop!(popable_itr)
    unlock(spinlock)
    loop_output = f(inputs[threadid()])
    lock(spinlock)
    output = op(output, loop_output)
    unlock(spinlock)
  end
  return output
end
# changes only output in-place
function tmap!(f::T, itr, output::U) where {T<:Function, U<:AbstractVector}
  @assert length(itr) == length(output)
  @assert !isempty(itr)
  spinlock = SpinLock()
  all_indices = Vector{Int}(1:length(itr))
  thread_index = Vector{Int}(undef, nthreads())
  @threads for i ∈ eachindex(itr)
    lock(spinlock)
    thread_index[threadid()] = pop!(all_indices)
    unlock(spinlock)
    thread_output = f(itr[thread_index[threadid()]])
    lock(spinlock)
    output[thread_index[threadid()]] = thread_output
    unlock(spinlock)
  end
  return nothing
end
function tmap(f::T, itr, output_type::Type=Any) where {T<:Function}
  output = Vector{output_type}(undef, length(itr))
  tmap!(f, itr, output)
  return output
end

end # Threadings
