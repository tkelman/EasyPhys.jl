
import Base.@__doc__


"""
    number_of_arguments(method::Function)

Gives the number of arguments taken by `method`. Requires that
`method` is the only method belonging to its generic function.
"""
function number_of_arguments(method::Function)
    fmethods = methods(method).ms
    @assert length(fmethods) == 1

    length(first(fmethods).sig.parameters) - 1
end


"""
    argument_names(method::Function)

Gives the original names of all arguments taken by `method`. Requires
that `method` is the only method belonging to its generic function.
"""
function argument_names(method::Function)
    n_args = number_of_arguments(method)

    argtypes = repeat([Any]; outer=n_args)
    lowered_code = first(code_lowered(method, argtypes))
    @assert lowered_code.nargs - 1 == n_args

    lowered_code.slotnames[2:end]
end


"""
    @partially_applicable f(x, args...; kwargs...) = ()

    @partially_applicable function g(x, args...; kwargs...) end

Pretty hacky. When applied to a function definition `f` of a function with
more than one argument, defines two methods on the function: one equivalent
to that defined by `f`, and one that takes one fewer argument than `f`,
amounting to all but the first argument, and partially applies them,
returning the resulting single-parameter

# Examples

```jldoctest
julia> @partially_applicable f(x, a, b) = a*x + b
f (generic function with 2 methods)

julia> f(28, 38, 273) == 28 |> f(38, 273)
true

julia> @partially_applicable g(x; kwargs...) = (println(kwargs); x*5)
g (generic function with 2 methods)

julia> g(2, sortaneat=:yes) == 2 |> g(sortaneat=:yes)
Any[(:sortaneat,:yes)]
Any[(:sortaneat,:yes)]
true
```
"""
macro partially_applicable(func)
    func_original = copy(func)
    r = match(r"([^\(]+\()([^,;]+),?(.+)", string(func.args[1]))
    func.args[1] = [r.captures[1], r.captures[3]]                |> join |> parse
    func.args[2] = [r.captures[2], " -> ", string(func.args[2])] |> join |> parse
    quote
        @__doc__ $(esc(func_original))
                 $(esc(func))
    end
end
