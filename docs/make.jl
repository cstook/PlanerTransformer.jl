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
  build = "site",
  sitename = "PlanerTransformer",
  authors = "Chris Stook",
  pages = PAGES,
  html_prettyurls = "deploy" in ARGS,
)

if "deploy" in ARGS
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
