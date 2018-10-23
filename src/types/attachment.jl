"""
A [`Message`](@ref) attachment.
More details [here](https://discordapp.com/developers/docs/resources/channel#attachment-object).
"""
@from_dict struct Attachment
    id::Snowflake
    filename::String
    size::Int
    url::String
    proxy_url::String
    height::Union{Int, Missing}
    width::Union{Int, Missing}
end
