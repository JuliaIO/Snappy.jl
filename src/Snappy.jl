module Snappy

include("LibSnappy.jl")

export compress, uncompress

# snappy status
const SnappyOK             = Cint(0)
const SnappyInvalidInput   = Cint(1)
const SnappyBufferTooSmall = Cint(2)

function statuscheck(st, op::AbstractString="compress")
    st == LibSnappy.SNAPPY_OK && return nothing
    error("snappy failed to $op: " * if st == LibSnappy.SNAPPY_INVALID_INPUT
        "invalid input"
    elseif st == LibSnappy.SNAPPY_BUFFER_TOO_SMALL
        "buffer too small"
    else
        "unknown error code ($st)"
    end)
end

function compress(input::Vector{UInt8}; validate::Bool=false)
    ilen = length(input)
    maxlen = snappy_max_compressed_length(UInt(ilen))
    compressed = Array{UInt8}(undef, maxlen)
    olen, st = snappy_compress(input, compressed)
    statuscheck(st)
    resize!(compressed, olen)
    compressed
end
compress(input::AbstractVector{UInt8}) = compress(convert(Vector{UInt8}, input))

function uncompress(input::Array{UInt8})
    ilen = length(input)
    explen, st = snappy_uncompressed_length(input)
    if st != SnappyOK
        error("faield to guess the length of the uncompressed data (the compressed data may be broken?)")
    end
    uncompressed = Array{UInt8}(undef, explen)
    olen, st = snappy_uncompress(input, uncompressed)
    statuscheck(st, "uncompress")
    if explen ≠ olen
        error("snappy expected uncompressed length $explen but got $olen")
    end
    resize!(uncompressed, olen)
    uncompressed
end
uncompress(input::AbstractVector{UInt8}) = uncompress(convert(Vector{UInt8}, input))

# Low-level Interfaces

function snappy_compress(input::Vector{UInt8}, compressed::Vector{UInt8})
    olen = Ref{Csize_t}(length(compressed))
    st = LibSnappy.snappy_compress(input, length(input), compressed, olen)
    olen[], Int(st)
end

function snappy_uncompress(compressed::Vector{UInt8}, uncompressed::Vector{UInt8})
    olen = Ref{Csize_t}(length(uncompressed))
    st = LibSnappy.snappy_uncompress(compressed, length(compressed), uncompressed, olen)
    olen[], st
end

function snappy_max_compressed_length(source_length::Integer)
    LibSnappy.snappy_max_compressed_length(UInt(source_length))
end

function snappy_uncompressed_length(compressed::Vector{UInt8})
    result = Ref{Csize_t}(0)
    st = LibSnappy.snappy_uncompressed_length(compressed, length(compressed), result)
    result[], st
end

function snappy_validate_compressed_buffer(compressed::Vector{UInt8})
    LibSnappy.snappy_validate_compressed_buffer(compressed, length(compressed))
end

end # module
