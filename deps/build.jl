using BinaryProvider

const prefix = Prefix(joinpath(@__DIR__,"usr"))

const platform = platform_key()

libsnappy = LibraryProduct(prefix, "libsnappy")

const bin_prefix="https://github.com/davidanthoff/SnappyBuilder/releases/download/v1.1.7"

# TODO Update hash values, only the Windows x64 hash is correct right now
const download_info = Dict(
    Linux(:i686) =>     ("$bin_prefix/SnappyBuilder.i686-linux-gnu.tar.gz", "0a339c2ab55aed43e75d30d54a2b8dde89f910d065829cdc80fdbf294c9d2ac3"),
    Linux(:x86_64) =>   ("$bin_prefix/SnappyBuilder.x86_64-linux-gnu.tar.gz", "55f89f8fd259ceed5e85a17cc0c71e90e0131086df006a0cd01e7b690c929943"),
    Linux(:aarch64) =>  ("$bin_prefix/SnappyBuilder.aarch64-linux-gnu.tar.gz", "bad1485645a41d2b2648925ebd31ca5c6b930945098309612c61f7cac46d6c34"),
    Linux(:armv7l) =>   ("$bin_prefix/SnappyBuilder.arm-linux-gnueabihf.tar.gz", "4de9544e7fa80158d245823e5f9acd4193dd7ae12d89452c8095c30c91a2b91c"),
    Linux(:ppc64le) =>  ("$bin_prefix/SnappyBuilder.powerpc64le-linux-gnu.tar.gz", "0cedec5c673172dc0626bc04c7b7bc76fa056c5527fe9157e57265255820ce19"),
    MacOS() =>          ("$bin_prefix/SnappyBuilder.x86_64-apple-darwin14.tar.gz", "96ced92b58c6ebd34d43404d78b9ac1edd2046ee27ae5c636ceed8fbb7a76114"),
    Windows(:i686) =>   ("$bin_prefix/SnappyBuilder.i686-w64-mingw32.tar.gz", "34c95dcfcdc95b3ca80968dec2d8ebaf0b15a6864bb006acafc2973ad8ded946"),
    Windows(:x86_64) => ("$bin_prefix/SnappyBuilder.x86_64-w64-mingw32.tar.gz", "bad19b215f411bd2068c39317512f0c750779261f32e47681e56ac6056404c6d"),
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
