---
title: "Deep Dive in C++"
published: 2024-12-26
description: 'DO u hate C++?'
image: ''
tags: [cpp]
category: 'Programming Language'
draft: false 
lang: 'en'
---

In C++, the `protected` access specifier means that the member variables or functions declared under it are accessible within the class itself, by derived classes, and by friend classes or functions. However, they are not accessible from outside these classes.

In your code, `numProtected` is declared as a `protected` member of the `Base` class. This means:
- `numProtected` can be accessed directly within the `Base` class.
- `numProtected` can be accessed directly within any class derived from `Base`, such as `DerivedPublic`, `DerivedPublic2`, and `OutScopeClass`.
- `numProtected` cannot be accessed directly from outside these classes.

For example, in the `DerivedPublic` class, `numProtected` is accessed directly in the `print` function:
```cpp
std::cout << "numProtected: " << numProtected << std::endl;
```

However, if you try to access `numProtected` from an instance of `Base` or `DerivedPublic` outside these classes, it will result in a compilation error.

## Resource Management via `std::unique_ptr`

- pros
  - ensures that resources are properly released even if an exception is thrown
- cons
  - additional heap allocation, which might be inacceptable in some performance-critical application

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

