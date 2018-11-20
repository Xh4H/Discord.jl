export OT_ROLE,
    OT_MEMBER,
    Overwrite

const OVERWRITE_TYPES = ["role", "member"]

"""
An [`Overwrite`](@ref)'s type.
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-optional-audit-entry-info).
"""
@enum OverwriteType OT_ROLE OT_MEMBER OT_UNKNOWN

function OverwriteType(x::AbstractString)
    i = findfirst(isequal(x), OVERWRITE_TYPES)
    return i === nothing ? OT_UNKNOWN : OverwriteType(i - 1)
end

Base.string(x::OverwriteType) = x === OT_UNKNOWN ? "" : OVERWRITE_TYPES[Int(x) + 1]
JSON.lower(x::OverwriteType) = string(x)

"""
A permission overwrite.
More details [here](https://discordapp.com/developers/docs/resources/channel#overwrite-object).
"""
struct Overwrite
    id::Snowflake
    type::OverwriteType
    allow::Int
    deny::Int
end
@boilerplate Overwrite :constructors :docs :lower :merge :mock
