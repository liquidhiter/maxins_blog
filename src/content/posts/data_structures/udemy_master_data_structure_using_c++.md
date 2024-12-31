---
title: "Review of DSA using C++"
published: 2024-12-31
description: 'This is my 2nd time of reviewing the DSA using C++...'
image: ''
tags: ["Data Structure", "Algorithm"]
category: 'CS Core'
draft: false 
lang: 'en'
---

## Thoughts

- computer is manipulating data (e.x. bytes in RAM)
    - how efficient is the operation on data depends on how efficient the data are arranged 

[TOC]

## Section 1: Before we start

- [ ] Skip

## Section 2: Essential C and C++ Concepts

- [ ] Skip

## Section 3:  Required Setup for Programming

- [ ] Skip

## Section 4: Introduction

### data structures
- arrangement of data in the main memory
- determines how efficient the data can be operated by the application / system

### databases

- [ ] TODOs

### Static and Dynamic Memory Allocation

- RAM is divided into **manageable** pieces which are called **segment**
- RAM is divided into different **sections**

  - **code**
  - **stack**
  - **heap**
- size of the function required by a function is decided at compile time
- how does  the compiler determine the heap size then?
  - initial heap allocation
    - when the program starts, the OS reserves a **minimum** heap size for the **process** 
      - this size depends on system configurations and runtime library settings
        - e.x. Linux may allocate **128 KB** to **1 MB** initially
  - heap growth
    - if the program requests more memory, the heap can grow dynamically by requesting more memory from the **OS Kernel** using `brk()` or `mmap()` system calls
  - heap limit
    - the **maximum heap size** depends on 
      - available physical memory (RAM)
      - virtual memory (swap space)
      - OS-enforced resource limits
  - custom configurations
    - e.x. **kernel configuration** in Zephyr OS

### Physical and Logical Data Structures

- physical data structures: how data are arranged in the memory
- logical data structures: build upon the physical data structures

### ADT (Abstract Data Type)

- Data Type
  - data  (different representation)
  - operations
- Abstract
  - expose APIs for the operation on data
    - BUT hiding all internal implementations

### Time and Space Complexity 

- [ ] skip

## Section 5: Recursion

- **calling phase**
- **returning phase**

```c++
void fun() {
    /// some base condition
    base_condition();
    
    /// Code to be executed during calling phase
    code_before_recursive_call();
    
   	/// Recursive call
    fun();
    
    /// Code to be executed during returning phase
    code_after_recursive_call();
}
```

- *loop only has the calling phase*

### tracing tree

- call stacks

### time complexity

- tracing tree
- recursion relations

### Static variables in recursion

```c++
int sum_numbers_static(int n) {
    static int x = 0;
    if (n == 0) {
        return 0;
    }

    ++x;
    /// x is a static variable, incrementing x will not be reset after the
    /// function returns
    /// so the value of x will be accumulated
    /// result = n * n
    /// KEY POINT here: x is evaluated during the returning phase, that is,
    /// after the recursive call
    return x + sum_numbers_static(n - 1);
}

int sum_static = sum_numbers_static(20);
int sum_static_expect = 20 * 20;
spdlog::info("Sum of numbers from 1 to 20 (static): {} (expect: {})", sum_static, sum_static_expect);
EXPECT_EQ(sum_static, sum_static_expect);
```

> static variable **x** is evaluated during the returning phase, which has already been incremented during the calling phase.
>
> in this case, the recursion calls serve as a loop, repeating to increase the value of the static variable

### Types of recursion

#### Tail recursion

- recursive call is the **last statement** of the function
  - everything is performed in **calling phase**

```c++
void print_numbers_descending(int n) {
    if (n == 0) {
        return;
    }

    std::cout << n << " ";
    print_numbers_descending(n - 1);
    /// recursive call is the last statement
    /// nothing needs to be done after it
}
```

- **tail recursion** can be easily converted into a loop

```c++
/// Convert the above tail recursioin to a loop
/// Tail recursion can be converted to a loop easily
void print_numbers_descending_loop(int n) {
    for (int i = n; i > 0; --i) {
        std::cout << i << " ";
    }
}
```

|                | Time complexity | Space Complexity |
| -------------- | --------------- | ---------------- |
| tail recursion | O(n)            | **O(n)**         |
| loop           | O(n)            | **O(1)**         |

> modern compilers can optimize the tail recursion into a loop to reduce the space consumption

### Head recursion

- everything is performed in `returning phase`

```c++
/// Head recursion
void print_numbers_ascending(int n) {
    if (n > 0) {
        /// Nothing is performed before the recursive call
        print_numbers_ascending(n - 1);
        /// Everything is performed after the recursive call
        std::cout << n << " ";
    }
}
```

- **head cursion** usually can't be easily converted into a loop

### Tree recursion

- function calls itself more than once

```c++
/// Tree recursion
void print_numbers_tree(int n) {
    if (n > 0) {
        std::cout << n << " ";
        print_numbers_tree(n - 1);
        print_numbers_tree(n - 1);
    }
}
```

- time complexity: `O(2^n)`
- space complexity: tree height `O(n)`

### Indirect recursion

```c++
/// Indirect recursion
/// for fun...
void fun_indirect_recursion_b(int n);
void fun_indirect_recursion_a(int n) {
    if (n == 0) {
        return;
    }

    std::cout << n << " ";
    fun_indirect_recursion_b(n - 1);
}

void fun_indirect_recursion_b(int n) {
    if (n > 1) {
        std::cout << n << " ";
        fun_indirect_recursion_a(n >> 1);
    }
}
```

