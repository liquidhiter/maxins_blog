---
title: Deep Dive in CMake
published: 2024-12-30
updated: 2024-12-30
description: 'CMake is not perfect, but it is the best choice ATP'
image: ''
tags: ["CMake"]
category: 'Tooling'
draft: false
---

## CMake Optional Commands

- `CMAKE_CXX_EXTENSIONS`

> set it off to use the standard C++ language without any vendor-specific extensions

- `CMAKE_CXX_STANDARD_REQUIRED `

> enforces the specific version of the C++ standard must be supported by the compiler, usually used with the `CMAKE_CXX_STANDARD` 