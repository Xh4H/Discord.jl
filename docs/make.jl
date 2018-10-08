using Documenter, Julicord

makedocs(;
    modules=[Julicord],
    format=:html,
    pages=[
        "Home" => "index.md",
        "Reference" => "reference.md",
    ],
    repo="https://github.com/PurgePJ/Julicord/blob/{commit}{path}#L{line}",
    sitename="Julicord",
    authors="PurgePJ <sindur.esl@gmail.com>, christopher-dG <chrisadegraaf@gmail.com>",
    assets=[],
)

deploydocs(;
    repo="github.com/PurgePJ/Julicord",
    target="build",
    julia="1.0",
    deps=nothing,
    make=nothing,
)
