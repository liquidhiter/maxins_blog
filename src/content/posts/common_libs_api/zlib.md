---
title: "zlib"
published: 2024-12-27
description: 'Get familiar with the next APIs'
image: ''
tags: ["zlib"]
category: 'LIB APIs'
draft: false 
lang: 'en'
---

## TODOs

- [ ] add a brief description to `zlib`
- [ ] add the link to the `zlib` repository

## How to decompress through `zlib` APIs?

### Step-wise Instructions

- `inflateInit`: initialize the internal `z_stream`
  - [ ] `inflatInit2`: `gzip` header check
- `inflate`: decompress the data

> example

```c++
/**
 * @brief Decompresses a GZIP file and writes the decompressed data to an output stream.
 * 
 * This function takes the path to a GZIP-compressed file, decompresses its contents,
 * and writes the decompressed data to the provided output stream.
 * 
 * @param inputPath The path to the GZIP-compressed file.
 * @param outputStream The output stream where the decompressed data will be written.
 */
void decompressGzipFile(const std::filesystem::path& inputPath, std::ostream& outputStream) {
    auto inputFile = std::make_unique<std::ifstream>(inputPath, std::ios_base::binary);
    if (!inputFile->is_open()) {
        throw std::runtime_error("Failed to open input file.");
    }

    z_stream zstream {
        .avail_in = 0,
        .next_in = Z_NULL,
        .zalloc = Z_NULL,
        .zfree = Z_NULL,
        .opaque = Z_NULL,
        .next_in = Z_NULL
    };

    int ret = inflateInit(&zstream);
    if (ret != Z_OK) {
        throw std::runtime_error("Failed to initialize zlib stream for decompression.");
    }

    std::array<char, CHUNK> in{};
    std::array<char, CHUNK> out{};
    do {
        inputFile->read(in.data(), in.size());
        zstream.avail_in = inputFile->gcount();
        zstream.next_in = reinterpret_cast<Bytef*>(in.data());
        do {
            zstream.avail_out = out.size();
            zstream.next_out = reinterpret_cast<Bytef*>(out.data());

            ret = inflate(&zstream, Z_NO_FLUSH);
            if (ret == Z_STREAM_ERROR) {
                throw std::runtime_error("Failed to decompress data.");
            }
            outputStream.write(out.data(), out.size() - zstream.avail_out);
        } while (zstream.avail_out == 0);
    } while (ret != Z_STREAM_END);

    inflateEnd(&zstream);
}

```

