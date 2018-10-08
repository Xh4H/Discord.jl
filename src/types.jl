# Discord's form of ID.
const Snowflake = Int64
# Discord sends strings, but it's easier to work with integers.
snowflake(s::AbstractString) = parse(Int64, s)

# Discord sends a trailing "Z". Maybe we actually need to think about time zones.
datetime(s::AbstractString) = DateTime(s[1:end-1], ISODateTimeFormat)

function field(k::String, t::Symbol)
    return if t === :Snowflake
        :(snowflake(d[$k]))
    elseif t === :DateTime
        :(datetime(d[$k]))
    elseif isprimitivetype(eval(t))
        :(d[$k])
    else
        :($t(d[$k]))
    end
end

function field(k::String, t::Expr)
    ex = if t.head === :curly
        if t.args[1] === :Vector && isa(t.args[2], Symbol)
            :($(t.args[2]).(d[$k]))
        elseif t.args[1] === :Union
            if :Nothing in t.args && :Missing in t.args
                :(haskey(d, $k) ? d[$k] === nothing ? nothing : $(field(k, t.args[2])) : missing)
            elseif t.args[3] === :Nothing
                :(d[$k] === nothing ? nothing : $(field(k, t.args[2])))
            elseif t.args[3] === :Missing
                :(haskey(d, $k) ? $(field(k, t.args[2])) : missing)
            end
        end
    end
    ex === nothing && error("uncaught case: k=$k, t=$t") || return ex
end

macro from_dict(ex)
    @assert ex.head === :struct
    name = isa(ex.args[2], Symbol) ? ex.args[2] : ex.args[2].args[1]
    args = map(
        e -> field(string(e.args[1]), e.args[2]),
        filter(e -> isa(e, Expr), ex.args[3].args),
    )

    quote
        $(esc(ex))
        Base.@__doc__ function $(esc(name))(d::Dict)
            return $(esc(name))($(args...))
        end
    end
end

include(joinpath("types", "user.jl"))
include(joinpath("types", "emoji.jl"))
include(joinpath("types", "role.jl"))
include(joinpath("types", "overwrite.jl"))
include(joinpath("types", "channel.jl"))
include(joinpath("types", "activity.jl"))
include(joinpath("types", "presence.jl"))
include(joinpath("types", "guild_member.jl"))
include(joinpath("types", "voice_state.jl"))
include(joinpath("types", "guild.jl"))

