export list_guild_emojis,
    get_guild_emoji,
    create_guild_emoji,
    modify_guild_emoji,
    delete_guild_emoji

"""
    list_guild_emojis(c::Client, guild::Integer) -> Vector{Emoji}

Get the [`Emoji`](@ref)s in a [`Guild`](@ref).
"""
list_guild_emojis(c::Client, guild::Integer) = Response{Vector{Emoji}}(c, :GET, "/guilds/$guild/emojis")

"""
    get_guild_emoji(c::Client, guild::Integer, emoji::Integer) -> Emoji

Get an [`Emoji`](@ref) in a [`Guild`](@ref).
"""
get_guild_emoji(c::Client, guild::Integer, emoji::Integer) = Response{Emoji}(c, :GET, "/guilds/$guild/emojis/$emoji")

"""
    create_guild_emoji(c::Client, guild::Integer; kwargs...) -> Emoji

Create an [`Emoji`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/emoji#create-guild-emoji).
"""
create_guild_emoji(c::Client, guild::Integer; kwargs...) = Response{Emoji}(c, :POST, "/guilds/$guild/emojis"; body = kwargs)

"""
    modify_guild_emoji(c::Client, guild::Integer, emoji::Integer; kwargs...) -> Emoji

Edit an [`Emoji`](@ref) in a [`Guild`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/emoji#modify-guild-emoji).
"""
modify_guild_emoji(c::Client, guild::Integer, emoji::Integer; kwargs...) = Response{Emoji}(c, :PATCH, "/guilds/$guild/emojis/$emoji"; body = kwargs)

"""
    delete_guild_emoji(c::Client, guild::Integer, emoji::Integer)

Delete an [`Emoji`](@ref) from a [`Guild`](@ref).
"""
delete_guild_emoji(c::Client, guild::Integer, emoji::Integer) = Response(c, :DELETE, "/guilds/$guild/emojis/$emoji")
