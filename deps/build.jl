using BinaryProvider

const prefix = Prefix(joinpath(@__DIR__,"usr"))

const platform = platform_key()

libsnappy = LibraryProduct(prefix, "libsnappy")

const bin_prefix="https://github.com/davidanthoff/SnappyBuilder/releases/download/v1.1.7"

# TODO Update hash values, only the Windows x64 hash is correct right now
const download_info = Dict(
    Linux(:i686) =>     ("$bin_prefix/SnappyBuilder.i686-linux-gnu.tar.gz", "f7507f06762dea5d4007ae2a0fb672093e1a6007cd16de6cdfe745c6474bc95b"),
    Linux(:x86_64) =>   ("$bin_prefix/SnappyBuilder.x86_64-linux-gnu.tar.gz", "767497ed970b00562e79359397f76d7bfbdb8fe7b730c0cfcdd36e686ec5d2fc"),
    Linux(:aarch64) =>  ("$bin_prefix/SnappyBuilder.aarch64-linux-gnu.tar.gz", "974867ab140f92fd3dca72935153d7759e46708f6492216376fff46024b32458"),
    Linux(:armv7l) =>   ("$bin_prefix/SnappyBuilder.arm-linux-gnueabihf.tar.gz", "f7325872f982a71c3f7bc4df324b121f3b4ceeeeaf9129c02e040dc2e7a0e0d2"),
    Linux(:ppc64le) =>  ("$bin_prefix/SnappyBuilder.powerpc64le-linux-gnu.tar.gz", "59a1d81f862abd61b41ae9a4e6aad9d8da8bc8f14483575120e635b43d5f0201"),
    MacOS() =>          ("$bin_prefix/SnappyBuilder.x86_64-apple-darwin14.tar.gz", "9d33952c433d4ac2f0ab17d7fc69db38651e751e67c6d6e6b2424409bdbf7388"),
    Windows(:i686) =>   ("$bin_prefix/SnappyBuilder.i686-w64-mingw32.tar.gz", "d587f8979b42ea6f6baa602e58e4796744208d242676a28099efd35038a51c8e"),
    Windows(:x86_64) => ("$bin_prefix/SnappyBuilder.x86_64-w64-mingw32.tar.gz", "e80de0cf571fadc8592a7ed9973ca89fe5efbe07a099513b125ae765e8a5c3f8"),
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
