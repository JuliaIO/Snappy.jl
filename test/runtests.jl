using Snappy
using Base.Test

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
        compressed = Array(Uint8, buffer_size)
        olen, st = Snappy.snappy_compress(original.data, compressed)
        @test st == SnappyOK
        resize!(compressed, olen)

        # uncompress
        uncompressed = Array(Uint8, buffer_size)
        olen, st = Snappy.snappy_uncompress(compressed, uncompressed)
        @test st == SnappyOK
        resize!(uncompressed, olen)

        restored = ASCIIString(uncompressed)
        @test original == restored
    end
end

let
    # Prepare too small buffer and try to compress and uncompress data
    original = "orig"

    # prepare too small buffer to compress
    compressed = Array(Uint8, 1)
    _, st = Snappy.snappy_compress(original.data, compressed)
    @test st == SnappyBufferTooSmall

    # now enough buffer size
    compressed = Array(Uint8, 100)
    olen, st = Snappy.snappy_compress(original.data, compressed)
    @test st == SnappyOK
    resize!(compressed, olen)

    # again the prepared buffer is too small to uncompress
    uncompressed = Array(Uint8, 1)
    olen, st = Snappy.snappy_uncompress(compressed, uncompressed)
    @test st == SnappyBufferTooSmall
end

let
    # Break compressed data and detect it
    original = "orig"
    compressed = Array(Uint8, 100)
    olen, st = Snappy.snappy_compress(original.data, compressed)
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
        maxlen = Snappy.snappy_max_compressed_length(uint(length(original)))
        compressed = Array(Uint8, 100)
        olen, st = Snappy.snappy_compress(original.data, compressed)
        @test st == SnappyOK
        #@show int(olen), int(maxlen)
        @test olen <= maxlen
    end
end

let
    # Estimate uncompressed size
    for original in originals()
        compressed = Array(Uint8, 100)
        olen, st = Snappy.snappy_compress(original.data, compressed)
        @test st == SnappyOK
        resize!(compressed, olen)
        olen, st = Snappy.snappy_uncompressed_length(compressed)
        @test st == SnappyOK
        @test olen == length(original)
    end
end

# High-level Interfaces

let
    srand(2014)
    for original in map(randstring, 0:100:1000)
        @test ASCIIString(uncompress(compress(original.data))) == original
    end
end

# Large data

let
    # 128MiB
    srand(2014)
    original = randstring(128 * 1024^2)
    @test uncompress(compress(original.data)) == original.data
end
