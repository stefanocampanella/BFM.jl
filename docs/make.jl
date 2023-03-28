using BFM
using Documenter

DocMeta.setdocmeta!(BFM, :DocTestSetup, :(using BFM); recursive=true)

makedocs(;
    modules=[BFM],
    authors="Stefano Campanella <15182642+stefanocampanella@users.noreply.github.com> and contributors",
    repo="https://github.com/stefanocampanella/BFM.jl/blob/{commit}{path}#{line}",
    sitename="BFM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://stefanocampanella.github.io/BFM.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/stefanocampanella/BFM.jl",
    devbranch="master",
)
