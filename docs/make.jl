
using Documenter
using PowerDynamics

makedocs(
    modules = [PowerDynamics],
    authors = "Tim Kittel and contributors.",
    linkcheck=false,
    sitename = "PowerDynamics.jl",
    pages = [
        "General" => "index.md",
        "language_conventions.md",
        "powergrid_model.md",
        "node_types.md",
        "custom_node_types.md",
        "line_types.md",
        "states_solutions.md",
        "simulations.md",
        "error_types.md",
        "import_export.md",
        "fullindex.md",
        "contact.md",
    ],
   format = Documenter.HTML(canonical = "https://juliaenergy.github.io/PowerDynamics.jl/stable/"),
   )
deploydocs(
    repo = "github.com/JuliaEnergy/PowerDynamics.jl.git",
    target = "build"
)
