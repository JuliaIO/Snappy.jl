using Snappy
using Base.Test
using Compat

const SnappyOK = Snappy.SnappyOK
const SnappyInvalidInput = Snappy.SnappyInvalidInput
const SnappyBufferTooSmall = Snappy.SnappyBufferTooSmall

# Low-level Interfaces

function originals()
    ["", "\x00", "\x00\x00", "foo", "foobarbaz", "x"^50]
end

let
    # Compress & uncompress small data using pre-allocated buffer
    buffer_size = 100
    for original in originals()
        # compress
        compressed = Array{UInt8}(buffer_size)
        olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
        @test st == SnappyOK
        resize!(compressed, olen)

        # uncompress
        uncompressed = Array{UInt8}(buffer_size)
        olen, st = Snappy.snappy_uncompress(compressed, uncompressed)
        @test st == SnappyOK
        resize!(uncompressed, olen)

        restored = String(uncompressed)
        @test original == restored
    end
end

let
    # Prepare too small buffer and try to compress and uncompress data
    original = "orig"

    # prepare too small buffer to compress
    compressed = Array{UInt8}(1)
    _, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
    @test st == SnappyBufferTooSmall

    # now enough buffer size
    compressed = Array{UInt8}(100)
    olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
    @test st == SnappyOK
    resize!(compressed, olen)

    # again the prepared buffer is too small to uncompress
    uncompressed = Array{UInt8}(1)
    olen, st = Snappy.snappy_uncompress(compressed, uncompressed)
    @test st == SnappyBufferTooSmall
end

let
    # Break compressed data and detect it
    original = "orig"
    compressed = Array{UInt8}(100)
    olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
    @test st == SnappyOK
    resize!(compressed, olen)
    @test Snappy.snappy_validate_compressed_buffer(compressed) == SnappyOK
    # perturb the compressed buffer
    compressed[1] = 0x00
    @test Snappy.snappy_validate_compressed_buffer(compressed) == SnappyInvalidInput
end

let
    # Estimate compressed size
    for original in originals()
        maxlen = Snappy.snappy_max_compressed_length(@compat(UInt(length(original))))
        compressed = Array{UInt8}(100)
        olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
        @test st == SnappyOK
        #@show Int(olen), Int(maxlen)
        @test olen <= maxlen
    end
end

let
    # Estimate uncompressed size
    for original in originals()
        compressed = Array{UInt8}(100)
        olen, st = Snappy.snappy_compress(Vector{UInt8}(original), compressed)
        @test st == SnappyOK
        resize!(compressed, olen)
        olen, st = Snappy.snappy_uncompressed_length(compressed)
        @test st == SnappyOK
        @test olen == length(original)
    end
end

# High-level Interfaces

let
    # QuickCheck-like property satisfaction tests (compress ○ uncompress = id)
    srand(2014)

    # byte arrays
    randbytes(n) = rand(UInt8, n)
    for original in map(randbytes, 0:100:10000)
        @test uncompress(compress(original)) == original
    end

    # strings
    for original in map(randstring, 0:100:1000)
        @test String(uncompress(compress(Vector{UInt8}(original)))) == original
    end
end

let
    # Large data
    # 128MiB
    srand(2014)
    original = randstring(128 * 1024^2)
    original_bytes = Vector{UInt8}(original)
    @test uncompress(compress(original_bytes)) == original_bytes
end
