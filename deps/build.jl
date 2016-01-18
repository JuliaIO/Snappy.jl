using BinDeps
using Compat
@BinDeps.setup

snappy = library_dependency("libsnappy")

# BinDeps issue: fails on sudo prompt
#provides(AptGet, {
#    "libsnappy-dev" => snappy
#})

provides(Sources, URI("https://github.com/google/snappy/releases/download/1.1.3/snappy-1.1.3.tar.gz"), snappy, unpacked_dir="snappy-1.1.3")
provides(BuildProcess, Autotools(libtarget = Pkg.dir("Snappy") * "/deps/builds/libsnappy/.libs/libsnappy."*BinDeps.shlib_ext), snappy, os=:Unix)

@osx_only begin
    using Homebrew
    provides(Homebrew.HB, "snappy", snappy, os=:Darwin)
end

@compat @BinDeps.install Dict(:libsnappy => :libsnappy)
