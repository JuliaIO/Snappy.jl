using BinaryProvider

const prefix = Prefix(joinpath(@__DIR__,"usr"))

const platform = platform_key()

libsnappy = LibraryProduct(prefix, "libsnappy")

const bin_prefix="https://github.com/davidanthoff/SnappyBuilder/releases/download/v1.1.7"

# TODO Update hash values, only the Windows x64 hash is correct right now
const download_info = Dict(
    Linux(:i686) =>     ("$bin_prefix/SnappyBuilder.i686-linux-gnu.tar.gz", "48eb2a4582549fa9fedc994cee8de6d4f0e4463c0e135075c32c470fc241367c"),
    Linux(:x86_64) =>   ("$bin_prefix/SnappyBuilder.x86_64-linux-gnu.tar.gz", "c5648bf09dc7adaf701630d7eb85f88bec6d704f7e00522727ac995a24736e38"),
    Linux(:aarch64) =>  ("$bin_prefix/SnappyBuilder.aarch64-linux-gnu.tar.gz", "c132f0f4319490f19df2961da0ac7a3bd3e7b81d29ad484dcb73eff773743fc4"),
    Linux(:armv7l) =>   ("$bin_prefix/SnappyBuilder.arm-linux-gnueabihf.tar.gz", "5370bcddd5aee7da59e477cd55c09a299577bc16cbf21afdab4055a13cf9176b"),
    Linux(:ppc64le) =>  ("$bin_prefix/SnappyBuilder.powerpc64le-linux-gnu.tar.gz", "4d756e61b474620251cc3d8404ada5e2d15d610e4b32b434ff73891680d572f8"),
    MacOS() =>          ("$bin_prefix/SnappyBuilder.x86_64-apple-darwin14.tar.gz", "5e64beef888703b8abf4fe33ad4af8e25b001d9c4749c3c81359e22e81f79b5b"),
    Windows(:i686) =>   ("$bin_prefix/SnappyBuilder.i686-w64-mingw32.tar.gz", "d1bc773ab110a2957d476bd66179ed496a7b0b883481d3bca3d927bc5a35664e"),
    Windows(:x86_64) => ("$bin_prefix/SnappyBuilder.x86_64-w64-mingw32.tar.gz", "5150ced35369ad8a879249a5c211824f5f1994bc81e433607d39ab3f786d974c"),
)

if platform in keys(download_info)
    # Grab the url and tarball hash for this particular platform
    url, tarball_hash = download_info[platform]

    install(url, tarball_hash; prefix=prefix, force=true, verbose=true)

    # Finaly, write out a deps file containing paths to libsnappy and fooifier
    @write_deps_file libsnappy
else
    error("Your platform $(Sys.MACHINE) is not recognized, we cannot install libsnappy.")
end
