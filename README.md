# Snappy - A fast compressor/decompressor

[![Build Status](https://travis-ci.org/JuliaIO/Snappy.jl.svg?branch=master)](https://travis-ci.org/JuliaIO/Snappy.jl)

[Snappy.jl](https://github.com/JuliaIO/Snappy.jl) is a Julia wrapper for the [snappy](https://code.google.com/p/snappy/) library - a compression/decompression library focusing on speed.


## High-level Interfaces

The `Snappy` module exports only two functions:

* `compress(input::Vector{UInt8}) -> compressed::Vector{UInt8}`
* `uncompress(input::Vector{UInt8}) -> uncompressed::Vector{UInt8}`.

These functions are self-explanatory and works as such (hence, always satisfies `uncompress(compress(input)) == input` for any `input`).


## Low-level Interfaces

If you dig into the module, you will find the following lower-level functions:

* `snappy_compress(input::Vector{UInt8}, compressed::Vector{UInt8}) -> (length, status)`
* `snappy_uncompress(compressed::Vector{UInt8}, uncompressed::Vector{UInt8}) -> (length, status)`
* `snappy_max_compressed_length(source_length::UInt) -> length`
* `snappy_uncompressed_length(compressed::Vector{UInt8}) -> (length, status)`
* `snappy_validate_compressed_buffer(compressed::Vector{UInt8}) -> status`.

These functions have one-to-one correspondance to the C-APIs and are very thin wrappers of them, so you can consult the ["snappy-c.h"](https://github.com/google/snappy/blob/master/snappy-c.h) header file for the documentation.
Moreover, even though these functions are not exported by default, you can assume that they are stable as long as the original C-APIs are stable.
