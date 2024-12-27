---
title: deep_dive_in_git
published: 2024-12-27
description: ''
image: ''
tags: [git]
category: 'git'
draft: false 
lang: 'en'
---
# Deep Dive in Git

## TODOs
- explain the use of different folder / files under `.git`

## .git directory
```bash
./.git
├── COMMIT_EDITMSG
├── FETCH_HEAD
├── HEAD
├── branches
├── config
├── description
├── hooks
│   ├── applypatch-msg.sample
│   ├── commit-msg.sample
│   ├── fsmonitor-watchman.sample
│   ├── post-update.sample
│   ├── pre-applypatch.sample
│   ├── pre-commit.sample
│   ├── pre-merge-commit.sample
│   ├── pre-push.sample
│   ├── pre-rebase.sample
│   ├── pre-receive.sample
│   ├── prepare-commit-msg.sample
│   └── update.sample
├── index
├── info
│   └── exclude
├── logs
│   ├── HEAD
│   └── refs
│       ├── heads
│       │   └── master
│       └── remotes
│           └── origin
│               ├── HEAD
│               └── master
├── objects
│   ├── 90
│   │   └── 25951f8b8d80941f35b24bdddf352e18dba8c8
│   ├── info
│   └── pack
├── packed-refs
└── refs
    ├── heads
    │   └── master
    ├── remotes
    │   └── origin
    │       ├── HEAD
    │       └── master
    └── tags
```
- `branches`
- `hooks`
- `info`
- `logs`
- `objects`
- `refs`
- `HEAD`
- `config`
- `description`


## `objects`
```bash
file ./.git/objects/90/25951f8b8d80941f35b24bdddf352e18dba8c8
./.git/objects/90/25951f8b8d80941f35b24bdddf352e18dba8c8: zlib compressed data
```
- compressed data containing the information required by Git to track the changes of files and directories

- `python3` script to uncompress the `object`
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import zlib
import sys
import os
from datetime import datetime

def decompress_file(input_path):
    with open(input_path, 'rb') as input_file:
        compressed_data = input_file.read()
        decompressed_data = zlib.decompress(compressed_data)
        file_stats = os.stat(input_path)
        creation_time = datetime.fromtimestamp(file_stats.st_ctime)
        file_size = file_stats.st_size

        print("-" * 50 + f" Decompressed Data from {input_path}" + "-" * 50)
        print(decompressed_data.decode('utf-8', errors='ignore'))
        print("-" * 50 + f" File Created On: {creation_time}" + "-" * 50)
        print("-" * 50 + f" File Size: {file_size} bytes" + "-" * 50)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 parse_git_objects.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    decompress_file(input_file)
```

### `objects` associated with code change
- example
```bash
-------------------------------------------------- File Created On: 2024-12-27 10:23:50.460408--------------------------------------------------
-------------------------------------------------- File Size: 238 bytes--------------------------------------------------
-------------------------------------------------- Decompressed Data from .git/objects/a5/0ba666051ce64698f0e82d6c97e5482922add9--------------------------------------------------
blob 1262#include <iostream>
#include <filesystem>
#include <fstream>
#include <string>

int main(int argc, char *argv[])
{
    // Flush after every std::cout / std::cerr
    std::cout << std::unitbuf;
    std::cerr << std::unitbuf;

    if (argc < 2) {
        std::cerr << "No command provided.\n";
        return EXIT_FAILURE;
    }
    
    std::string command = argv[1];
    
    if (command == "init") {
        try {
            std::filesystem::create_directory(".git");
            std::filesystem::create_directory(".git/objects");
            std::filesystem::create_directory(".git/refs");
    
            std::ofstream headFile(".git/HEAD");
            if (headFile.is_open()) {
                headFile << "ref: refs/heads/main\n";
                headFile.close();
            } else {
                std::cerr << "Failed to create .git/HEAD file.\n";
                return EXIT_FAILURE;
            }
    
            std::cout << "Initialized git directory\n";
        } catch (const std::filesystem::filesystem_error& e) {
            std::cerr << e.what() << '\n';
            return EXIT_FAILURE;
        }
    } else {
        std::cerr << "Unknown command " << command << '\n';
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}
```
### contains
- Source code
- `blob 1262`: The `blob` indicates that this object is a binary large object, which in this case contains the source code of a C++ program. The number `1262` represents the size of the blob in bytes.

```bash
stat -c%s /home/maxin/git/codecrafters-git-cpp/src/Server.cpp
1262
```