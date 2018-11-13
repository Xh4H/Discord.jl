"""
An [`Embed`](@ref)'s thumbnail image information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-thumbnail-structure).
"""
struct EmbedThumbnail
    url::Union{String, Missing}
    proxy_url::Union{String, Missing}
    height::Union{Int, Missing}
    width::Union{Int, Missing}
end
@boilerplate EmbedThumbnail :constructors :docs :lower :merge

"""
An [`Embed`](@ref)'s video information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-video-structure).
"""
struct EmbedVideo
    url::Union{String, Missing}
    height::Union{Int, Missing}
    width::Union{Int, Missing}
end
@boilerplate EmbedVideo :constructors :docs :lower :merge

"""
An [`Embed`](@ref)'s image information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-image-structure).
"""
struct EmbedImage
    url::Union{String, Missing}
    proxy_url::Union{String, Missing}
    height::Union{Int, Missing}
    width::Union{Int, Missing}
end
@boilerplate EmbedImage :constructors :docs :lower :merge

"""
An [`Embed`](@ref)'s provider information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-provider-structure).
"""
struct EmbedProvider
    name::Union{String, Missing}
    url::Union{String, Nothing, Missing}  # Not supposed to be nullable.
end
@boilerplate EmbedProvider :constructors :docs :lower :merge

"""
An [`Embed`](@ref)'s author information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-author-structure).
"""
struct EmbedAuthor
    name::Union{String, Missing}
    url::Union{String, Missing}
    icon_url::Union{String, Missing}
    proxy_icon_url::Union{String, Missing}
end
@boilerplate EmbedAuthor :constructors :docs :lower :merge

"""
An [`Embed`](@ref)'s footer information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-footer-structure).
"""
struct EmbedFooter
    text::String
    icon_url::Union{String, Missing}
    proxy_icon_url::Union{String, Missing}
end
@boilerplate EmbedFooter :constructors :docs :lower :merge

"""
An [`Embed`](@ref) field.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-field-structure).
"""
struct EmbedField
    name::String
    value::String
    inline::Union{Bool, Missing}
end
@boilerplate EmbedField :constructors :docs :lower :merge

"""
A [`Message`](@ref) embed.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object).
"""
struct Embed
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
@boilerplate Embed :constructors :docs :lower :merge
