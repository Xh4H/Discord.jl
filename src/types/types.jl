# First millisecond of 2015.
const DISCORD_EPOCH = 1420070400000

# Discord's form of ID.
const Snowflake = UInt64

snowflake(s::Integer) = Snowflake(s)
snowflake(s::AbstractString) = parse(Snowflake, s)

# TODO: Put these in helpers?
snowflake2datetime(s::Snowflake) = unix2datetime(((s >> 22) + DISCORD_EPOCH) / 1000)
worker_id(s::Snowflake) = (s & 0x3e0000) >> 17
process_id(s::Snowflake) = (s & 0x1f000) >> 12
increment(s::Snowflake) = s & 0xfff

# Discord sends both Unix and ISO timestamps.
datetime(s::Int) = unix2datetime(s / 1000)
datetime(s::AbstractString) = DateTime(replace(s, "+" => ".000+")[1:23], ISODateTimeFormat)
datetime(d::DateTime) = d

# Lower to something JSON-compatible.
lowered(x::DateTime) = round(Int, datetime2unix(x))
lowered(x::Union{Integer, Bool}) = x
lowered(x::Vector) = lowered.(x)
lowered(x::Nothing) = nothing
lowered(x) = JSON.lower(x)

# Define JSON.lower for a type.
macro lower(T)
    if supertype(eval(T)) <: Enum{<:Integer}
        quote
            JSON.lower(x::$T) = Int(x)
        end
    else
        quote
            function JSON.lower(x::$T)
                d = Dict{Symbol, Any}()

                for f in fieldnames($T)
                    v = getfield(x, f)
                    if !ismissing(v)
                        d[f] = lowered(v)
                    end
                end

                return d
            end
        end
    end
end

# Define Base.merge for a type.
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
        Base.merge(::Missing, x::$T) = x
        Base.merge(x::$T, ::Missing) = x
    end
end

# Compute the expression needed to extract field k from keywords.
field(k::QuoteNode, ::Type{Any}) = :(kwargs[$k])
field(k::QuoteNode, ::Type{Snowflake}) = :(snowflake(kwargs[$k]))
field(k::QuoteNode, ::Type{DateTime}) = :(datetime(kwargs[$k]))
field(k::QuoteNode, ::Type{T}) where T = :($T(kwargs[$k]))
field(k::QuoteNode, ::Type{Vector{Snowflake}}) = :(snowflake.(kwargs[$k]))
field(k::QuoteNode, ::Type{Vector{DateTime}}) = :(datetime.(kwargs[$k]))
field(k::QuoteNode, ::Type{Vector{T}}) where T = :($T.(kwargs[$k]))
function field(k::QuoteNode, ::Type{T}) where T <: Enum
    return :(kwargs[$k] isa Integer ? $T(Int(kwargs[$k])) :
             kwargs[$k] isa $T ? kwargs[$k] : $T(kwargs[$k]))
end
function field(k::QuoteNode, ::Type{Optional{T}}) where T
    return :(haskey(kwargs, $k) ? $(field(k, T)) : missing)
end
function field(k::QuoteNode, ::Type{Nullable{T}}) where T
    return :(kwargs[$k] === nothing ? nothing : $(field(k, T)))
end
function field(k::QuoteNode, ::Type{Union{T, Nothing, Missing}}) where T
    return :(haskey(kwargs, $k) ? $(field(k, Nullable{T})) : missing)
end

# Define constructors from keyword arguments and a Dict for a type.
macro constructors(T)
    TT = eval(T)
    args = map(f -> field(QuoteNode(f), fieldtype(TT, f)), fieldnames(TT))

    quote
        $(esc(T))(; kwargs...) = $(esc(T))($(args...))
        $(esc(T))(d::Dict{Symbol, Any}) = $(esc(T))(; d...)
        $(esc(T))(x::$(esc(T))) = x
    end
end

# Export all instances of an enum.
macro exportenum(T)
    TT = eval(T)
    quote
        $(map(x -> :(export $(Symbol(x))), instances(TT))...)
    end
end

