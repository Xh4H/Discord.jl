# First millisecond of 2015.
const DISCORD_EPOCH = 1420070400000

# Discord's form of ID.
const Snowflake = UInt64

snowflake(s::Integer) = Snowflake(s)
snowflake(s::AbstractString) = parse(UInt64, s)

snowflake2datetime(s::Snowflake) = unix2datetime(((s >> 22) + DISCORD_EPOCH) / 1000)
worker_id(s::Snowflake) = (s & 0x3E0000) >> 17
process_id(s::Snowflake) = (s & 0x1F000) >> 12
increment(s::Snowflake) = s & 0xFFF

# Discord sends both Unix and ISO timestamps.
datetime(s::Integer) = unix2datetime(s / 1000)
datetime(s::AbstractString) = DateTime(replace(s, "+" => ".000+")[1:23], ISODateTimeFormat)

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
    if supertype(eval(T)) <: Enum{<:Integer}
        quote
            JSON.lower(x::$T) = Int(x)
        end
    else
        quote
            function JSON.lower(x::$T)
                d = Dict()
                for f in fieldnames($T)
                    v = getfield(x, f)
                    if !ismissing(v)
                        d[string(f)] = lowered(v)
                    end
                end
                return d
            end
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
                push!(vals, ismissing(vb) ? va : vb)
            end
            return $T(vals...)
        end
    end
end

field(k::String, ::Type{Any}) = :(d[$k])
field(k::String, ::Type{Snowflake}) = :(snowflake(d[$k]))
field(k::String, ::Type{DateTime}) = :(datetime(d[$k]))
field(k::String, ::Type{T}) where T = :($T(d[$k]))
field(k::String, ::Type{Vector{Snowflake}}) = :(snowflake.(d[$k]))
field(k::String, ::Type{Vector{DateTime}}) = :(datetime.(d[$k]))
field(k::String, ::Type{Vector{T}}) where T = :($T.(d[$k]))
function field(k::String, ::Type{Union{T, Missing}}) where T
    return :(haskey(d, $k) ? $(field(k, T)) : missing)
end
function field(k::String, ::Type{Union{T, Nothing}}) where T
    return :(d[$k] === nothing ? nothing : $(field(k, T)))
end
function field(k::String, ::Type{Union{T, Nothing, Missing}}) where T
    return :(haskey(d, $k) ? $(field(k, Union{T, Nothing})) : missing)
end

macro dict(T)
    TT = eval(T)
    args = map(f -> field(string(f), fieldtype(TT, f)), fieldnames(TT))
    quote
        function $(esc(T))(d::Dict{String, Any})
            $(esc(T))($(args...))
        end
    end
end

macro boilerplate(T, exs...)
    macros = map(e -> e.value, exs)
    quote
        :dict in $macros && @dict $T
        :lower in $macros && @lower $T
        :merge in $macros && @merge $T
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
