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

## Template Class

### Implementation separate from declaration

- [ ] add detailed description to how the normal classes are compiled and associated objects are linked to each other

> Template Compilation Process

For **templates**, the compilation process differs from non-template classes because **templates** are *not compiled into machine code immediately*. Instead, **templates** follow a process called **delayed instantiation** (also known as lazy instantiation).

- Declaration Phase (Parsing)
  - The compiler parses the template declaration without generating any code
  - The compiler doesn't compile the body of the template unless it is explicitly instantiated with a concrete type
- Instantiation Phase (Type Binding)
  - The compiler requires the entire definition of the template to generate the code, when the template is instantiated with a specific type
  - The compiler checks whether the template definition is visible at the point of instantiation

#### Not working

`my_template_class.hpp`

```c++
#ifndef __TEMPLATE_CLASS_H_
#define __TEMPLATE_CLASS_H_

/// Template class

template <typename T> class MyTemplateClass {
public:
  MyTemplateClass() = default;
  MyTemplateClass(T initVal) : initVal{initVal} {}
  virtual void printPretty() const;

private:
  T initVal;
};

#ifdef __TEMPLATE_CLASS_IMPL_
/// Include the implementation here
#include "my_template_class.impl"
#elif defined(__TEMPLATE_CLASS_IMPL_CPP_)
/// Declare the implementation here
#include "my_template_class.cpp"
#else
/// Do nothing, let the compiler to fail
#endif

#endif // __TEMPLATE_CLASS_H_

```

`my_template_class.cpp`

```c++
#include <iostream>
#ifndef (__TEMPLATE_CLASS_IMPL_)
#include "my_template_class.hpp"
#endif

template <typename T>
void MyTemplateClass<T>::printPretty() const {
  std::cout << "Init val = " << this->initVal << std::endl;
}

```

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.20)

set(TARGET "template_class")
project(
    ${TARGET}
    VERSION 1.0.0
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(__TEMPLATE_CLASS_IMPL_ "Enable to add template class implementation." OFF)
option(__TEMPLATE_CLASS_IMPL_CPP_ "Enable to add template class cpp." OFF)

add_executable(template_class main.cpp)

if(${__TEMPLATE_CLASS_IMPL_} STREQUAL "ON")
    message(WARNING "Include template class implementation.")
    add_compile_definitions(__TEMPLATE_CLASS_IMPL_)
endif()

if(${__TEMPLATE_CLASS_IMPL_CPP_} STREQUAL "ON")
    message(WARNING "Include template class cpp.")
    add_compile_definitions(__TEMPLATE_CLASS_IMPL_CPP_)
endif()
```

**linking failure**

```bash
/usr/bin/ld: CMakeFiles/template_class.dir/main.cpp.o: in function `main':
main.cpp:(.text+0x45): undefined reference to `MyTemplateClass<int>::printPretty() const'
/usr/bin/ld: CMakeFiles/template_class.dir/main.cpp.o:(.data.rel.ro._ZTV15MyTemplateClassIiE[_ZTV15MyTemplateClassIiE]+0x10): undefined reference to `MyTemplateClass<int>::printPretty() const'
collect2: error: ld returned 1 exit status
make[2]: *** [CMakeFiles/template_class.dir/build.make:100: template_class] Error 1
make[1]: *** [CMakeFiles/Makefile2:87: CMakeFiles/template_class.dir/all] Error 2
make: *** [Makefile:91: all] Error 2
```

- The template implementation is in `my_template_class.cpp` which is not compiled along with the `main.cpp` because template definitions ***are not compiled until instantiated***
- The compiler doesn't see the implementation at the point of instantiation because `my_template_class.cpp` is not included in `main.cpp`
- The linker cannot find the implementation, leading to linker errors

####  Working

`my_template_class.hpp`

```c++
#ifndef __TEMPLATE_CLASS_H_
#define __TEMPLATE_CLASS_H_

/// Template class

template <typename T> class MyTemplateClass {
public:
  MyTemplateClass() = default;
  MyTemplateClass(T initVal) : initVal{initVal} {}
  virtual void printPretty() const;

private:
  T initVal;
};

#ifdef __TEMPLATE_CLASS_IMPL_
/// Include the implementation here
#include "my_template_class.impl"
#elif defined(__TEMPLATE_CLASS_IMPL_CPP_)
/// Declare the implementation here
#include "my_template_class.cpp"
#else
/// Do nothing, let the compiler to fail
#endif

#endif // __TEMPLATE_CLASS_H_

```

`my_template_class.impl`

```c++
#include <iostream>

template <typename T>
void MyTemplateClass<T>::printPretty() const {
  std::cout << "Init val = " << this->initVal << std::endl;
}

```

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.20)