# Format a type for a docstring.
function doctype(s::String)
    s = replace(s, "UInt64" => "Snowflake")
    s = replace(s, string(Int) => "Int")
    s = replace(s, "Discord." => "")
    s = replace(s, "Dates." => "")
    m = match(r"Array{([^{}]+),1}", s)
    m === nothing || (s = replace(s, m.match => "Vector{$(m.captures[1])}"))
    m = match(r"Union{Missing, Nothing, (.+)}", s)
    m === nothing || return replace(s, m.match => "OptionalNullable{$(m.captures[1])}")
    m = match(r"Union{Missing, (.+)}", s)
    m === nothing || return replace(s, m.match => "Optional{$(m.captures[1])}")
    m = match(r"Union{Nothing, (.+)}", s)
    m === nothing || return replace(s, m.match => "Nullable{$(m.captures[1])}")
    return s
end

# Update a type's docstring with field names and types.
macro fielddoc(T)
    TT = eval(T)
    fields = filter(n -> !startswith(string(n), "djl_"), collect(fieldnames(TT)))
    ns = collect(string.(fields))
    width = maximum(length, ns)
    map!(n -> rpad(n, width), ns, ns)
    ts = collect(map(f -> string(fieldtype(TT, f)), fields))
    map!(doctype, ts, ts)
    docs = join(map(t -> "$(t[1]) :: $(t[2])", zip(ns, ts)), "\n")

    quote
        doc = string(@doc $T)
        docstring = doc * "\n## Fields\n\n```\n" * $docs * "\n```\n"

        Base.CoreLogging.with_logger(Base.CoreLogging.NullLogger()) do
            @doc docstring $T
        end
    end
end

# Produce a random string.
randstring() = String(filter(!ispunct, map(i -> Char(rand(48:122)), 1:rand(1:20))))

# Produce a randomized value of a type.
mock(::Type{Bool}; kwargs...) = rand(Bool)
mock(::Type{DateTime}; kwargs...) = now()
mock(::Type{AbstractString}; kwargs...) = randstring()
mock(::Type{Dict{Symbol, Any}}; kwargs...) = Dict(:a => mock(String), :b => mock(Int))
mock(::Type{T}; kwargs...) where T <: AbstractString = T(randstring())
mock(::Type{T}; kwargs...) where T <: Integer = abs(rand(T))
mock(::Type{T}; kwargs...) where T <: Enum = instances(T)[rand(1:length(instances(T)))]
mock(::Type{Vector{T}}; kwargs...) where T = map(i -> mock(T; kwargs...), 1:rand(1:10))
mock(::Type{Set{T}}; kwargs...) where T = Set(map(i -> mock(T; kwargs...), 1:rand(1:10)))
mock(::Type{Optional{T}}; kwargs...) where T = mock(T; kwargs...)
mock(::Type{Nullable{T}}; kwargs...) where T = mock(T; kwargs...)
mock(::Type{OptionalNullable{T}}; kwargs...) where T = mock(T; kwargs...)

# Define a mock method for a type.
macro mock(T)
    quote
        function $(esc(:mock))(::Type{$T}; kwargs...)
            names = fieldnames($(esc(T)))
            types = map(TT -> fieldtype($(esc(T)), TT), names)
            args = Vector{Any}(undef, length(names))
            for (i, (n, t)) in enumerate(zip(names, types))
                args[i] = haskey(kwargs, n) ? kwargs[n] : mock(t; kwargs...)
            end
            return $(esc(T))(args...)
        end
    end
end

# Apply the above macros to a type.
macro boilerplate(T, exs...)
    macros = map(e -> e.value, exs)

    quote
        @static if :constructors in $macros
            @constructors $T
        end
        @static if :docs in $macros
            @fielddoc $T
        end
        @static if :export in $macros
            @exportenum $T
        end
        @static if :lower in $macros
            @lower $T
        end
        @static if :merge in $macros
            @merge $T
        end
        @static if :mock in $macros
            @mock $T
        end
    end
end

include("overwrite.jl")
include("role.jl")
include("guild_embed.jl")
include("attachment.jl")
include("voice_region.jl")
include("activity.jl")
include("embed.jl")
include("user.jl")
include("ban.jl")
include("integration.jl")
include("connection.jl")
include("emoji.jl")
include("reaction.jl")
include("presence.jl")
include("channel.jl")
include("webhook.jl")
include("invite_metadata.jl")
include("member.jl")
include("voice_state.jl")
include("message.jl")
include("guild.jl")
include("invite.jl")
include("audit_log.jl")
