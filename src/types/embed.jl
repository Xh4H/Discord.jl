@from_dict struct EmbedThumbnail
    url::Union{String, Missing}
    proxy_url::Union{String, Missing}
    height::Union{Int, Missing}
    width::Union{Int, Missing}
end

@from_dict struct EmbedVideo
    url::Union{String, Missing}
    height::Union{Int, Missing}
    width::Union{Int, Missing}
end

@from_dict struct EmbedImage
    url::Union{String, Missing}
    proxy_url::Union{String, Missing}
    height::Union{Int, Missing}
    width::Union{Int, Missing}
end

@from_dict struct EmbedProvider
    name::Union{String, Missing}
    url::Union{String, Missing}
end

@from_dict struct EmbedAuthor
    name::Union{String, Missing}
    url::Union{String, Missing}
    icon_url::Union{String, Missing}
    proxy_icon_url::Union{String, Missing}
end

@from_dict struct EmbedFooter
    text::String
    icon_url::Union{String, Missing}
    proxy_icon_url::Union{String, Missing}
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
    title::Union{String, Missing}
    type::Union{String, Missing}
    description::Union{String, Missing}
    url::Union{String, Missing}
    timestamp::Union{DateTime, Missing}
    color::Union{Int, Missing}
    footer::Union{EmbedFooter, Missing}
    image::Union{EmbedImage, Missing}
    thumbnail::Union{EmbedThumbnail, Missing}
    video::Union{EmbedVideo, Missing}
    provider::Union{EmbedProvider, Missing}
    author::Union{EmbedAuthor, Missing}
    fields::Union{Vector{EmbedField}, Missing}
end
