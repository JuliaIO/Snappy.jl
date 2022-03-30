using Clang.Generators
using snappy_jll

cd(@__DIR__)

include_dir = normpath(snappy_jll.artifact_dir, "include")

opts = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

headers = filter(file -> endswith(file, ".h"), readdir(include_dir, join=true))

ctx = create_context(headers, args, opts)

build!(ctx)
