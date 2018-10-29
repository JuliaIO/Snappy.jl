using Snappy
using Random
using Test

@testset "Low-level Interfaces" begin
    SnappyOK = Snappy.SnappyOK
    SnappyInvalidInput = Snappy.SnappyInvalidInput
    SnappyBufferTooSmall = Snappy.SnappyBufferTooSmall

    function originals()
        ["", "\x00", "\x00\x00", "foo", "foobarbaz", "x"^50]
    end

    # Compress & uncompress small data using pre-allocated buffer
    buffer_size = 100
    for original in originals()
        # compress
        compressed = Array{UInt8}(undef, buffer_size)
        olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
        @test st == SnappyOK
        resize!(compressed, olen)

        # uncompress
        uncompressed = Array{UInt8}(undef, buffer_size)
        olen, st = Snappy.snappy_uncompress(compressed, uncompressed)
        @test st == SnappyOK
        resize!(uncompressed, olen)

        restored = String(uncompressed)
        @test original == restored
    end

    # Prepare too small buffer and try to compress and uncompress data
    original = "orig"

    # prepare too small buffer to compress
    compressed = Array{UInt8}(undef, 1)
    _, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
    @test st == SnappyBufferTooSmall

    # now enough buffer size
    compressed = Array{UInt8}(undef, 100)
    olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
    @test st == SnappyOK
    resize!(compressed, olen)

    # again the prepared buffer is too small to uncompress
    uncompressed = Array{UInt8}(undef, 1)
    olen, st = Snappy.snappy_uncompress(compressed, uncompressed)
    @test st == SnappyBufferTooSmall

    # Break compressed data and detect it
    original = "orig"
    compressed = Array{UInt8}(undef, 100)
    olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
    @test st == SnappyOK
    resize!(compressed, olen)
    @test Snappy.snappy_validate_compressed_buffer(compressed) == SnappyOK
    # perturb the compressed buffer
    compressed[1] = 0x00
    @test Snappy.snappy_validate_compressed_buffer(compressed) == SnappyInvalidInput

    # Estimate compressed size
    for original in originals()
        maxlen = Snappy.snappy_max_compressed_length(UInt(length(original)))
        compressed = Array{UInt8}(undef, 100)
        olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
        @test st == SnappyOK
        #@show Int(olen), Int(maxlen)
        @test olen <= maxlen
    end

    # Estimate uncompressed size
    for original in originals()
        compressed = Array{UInt8}(undef, 100)
        olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
        @test st == SnappyOK
        resize!(compressed, olen)
        olen, st = Snappy.snappy_uncompressed_length(compressed)
        @test st == SnappyOK
        @test olen == length(original)
    end
end

@testset "High-level Interfaces" begin
    # QuickCheck-like property satisfaction tests (compress ○ uncompress = id)
    Random.seed!(2014)

    # byte arrays
    randbytes(n) = rand(UInt8, n)
    for original in map(randbytes, 0:100:10000)
        @test uncompress(compress(original)) == original
    end

    # strings
    for original in map(randstring, 0:100:1000)
        @test String(uncompress(compress(Vector{UInt8}(original)))) == original
    end

    # Large data
    # 128MiB
    Random.seed!(2014)
    original = randstring(128 * 1024^2)
    original_bytes = Vector{UInt8}(original)
    @test uncompress(compress(original_bytes)) == original_bytes
end