set(TARGET "template_class")
project(
    ${TARGET}
    VERSION 1.0.0
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(__TEMPLATE_CLASS_IMPL_ "Enable to add template class implementation." ON)
option(__TEMPLATE_CLASS_IMPL_CPP_ "Enable to add template class cpp." OFF)

add_executable(template_class main.cpp)

if(${__TEMPLATE_CLASS_IMPL_} STREQUAL "ON")
    message(WARNING "Include template class implementation.")
    add_compile_definitions(__TEMPLATE_CLASS_IMPL_)
endif()

if(${__TEMPLATE_CLASS_IMPL_CPP_} STREQUAL "ON")
    message(WARNING "Include template class cpp.")
    add_compile_definitions(__TEMPLATE_CLASS_IMPL_CPP_)
endif()
```

> Include the implementation in the template class header file, if it is crucial to separate the implementation from the header file

##### alternative solution

1. define everything in the template class header file

2. include the implementation file in the header file (seems rarely used)

3. explicit instantiation to force the compiler to generate code for the specific types (see below)

##### solution 3

`my_template_class_explicit_instantiation.cpp`

```c++
#include <iostream>
#include "my_template_class.hpp"

template <typename T>
void MyTemplateClass<T>::printPretty() const {
  std::cout << "Init val = " << this->initVal << std::endl;
}

/// Force the compiler to generate code for the template classes with int / float / double type
template class MyTemplateClass<int>;
template class MyTemplateClass<float>;
template class MyTemplateClass<double>;
```

`CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.20)

set(TARGET "template_class")
project(
    ${TARGET}
    VERSION 1.0.0
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(__TEMPLATE_CLASS_IMPL_ "Enable to add template class implementation." OFF)
option(__TEMPLATE_CLASS_IMPL_CPP_ "Enable to add template class cpp." OFF)

add_executable(template_class main.cpp)

if(${__TEMPLATE_CLASS_IMPL_} STREQUAL "ON")
    message(WARNING "Include template class implementation.")
    add_compile_definitions(__TEMPLATE_CLASS_IMPL_)
endif()

if(${__TEMPLATE_CLASS_IMPL_CPP_} STREQUAL "ON")
    message(WARNING "Include template class cpp.")
    add_compile_definitions(__TEMPLATE_CLASS_IMPL_CPP_)
endif()

if(${__TEMPLATE_CLASS_IMPL_CPP_} STREQUAL "OFF" AND ${__TEMPLATE_CLASS_IMPL_} STREQUAL "OFF")
    message(WARNING "Explicit instantiation of template class.")
    target_sources(${TARGET} PRIVATE my_template_class_explicit_instantiation.cpp)
endif()
```

## `this`

- `const` method

```c++
void Point::getX() const {
    return this->x;
}
```

> `this` underlying is **const Point*x**

## `const`

- `const` overloading
  - `const` objects must be accessed via `const interface`

```c++
private:
	const size_t logical_size;

public:
	size_t size() const;

template <type T>
size_t Vector<T>::size() const {
    return this->logical_size;
}
```

- what if we want to modify the returned object?
  - **const correctness**

```c++
public:
	const T& at(size_t index) const;
	T& at(size_t index);

/// const version
template <type T>
const T& Vector<T>::at(size_t index) const {
	return elems[index];
}

/// non-const version
template <type T>
T& vector<T>::at(size_t index) {
	return elems[index];
}
```

- complicated logic

> implement logic in non-const version, and cast away the `constness` of`this` pointer in the const version

```c++
/// When modification is the primary use case

int&
MyStruct::findElement(const int& elem) {
    std::cout << "const version of findElement" << std::endl;
    for (int i = 0; i < this->size; i++) {
        if (this->data[i] == elem) {
            return this->data[i];
        }
    }
    throw std::runtime_error("Element not found");
}

/**
 * non-const version of findElement
 * const_cast is used to cast away the constness of variables.
 */
const int&
MyStruct::findElement(const int& elem) const {
    std::cout << "non-const version of findElement" << std::endl;
    return const_cast<MyStruct*>(this)->findElement(elem);
}
```

- counterintuitive as `const` version depends on the **mutable** behavior of the `non-const` version
- might violate **const-correctness** as **constness** should not be casted away if the object is supposed to be const

> implement logic in const version, and cast away the `constness` from the returned-result of the const version

```c++
/// When read-only operations are more common

const int&
MyStruct::findElement(const int& elem) const{
    std::cout << "const version of findElement" << std::endl;
    for (int i = 0; i < this->size; i++) {
        if (this->data[i] == elem) {
            return this->data[i];
        }
    }
    throw std::runtime_error("Element not found");
}

int &
MyStruct::findElement(const int &elem) {
    std::cout << "non-const version of findElement" << std::endl;
    // return const_cast<int&>(const_cast<const MyStruct*>(this)->findElement(elem));
    return const_cast<int&>(static_cast<const MyStruct&>(*this).findElement(elem));
}
```

- extra casting `static_cast<const MyStruct&>`

## `mutable`

- allows a data member of a class or struct to be modifiable even if it is part of a const object

```c++
struct MyStruct2 {
  int data;
  mutable int counter = 0;
};

const MyStruct2 myStruct2{5};
/// myStruct2 is const, so we cannot modify its data member
// myStruct2.data = 10;
myStruct2.counter = 10;

```







