export list_guild_emojis,
        get_guild_emoji,
        create_guild_emoji,
        modify_guild_emoji,
        delete_guild_emoji

"""
    list_guild_emojis(c::Client, guild::Integer) -> Vector{Emoji}

Get the [`Emoji`](@ref)s in a [`Guild`](@ref).
"""
function list_guild_emojis(c::Client, guild::Integer)
    return Response{Vector{Emoji}}(c, :GET, "/guilds/$guild/emojis")
end

"""
    get_guild_emoji(c::Client, guild::Integer, emoji::Integer) -> Emoji

Get an [`Emoji`](@ref) in a [`Guild`](@ref).
"""
function get_guild_emoji(c::Client, guild::Integer, emoji::Integer)
    return Response{Emoji}(c, :GET, "/guilds/$guild/emojis/$emoji")
end

"""
    create_guild_emoji(c::Client, guild::Integer; kwargs...) -> Emoji

Create an [`Emoji`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/emoji#create-guild-emoji).
"""
function create_guild_emoji(c::Client, guild::Integer; kwargs...)
    return Response{Emoji}(c, :POST, "/guilds/$guild/emojis"; body=kwargs)
end

"""
    modify_guild_emoji(c::Client, guild::Integer, emoji::Integer; kwargs...) -> Emoji

Edit an [`Emoji`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/emoji#modify-guild-emoji).
"""
function modify_guild_emoji(c::Client, guild::Integer, emoji::Integer; kwargs...)
    return Response{Emoji}(c, :PATCH, "/guilds/$guild/emojis/$emoji"; body=kwargs)
end

"""
    delete_guild_emoji(c::Client, guild::Integer, emoji::Integer)

Delete an [`Emoji`](@ref) from a [`Guild`](@ref).
"""
function delete_guild_emoji(c::Client, guild::Integer, emoji::Integer)
    return Response(c, :DELETE, "/guilds/$guild/emojis/$emoji")
end
