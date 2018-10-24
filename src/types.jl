# First millisecond of 2015.
const DISCORD_EPOCH = 1420070400000
# Discord's form of ID.
const Snowflake = UInt64
# Discord sends strings, but it's easier to work with integers.
snowflake(s::AbstractString) = parse(UInt64, s)
# Actually, we sometimes get them as integers.
snowflake(s::Integer) = Snowflake(s)
# Extract the DateTime from a Snowflake.
snowflake2datetime(s::Snowflake) = unix2datetime(((s >> 22) + DISCORD_EPOCH) / 1000)
# Extract the worker ID from a Snowflake.
worker_id(s::Snowflake) = (s & 0x3E0000) >> 17
# Extract the process ID from a Snowflake.
process_id(s::Snowflake) = (s & 0x1F000) >> 12
# Extract the increment from a Snowflake.
increment(s::Snowflake) = s & 0xFFF

# Discord sends some trailing timezone stuff. Maybe we need to think about time zones.
datetime(s::AbstractString) = DateTime(replace(s, "+" => ".000+")[1:23], ISODateTimeFormat)

function field(k::String, t::Symbol)
    return if t === :Snowflake
        :(snowflake(d[$k]))
    elseif t === :DateTime
        :(datetime(d[$k]))
    elseif t === :Any
        :(d[$k])
    else
        :($t(d[$k]))
    end
end

function field(k::String, t::Expr)
    ex = if t.head === :curly
        if t.args[1] === :Vector && isa(t.args[2], Symbol)
            t.args[2] === :Snowflake ? :(snowflake.(d[$k])) : :($(t.args[2]).(d[$k]))
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

function extra_fields(t::Type, d::Dict{String, Any})
    fields = string.(fieldnames(t))
    return filter(p -> !in(p.first, fields), d)
end

function lowered(x)
    return if x === nothing
        nothing
    elseif x isa Integer || x isa Bool
        x
    elseif x isa DateTime
        round(Int, datetime2unix(x))
    elseif x isa Vector
        lowered.(x)
    else
        JSON.lower(x)
    end
end

macro lower(T)
    quote
        function JSON.lower(x::$T)
            d = Dict()
            for f in fieldnames($T)
                f === :extra_fields && continue
                v = getfield(x, f)
                if !ismissing(v)
                    d[string(f)] = lowered(v)
                end
            end
            return d
        end
    end
end

macro merge(T)
    quote
        function Base.merge(a::$T, b::$T)
            vals = []
            for f in fieldnames($T)
                va = getfield(a, f)
                vb = getfield(b, f)
                push!(vals, ismissing(va) || va != vb ? vb : va)
            end
            return $T(vals...)
        end
    end
end

macro from_dict(ex)
    name = isa(ex.args[2], Symbol) ? ex.args[2] : ex.args[2].args[1]
    args = map(
        e -> field(string(e.args[1]), e.args[2]),
        filter(e -> isa(e, Expr), ex.args[3].args),
    )
    push!(ex.args[3].args, :(extra_fields::Dict{String, Any}))

    quote
        Base.@__doc__ $(esc(ex))

        function $(esc(name))(d::Dict{String, Any})
            extras = extra_fields($(esc(name)), d)
            return $(esc(name))($(args...), extras)
        end

        @lower $(esc(name))
        @merge $(esc(name))
    end
end

include(joinpath("types", "overwrite.jl"))
include(joinpath("types", "role.jl"))
include(joinpath("types", "guild_embed.jl"))
include(joinpath("types", "attachment.jl"))
include(joinpath("types", "voice_region.jl"))
include(joinpath("types", "activity.jl"))
include(joinpath("types", "embed.jl"))
include(joinpath("types", "user.jl"))
include(joinpath("types", "ban.jl"))
include(joinpath("types", "integration.jl"))
include(joinpath("types", "connection.jl"))
include(joinpath("types", "emoji.jl"))
include(joinpath("types", "reaction.jl"))
include(joinpath("types", "presence.jl"))
include(joinpath("types", "channel.jl"))
include(joinpath("types", "webhook.jl"))
include(joinpath("types", "invite_metadata.jl"))
include(joinpath("types", "member.jl"))
include(joinpath("types", "voice_state.jl"))
include(joinpath("types", "message.jl"))
include(joinpath("types", "guild.jl"))
include(joinpath("types", "invite.jl"))
include(joinpath("types", "audit_log.jl"))
