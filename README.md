# Swiftpy : embedding Python in Swift

## Requirements

- OSX 10.12 (may work on a lower version, though this is untested)
- Swift version 3.1, swiftlang-802.0.53 (may work on a lower version, though this is untested)
- Python 2.7 (system Python)

## Building

```bash
git checkout develop
swift build
```

run demo

```bash
.build/debug/PySwift_Demo
```

## Features

- Run Python code from string,
- Load Python module,
- Call Python functions, and methods on Python objects, with positional and named arguments,
- Convert String, Int, Float, Array/List between Swift & Python,
- Getting/setting attributes from object.

## Usage

see [Demo](src/PySwift_Demo/main.swift)

## To-do

![DOCUMENT ALL THE THINGS](https://cdn.meme.am/cache/instances/folder415/64911415.jpg "")

1. DOCUMENT ALL THE THINGS
2. Support more types for « toll-free » bridging of objects between Swift and Python,
3. Smooth things out and allow manual creation of Python counterparts for Swift custom classes (essentially, just like #2 but for your own classes),
4. Automagic creation of Python wrappers for Swift objects (eventually).

## How can I help ? 
Do your things and submit a PR. Alternatively, I'll soon put up a list of small things to do, in addition to the Todo.
