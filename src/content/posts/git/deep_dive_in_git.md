---
title: "Deep Dive in GIT"
published: 2024-12-27
description: 'Understand git a bit more'
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
types:
- blob
- tree
- commit
- tag

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
#### contains
- Source code
- `blob 1262`: The `blob` indicates that this object is a binary large object, which in this case contains the source code of a C++ program. The number `1262` represents the size of the blob in bytes.

```bash
stat -c%s /home/maxin/git/codecrafters-git-cpp/src/Server.cpp
1262
```

### objects assoicated with commit
```bash
-------------------------------------------------- Decompressed Data from ./.git/objects/df/81f01124a17662f90fa6b0830b52c18179ae78--------------------------------------------------
commit 195tree 9b9b3c815ecb8d027d012a1ab7bf3ce986d50a29
author codecrafters-bot <hello@codecrafters.io> 1735229448 +0000
committer codecrafters-bot <hello@codecrafters.io> 1735229448 +0000

init [skip ci]

-------------------------------------------------- File Created On: 2024-12-27 10:03:26.260455--------------------------------------------------
-------------------------------------------------- File Size: 133 bytes--------------------------------------------------
-------------------------------------------------- SHA-1 Hash: df81f01124a17662f90fa6b0830b52c18179ae78--------------------------------------------------
```
#### contains
- Commit hash: The unique identifier for the commit.
- Tree hash: The hash of the tree object that represents the state of the repository at the time of the commit.
- Author: The name and email of the person who originally created the commit, along with the timestamp.
- Committer: The name and email of the person who last applied the commit, along with the timestamp.
- Commit Message

Another interesting observation is about the name of the sub-directory where the object file resides:
- `SHA-1 Hash: df81f01124a17662f90fa6b0830b52c18179ae78`
- `df`: used as the sub-directory name
- `81f01124a17662f90fa6b0830b52c18179ae78`: used as the object name

