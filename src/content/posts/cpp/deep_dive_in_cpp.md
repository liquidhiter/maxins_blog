---
title: deep_dive_in_cpp
published: 2024-12-26
description: ''
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
