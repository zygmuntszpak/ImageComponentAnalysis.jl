using ImageComponentAnalysis
using Documenter

DocMeta.setdocmeta!(ImageComponentAnalysis, :DocTestSetup, :(using ImageComponentAnalysis); recursive=true)

makedocs(;
    modules=[ImageComponentAnalysis],
    authors="Zygmunt Szpak",
    repo="https://github.com/zygmuntszpak/ImageComponentAnalysis.jl/blob/{commit}{path}#{line}",
    sitename="ImageComponentAnalysis.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://zygmuntszpak.github.io/ImageComponentAnalysis.jl/stable/",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Function Reference" => "reference.md"
    ],
)

deploydocs(;
    repo="github.com/zygmuntszpak/ImageComponentAnalysis.jl.git",
)