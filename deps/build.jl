using BinDeps
@BinDeps.setup

snappy = library_dependency("libsnappy")

# BinDeps issue: fails on sudo prompt
#provides(AptGet, {
#    "libsnappy-dev" => snappy
#})

version = "1.1.6"
provides(Sources, URI("https://github.com/google/snappy/releases/download/$(version)/snappy-$(version).tar.gz"), snappy, unpacked_dir="snappy-$(version)")
provides(BuildProcess, Autotools(libtarget=dirname(@__FILE__) * "/builds/libsnappy/.libs/libsnappy." * Libdl.dlext), snappy, os=:Unix)

@static if is_apple()
    using Homebrew
    provides(Homebrew.HB, "snappy", snappy, os=:Darwin)
end

@BinDeps.install Dict(:libsnappy => :libsnappy)
