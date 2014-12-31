using BinDeps
@BinDeps.setup

snappy = library_dependency("libsnappy")

@osx_only begin
    using Homebrew
    provides(Homebrew.HB, "snappy", snappy, os=:Darwin)
end

@BinDeps.install
