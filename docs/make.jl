using Documenter, PlanerTransformer

const PAGES = [
  "Home" => "index.md",
  "Installation" => "install.md",
  "Introduction" => "introduction.md",
  "Design API" => "design_api.md",
  "Data Entry API" => "data_entry_api.md",
  "Internal API" => "internal_api.md",
  "API index" => "APIindex.md",
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
  fake_travis = "C:/Users/Chris/fake_travis_PlanerTransformer.jl"
  if isfile(fake_travis)
    include(fake_travis)
  end
  deploydocs(
    repo = "github.com/cstook/PlanerTransformer.jl.git",
    target = "site",
    branch = "gh-pages",
    latest = "master",
    osname = "linux",
    julia  = "0.7",
    deps = nothing,
    make = nothing,
  )
end
