module LibSnappy

using snappy_jll
export snappy_jll

using CEnum

@cenum snappy_status::UInt32 begin
    SNAPPY_OK = 0
    SNAPPY_INVALID_INPUT = 1
    SNAPPY_BUFFER_TOO_SMALL = 2
end

function snappy_compress(input, input_length, compressed, compressed_length)
    ccall((:snappy_compress, libsnappy), snappy_status, (Ptr{Cchar}, Csize_t, Ptr{Cchar}, Ptr{Csize_t}), input, input_length, compressed, compressed_length)
end

function snappy_uncompress(compressed, compressed_length, uncompressed, uncompressed_length)
    ccall((:snappy_uncompress, libsnappy), snappy_status, (Ptr{Cchar}, Csize_t, Ptr{Cchar}, Ptr{Csize_t}), compressed, compressed_length, uncompressed, uncompressed_length)
end

function snappy_max_compressed_length(source_length)
    ccall((:snappy_max_compressed_length, libsnappy), Csize_t, (Csize_t,), source_length)
end

function snappy_uncompressed_length(compressed, compressed_length, result)
    ccall((:snappy_uncompressed_length, libsnappy), snappy_status, (Ptr{Cchar}, Csize_t, Ptr{Csize_t}), compressed, compressed_length, result)
end

function snappy_validate_compressed_buffer(compressed, compressed_length)
    ccall((:snappy_validate_compressed_buffer, libsnappy), snappy_status, (Ptr{Cchar}, Csize_t), compressed, compressed_length)
end

const SNAPPY_MAJOR = 1

const SNAPPY_MINOR = 1

const SNAPPY_PATCHLEVEL = 9

const SNAPPY_VERSION = (SNAPPY_MAJOR << 16 | SNAPPY_MINOR << 8) | SNAPPY_PATCHLEVEL

end # module
