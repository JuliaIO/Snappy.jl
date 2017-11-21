using BinaryProvider

const prefix = Prefix(joinpath(@__DIR__,"usr"))

const platform = platform_key()

libsnappy = LibraryProduct(prefix, "libsnappy")

const bin_prefix="https://github.com/davidanthoff/SnappyBuilder/releases/download/v1.1.7"

# TODO Update hash values, only the Windows x64 hash is correct right now
const download_info = Dict(
    Linux(:i686) =>     ("$bin_prefix/SnappyBuilder.i686-linux-gnu.tar.gz", "e3b13b4b686157ff687a3c0685b77ceeb105e6f8666181b57aebbd775d21c0cf"),
    Linux(:x86_64) =>   ("$bin_prefix/SnappyBuilder.x86_64-linux-gnu.tar.gz", "727b343115760caff69cdcd10f8fbf63d4abd452b923e712553fb795ca4067ed"),
    Linux(:aarch64) =>  ("$bin_prefix/SnappyBuilder.aarch64-linux-gnu.tar.gz", "a05ac433b8ab84126017354e489cf3f4fd77dbfa4a2b328ad383c833098de3ef"),
    Linux(:armv7l) =>   ("$bin_prefix/SnappyBuilder.arm-linux-gnueabihf.tar.gz", "a22e0c2a7da49b3ed74d72946f89a7c5e69fc103d2e2ac7eae204b9d4ead158d"),
    Linux(:ppc64le) =>  ("$bin_prefix/SnappyBuilder.powerpc64le-linux-gnu.tar.gz", "d54a56fbc29b4f3e46f786b248f6de108fe24357e3701e0522503a397dd686ed"),
    MacOS() =>          ("$bin_prefix/SnappyBuilder.x86_64-apple-darwin14.tar.gz", "2245ba24ef2653e1f174f75ce5e868e505a469304db7b30022b2cf7fe51e267f"),
    Windows(:i686) =>   ("$bin_prefix/SnappyBuilder.i686-w64-mingw32.tar.gz", "5f766a018c77aa2136a9d3075027b257d1ab6c62cbcb4610bd8bc59085821b20"),
    Windows(:x86_64) => ("$bin_prefix/SnappyBuilder.x86_64-w64-mingw32.tar.gz", "615685cc76e0c985acef96185c7d42637e70a8ef79099a1b99a6d275a177cf3d"),
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
