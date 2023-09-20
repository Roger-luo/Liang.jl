using Documenter
using Liang
using DocThemeIndigo

indigo = DocThemeIndigo.install(Configurations)

makedocs(;
    modules = [Liang],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical="https://Roger-luo.github.io/Liang.jl",
        assets=String[indigo],
    ),
    pages = [
        "Home" => "index.md",
    ],
    repo = "https://github.com/Roger-luo/Liang.jl",
    sitename = "Liang.jl",
)

deploydocs(; repo = "https://github.com/Roger-luo/Liang.jl")
