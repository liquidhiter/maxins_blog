---
title: "Issues and Solutions"
published: 2024-12-27
description: 'Solving the next problem'
image: ''
tags: ["problem solving"]
category: 'dev'
draft: false 
lang: 'en'
---

## CMake

### `target_link_libraries`

1. signature conflicts

```bash
-- Running vcpkg install
Detecting compiler hash for triplet x64-linux...
Compiler found: /usr/bin/c++
All requested packages are currently installed.
Total install time: 199 ns
The package zlib is compatible with built-in CMake targets:

    find_package(ZLIB REQUIRED)
    target_link_libraries(main PRIVATE ZLIB::ZLIB)

-- Running vcpkg install - done
CMake Error at CMakeLists.txt:18 (target_link_libraries):
  The plain signature for target_link_libraries has already been used with
  the target "git".  All uses of target_link_libraries with a target must be
  either all-keyword or all-plain.

  The uses of the plain signature are here:

   * CMakeLists.txt:17 (target_link_libraries)
```

> source CMakeLists.txt

```cmake
file(GLOB_RECURSE SOURCE_FILES src/*.cpp src/*.hpp)

add_executable(git ${SOURCE_FILES})

target_link_libraries(git -lz)
target_link_libraries(git PRIVATE ZLIB::ZLIB)
```

- best guess is that the `ZLIB::ZLIB` conflicts with `-lz`
  - `keyword`: `ZLIB::ZLIB`
  - `plain`: `-lz`
