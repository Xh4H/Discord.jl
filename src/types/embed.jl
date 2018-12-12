export EmbedThumbnail,
    EmbedVideo,
    EmbedImage,
    EmbedProvider,
    EmbedAuthor,
    EmbedFooter,
    EmbedField,
    Embed

"""
An [`Embed`](@ref)'s thumbnail image information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-thumbnail-structure).
"""
struct EmbedThumbnail
    url::Optional{String}
    proxy_url::Optional{String}
    height::Optional{Int}
    width::Optional{Int}
end
@boilerplate EmbedThumbnail :constructors :docs :lower :merge :mock

"""
An [`Embed`](@ref)'s video information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-video-structure).
"""
struct EmbedVideo
    url::Optional{String}
    height::Optional{Int}
    width::Optional{Int}
end
@boilerplate EmbedVideo :constructors :docs :lower :merge :mock

"""
An [`Embed`](@ref)'s image information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-image-structure).
"""
struct EmbedImage
    url::Optional{String}
    proxy_url::Optional{String}
    height::Optional{Int}
    width::Optional{Int}
end
@boilerplate EmbedImage :constructors :docs :lower :merge :mock

"""
An [`Embed`](@ref)'s provider information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-provider-structure).
"""
struct EmbedProvider
    name::Optional{String}
    url::Union{String, Nothing, Missing}  # Not supposed to be nullable.
end
@boilerplate EmbedProvider :constructors :docs :lower :merge :mock

"""
An [`Embed`](@ref)'s author information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-author-structure).
"""
struct EmbedAuthor
    name::Optional{String}
    url::Optional{String}
    icon_url::Optional{String}
    proxy_icon_url::Optional{String}
end
@boilerplate EmbedAuthor :constructors :docs :lower :merge :mock

"""
An [`Embed`](@ref)'s footer information.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-footer-structure).
"""
struct EmbedFooter
    text::String
    icon_url::Optional{String}
    proxy_icon_url::Optional{String}
end
@boilerplate EmbedFooter :constructors :docs :lower :merge :mock

"""
An [`Embed`](@ref) field.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object-embed-field-structure).
"""
struct EmbedField
    name::String
    value::String
    inline::Optional{Bool}
end
@boilerplate EmbedField :constructors :docs :lower :merge :mock

"""
A [`Message`](@ref) embed.
More details [here](https://discordapp.com/developers/docs/resources/channel#embed-object).
"""
struct Embed
    title::Optional{String}
    type::Optional{String}
    description::Optional{String}
    url::Optional{String}
    timestamp::Optional{DateTime}
    color::Optional{Int}
    footer::Optional{EmbedFooter}
    image::Optional{EmbedImage}
    thumbnail::Optional{EmbedThumbnail}
    video::Optional{EmbedVideo}
    provider::Optional{EmbedProvider}
    author::Optional{EmbedAuthor}
    fields::Optional{Vector{EmbedField}}
end
@boilerplate Embed :constructors :docs :lower :merge :mock
