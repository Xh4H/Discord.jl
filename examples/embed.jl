module Embed

using Discord

function embed(c::Client, m::Message)
    
    local e = Embed(
        
        color = 0x36393f,
        title = "Embed title",
        description="[Embed description](https://github.com/Xh4H/Discord.jl) $(string(m.author))",

        fields=[EmbedField(
                    name="Field name 1", value="Field value 1", inline=true),
                EmbedField(
                    name="Field name 2", value="Field value 2", inline=false),
                EmbedField(
                    name="Field name 3", value="Field value 3"),
                EmbedField(
                    name="Field name 4", value="[Field value 4](https://github.com/Xh4H/Discord.jl)")
                ],
        
        author=EmbedAuthor(
            name="Embed author",
            icon_url="https://cdn.discordapp.com/embed/avatars/0.png"),

        thumbnail=EmbedThumbnail(
            url="https://cdn.discordapp.com/embed/avatars/0.png"),
        
        image=EmbedImage(
            url="https://cdn.discordapp.com/embed/avatars/0.png"),
        
        footer=EmbedFooter(
            text="Embed footer",
            icon_url="https://cdn.discordapp.com/embed/avatars/0.png"
    ))
    
    reply(c, m, e)
end


@command(
    name=:embed,
    handler=embed,
    help="Simple embed",
);
end