> changes to the .git folder after `git add new_file` and `git commit -m "COMMIT_MSG"`
```bash
diff -r -u /home/maxin/git/codecrafters-git-cpp/.git/COMMIT_EDITMSG /home/maxin/git/codecrafters-git-cpp/.git_snapshot/COMMIT_EDITMSG
--- /home/maxin/git/codecrafters-git-cpp/.git/COMMIT_EDITMSG    2024-12-27 17:16:07.443462227 +0100
+++ /home/maxin/git/codecrafters-git-cpp/.git_snapshot/COMMIT_EDITMSG   2024-12-27 10:56:01.000332817 +0100
@@ -1 +1 @@
-[WIP]: add new files
+[WIP] Add test file checking git objects
Binary files /home/maxin/git/codecrafters-git-cpp/.git/index and /home/maxin/git/codecrafters-git-cpp/.git_snapshot/index differ
diff -r -u /home/maxin/git/codecrafters-git-cpp/.git/logs/HEAD /home/maxin/git/codecrafters-git-cpp/.git_snapshot/logs/HEAD
--- /home/maxin/git/codecrafters-git-cpp/.git/logs/HEAD 2024-12-27 17:16:07.443462227 +0100
+++ /home/maxin/git/codecrafters-git-cpp/.git_snapshot/logs/HEAD        2024-12-27 17:14:48.393441897 +0100
@@ -4,4 +4,3 @@
 77b2f69947e60995716e1e017cd78e8a26665d32 9025951f8b8d80941f35b24bdddf352e18dba8c8 liquidhiter <909494727@qq.com> 1735293361 +0100      commit: [WIP] Add test file checking git objects
 9025951f8b8d80941f35b24bdddf352e18dba8c8 9025951f8b8d80941f35b24bdddf352e18dba8c8 liquidhiter <909494727@qq.com> 1735314719 +0100      reset: moving to HEAD
 9025951f8b8d80941f35b24bdddf352e18dba8c8 9025951f8b8d80941f35b24bdddf352e18dba8c8 liquidhiter <909494727@qq.com> 1735316088 +0100      reset: moving to HEAD
-9025951f8b8d80941f35b24bdddf352e18dba8c8 2f563aaa2ea5e049f6ad778f3d22d141b293c3a5 liquidhiter <909494727@qq.com> 1735316167 +0100      commit: [WIP]: add new files
diff -r -u /home/maxin/git/codecrafters-git-cpp/.git/logs/refs/heads/master /home/maxin/git/codecrafters-git-cpp/.git_snapshot/logs/refs/heads/master
--- /home/maxin/git/codecrafters-git-cpp/.git/logs/refs/heads/master    2024-12-27 17:16:07.443462227 +0100
+++ /home/maxin/git/codecrafters-git-cpp/.git_snapshot/logs/refs/heads/master   2024-12-27 10:56:01.000332817 +0100
@@ -2,4 +2,3 @@
 df81f01124a17662f90fa6b0830b52c18179ae78 209de45b65000b7f1df660c054188dbd85eb89b5 liquidhiter <909494727@qq.com> 1735291186 +0100      commit: test
 209de45b65000b7f1df660c054188dbd85eb89b5 77b2f69947e60995716e1e017cd78e8a26665d32 liquidhiter <909494727@qq.com> 1735291430 +0100      commit: Stage 1: initialize the .git directory
 77b2f69947e60995716e1e017cd78e8a26665d32 9025951f8b8d80941f35b24bdddf352e18dba8c8 liquidhiter <909494727@qq.com> 1735293361 +0100      commit: [WIP] Add test file checking git objects
-9025951f8b8d80941f35b24bdddf352e18dba8c8 2f563aaa2ea5e049f6ad778f3d22d141b293c3a5 liquidhiter <909494727@qq.com> 1735316167 +0100      commit: [WIP]: add new files
Only in /home/maxin/git/codecrafters-git-cpp/.git/objects/23: 8cebafb47177c249baf601c1b1aca6538a11b0
Only in /home/maxin/git/codecrafters-git-cpp/.git/objects/2f: 563aaa2ea5e049f6ad778f3d22d141b293c3a5
diff -r -u /home/maxin/git/codecrafters-git-cpp/.git/refs/heads/master /home/maxin/git/codecrafters-git-cpp/.git_snapshot/refs/heads/master
--- /home/maxin/git/codecrafters-git-cpp/.git/refs/heads/master 2024-12-27 17:16:07.443462227 +0100
+++ /home/maxin/git/codecrafters-git-cpp/.git_snapshot/refs/heads/master        2024-12-27 10:56:01.000332817 +0100
@@ -1 +1 @@
-2f563aaa2ea5e049f6ad778f3d22d141b293c3a5
+9025951f8b8d80941f35b24bdddf352e18dba8c8
```
- `git cat-file -t 2f563aaa2ea5e049f6ad778f3d22d141b293c3a5`: new `commit` objects
- `git cat-file -t 238cebafb47177c249baf601c1b1aca6538a11b0`: new `tree` objects

> `Python3` script to run the git command, e.x. `git add new_file`,  by first taking a snapshot of the `.git` folder and then diff the new one against the snapshot
```python3
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# This script is a wrapper around the git command
# A snapshot of the .git folder is taken before running the git command

def git_wrapper(command):
    import os
    import shutil
    import subprocess
    from pathlib import Path
    
    # Current folder
    current_folder = Path(__file__).resolve().parent
    root_folder = current_folder.parent.parent

    # Take a snapshot of the .git folder
    git_folder = root_folder / ".git"
    snapshot_folder = root_folder / ".git_snapshot"
    if os.path.exists(snapshot_folder):
        shutil.rmtree(snapshot_folder)
    shutil.copytree(git_folder, snapshot_folder)

    # Run the git command
    process = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if process.returncode != 0:
        print(f"Error executing command: {command}")
        print(f"Error: {process.stderr.decode()}")
        exit(1)

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 git_wrapper.py <git_command>")
        sys.exit(1)
    git_command = " ".join(sys.argv[1:])
    git_wrapper(git_command)
```

## Side Notes
- `.git/HEAD` file has a newline at the end
- `.git/HEAD` contains either `ref: refs/heads/main\n` or `ref:refs/heads/master\n`