"""
A [`Message`](@ref) attachment.
More details [here](https://discordapp.com/developers/docs/resources/channel#attachment-object).
"""
struct Attachment
    id::Snowflake
    filename::String
    size::Int
    url::String
    proxy_url::String
    height::Optional{Int}
    width::Optional{Int}
end
@boilerplate Attachment :constructors :docs :lower :merge :mock
