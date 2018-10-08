@from_dict struct EmbedThumbnail
    url::Union{String, Nothing}
    proxy_url::Union{String, Nothing}
    height::Union{Int, Nothing}
    width::Union{Int, Nothing}
end

@from_dict struct EmbedVideo
    url::Union{String, Nothing}
    height::Union{Int, Nothing}
    width::Union{Int, Nothing}
end

@from_dict struct EmbedImage
    url::Union{String, Nothing}
    proxy_url::Union{String, Nothing}
    height::Union{Int, Nothing}
    width::Union{Int, Nothing}
end

@from_dict struct EmbedProvider
    name::Union{String, Nothing}
    url::Union{String, Nothing}
end

@from_dict struct EmbedAuthor
    name::Union{String, Nothing}
    url::Union{String, Nothing}
    icon_url::Union{String, Nothing}
    proxy_icon_url::Union{String, Nothing}
end

@from_dict struct EmbedFooter
    text::String
    icon_url::Union{String, Nothing}
    proxy_icon_url::Union{String, Nothing}
end

@from_dict struct EmbedField
    name::String
    value::String
    inline::Union{Bool, Nothing}
end

"""
A message embed.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object).
"""
@from_dict struct Embed
    title::Union{String, Nothing}
    type::Union{String, Nothing}
    description::Union{String, Nothing}
    url::Union{String, Nothing}
    timestamp::Union{DateTime, Nothing}
    color::Union{Int, Nothing}
    footer::Union{EmbedFooter, Nothing}
    image::Union{EmbedImage, Nothing}
    thumbnail::Union{EmbedThumbnail, Nothing}
    video::Union{EmbedVideo, Nothing}
    provider::Union{EmbedProvider, Nothing}
    author::Union{EmbedAuthor, Nothing}
    fields::Union{Vector{EmbedField}, Nothing}
end
