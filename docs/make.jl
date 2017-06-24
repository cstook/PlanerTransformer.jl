using Documenter, PlanerTransformer

const PAGES = [
  "Home" => "index.md"
  "API" => "api.md"
]

makedocs(
  modules = [PlanerTransformer],
  doctest   = "doctest" in ARGS,
  linkcheck = "linkcheck" in ARGS,
  format    = "pdf" in ARGS ? :latex : :html,
  sitename = "PlanerTransformer",
  authors = "Chris Stook",
  pages = PAGES,
  html_prettyurls = true #("deploy" in ARGS),
)

if true #"deploy" in ARGS
  deploydocs(
    repo = "github.com/cstook/PlanerTransformer.jl.git",
    target = "site",
    branch = "gh-pages",
    latest = "master",
    osname = "linux",
    julia  = "0.6",
    deps = nothing,
    make = nothing,
  )
end
