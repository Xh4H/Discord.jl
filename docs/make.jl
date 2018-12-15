using Documenter
using Discord

makedocs(;
    modules=[Discord],
    format=Documenter.HTML(),
    pages=[
        "Home"     => "index.md",
        "Client"   => "client.md",
        "Events"   => "events.md",
        "REST API" => "rest.md",
        "Helpers"  => "helpers.md",
        "Types"    => "types.md",
        "Tutorial" => "tutorial.md",
    ],
    repo="https://github.com/PurgePJ/Discord.jl/blob/{commit}{path}#L{line}",
    sitename="Discord.jl",
    authors="PurgePJ <sindur.esl@gmail.com>, christopher-dG <chrisadegraaf@gmail.com>",
    assets=[
        "assets/logo.png",
    ],
)

deploydocs(;
    repo="github.com/PurgePJ/Discord.jl",
)
