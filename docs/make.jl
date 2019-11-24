push!(LOAD_PATH,"../src/")
using Documenter, ImageComponentAnalysis
makedocs(sitename="Documentation",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    pages = [
        "Home" => "index.md",
        "Function Reference" => "reference.md"
    ]
)
deploydocs(repo = "github.com/zygmuntszpak/ImageComponentAnalysis.jl.git")
