push!(LOAD_PATH,"../src/")
using Documenter, ImageComponentAnalysis
makedocs(sitename="Documentation",
            Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"))
deploydocs(repo = "github.com/zygmuntszpak/ImageComponentAnalysis.jl.git")
