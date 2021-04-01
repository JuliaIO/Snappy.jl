module Snappy

# Load libsnappy from our deps.jl
using snappy_jll

export compress, uncompress

# snappy status
const SnappyOK             = Cint(0)
const SnappyInvalidInput   = Cint(1)
const SnappyBufferTooSmall = Cint(2)

# High-level Interfaces

function compress(input::Vector{UInt8})
    ilen = length(input)
    maxlen = snappy_max_compressed_length(UInt(ilen))
    compressed = Array{UInt8}(undef, maxlen)
    olen, st = snappy_compress(input, compressed)
    if st != SnappyOK
        error("failed to compress the data")
    end
    resize!(compressed, olen)
    compressed
end

function uncompress(input::Array{UInt8})
    ilen = length(input)
    explen, st = snappy_uncompressed_length(input)
    if st != SnappyOK
        error("faield to guess the length of the uncompressed data (the compressed data may be broken?)")
    end
    uncompressed = Array{UInt8}(undef, explen)
    olen, st = snappy_uncompress(input, uncompressed)
    if st != SnappyOK
        error("failed to uncompress the data")
    end
    @assert explen == olen
    resize!(uncompressed, olen)
    uncompressed
end

# Low-level Interfaces

function snappy_compress(input::Vector{UInt8}, compressed::Vector{UInt8})
    ilen = length(input)
    olen = Ref{Csize_t}(length(compressed))
    status = ccall(
        (:snappy_compress, libsnappy),
        Cint,
        (Ptr{UInt8}, Csize_t, Ptr{UInt8}, Ref{Csize_t}),
        input, ilen, compressed, olen
    )
    olen[], status
end

function snappy_uncompress(compressed::Vector{UInt8}, uncompressed::Vector{UInt8})
    ilen = length(compressed)
    olen = Ref{Csize_t}(length(uncompressed))
    status = ccall(
        (:snappy_uncompress, libsnappy),
        Cint,
        (Ptr{UInt8}, Csize_t, Ptr{UInt8}, Ref{Csize_t}),
        compressed, ilen, uncompressed, olen
    )
    olen[], status
end

function snappy_max_compressed_length(source_length::UInt)
    ccall((:snappy_max_compressed_length, libsnappy), Csize_t, (Csize_t,), source_length)
end

function snappy_uncompressed_length(compressed::Vector{UInt8})
    len = length(compressed)
    result = Ref{Csize_t}(0)
    status = ccall((:snappy_uncompressed_length, libsnappy), Cint, (Ptr{UInt8}, Csize_t, Ref{Csize_t}), compressed, len, result)
    result[], status
end

function snappy_validate_compressed_buffer(compressed::Vector{UInt8})
    ilen = length(compressed)
    ccall((:snappy_validate_compressed_buffer, libsnappy), Cint, (Ptr{UInt8}, Csize_t), compressed, ilen)
end

end # module
