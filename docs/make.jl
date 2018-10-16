using Documenter, Discord

makedocs(;
    modules=[Discord],
    format=:html,
    pages=[
        "Home" => "index.md",
        "Reference" => "reference.md",
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
    target="build",
    julia="1.0",
    deps=nothing,
    make=nothing,
)
