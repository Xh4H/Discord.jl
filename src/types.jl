function field(k::String, t::Symbol)
    return if t === :String
        :(data[$k])
    elseif t === :DateTime
        :(datetime(data[$k]))
    elseif t === :Snowflake
        :(snowflake(data[$k]))
    else
        :($t(data[$k]))
    end
end

function field(k::String, t::Expr)
    if t.head === :curly
        if t.args[1] === :Vector && isa(t.args[2], Symbol)
            vector(k, t.args[2])
        elseif t.args[1] === :Union
            maybe(k, t.args[2:end])
        else
            error("uncaught case: k=$k, t=$t")
        end
    else
        error("uncaught case: k=$k, t=$t")
    end
end

vector(k::String, t::Symbol) = :($t.(data[$k]))

nullable(k::String, t::Symbol) = :(data[$k] === nothing ? nothing : field($k, Symbol($t)))
optional(k::String, t::Symbol) = :(haskey(data, $k) ? field($k, Symbol($t)) : missing)


function maybe(k::String, t::Vector)
    @assert length(t) == 2
    return if t[2] === :Nothing
        nullable(k, t[1])
    elseif t[2] === :Missing
        optional(k, t[1])
    else
        error("uncaught case: k=$k, t=$t")
    end
end

macro from_dict(ex)
    @assert ex.head === :struct
    name = ex.args[2]
    args = map(
        e -> field(string(e.args[1]), e.args[2]),
        filter(e -> isa(e, Expr), ex.args[3].args),
    )

    quote
        $ex
        Base.@__doc__ function $(esc(name))(data::Dict)
            return $name($(args...))
        end
    end
end

include(joinpath("types", "user.jl"))
