using BinaryProvider

const prefix = Prefix(joinpath(@__DIR__,"usr"))

const platform = platform_key()

libsnappy = LibraryProduct(prefix, "libsnappy")

const bin_prefix="https://github.com/davidanthoff/SnappyBuilder/releases/download/v1.1.7"

# TODO Update hash values, only the Windows x64 hash is correct right now
const download_info = Dict(
    Linux(:i686) =>     ("$bin_prefix/SnappyBuilder.i686-linux-gnu.tar.gz", "cd2b3256bfdfc251494cf092936506f437c92d5b467f7770c4235ed3e639914d"),
    Linux(:x86_64) =>   ("$bin_prefix/SnappyBuilder.x86_64-linux-gnu.tar.gz", "63a6789ef9111c24468caf43fa7738b38a901150fdf5025eb2e1b6264628a9d2"),
    Linux(:aarch64) =>  ("$bin_prefix/SnappyBuilder.aarch64-linux-gnu.tar.gz", "b271ff745ae33134bb83e23c09f1acdceaa5c36f205767abdf66900cd0fb34b9"),
    Linux(:armv7l) =>   ("$bin_prefix/SnappyBuilder.arm-linux-gnueabihf.tar.gz", "bcae64587236daa1ac2b8c801faf85869edbb4047dd95fc3163f56d44016d007"),
    Linux(:ppc64le) =>  ("$bin_prefix/SnappyBuilder.powerpc64le-linux-gnu.tar.gz", "c3efc79dcd51de5a5ffb6210dc257bf77f45240516c310f149ff4387385d624b"),
    MacOS() =>          ("$bin_prefix/SnappyBuilder.x86_64-apple-darwin14.tar.gz", "4f15671d14a409e6a2140748419b91002e004554848d2bd01b6c6da74abdb9ab"),
    Windows(:i686) =>   ("$bin_prefix/SnappyBuilder.i686-w64-mingw32.tar.gz", "1984eb5a04c78fbeae440fcd6ebe9f92d6c8c8facb7fff807ae7178dda61636b"),
    Windows(:x86_64) => ("$bin_prefix/SnappyBuilder.x86_64-w64-mingw32.tar.gz", "50b1af335612b4c352b6dca17a425a7ab9265ddc773cc69757b6f4dadbdf0918"),
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
