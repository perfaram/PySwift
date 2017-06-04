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
- Call function on Python objects with positional and named arguments,
- Convert String, Int, Float, Array/List between Swift & Python,
- Getting/setting attributes from object.

## Usage

see [Demo](src/PySwift_Demo/main.swift)

## Todos

- Support more types for « toll-free » bridging of objects between Swift and Python,
- Automagic creation of Python wrappers for Swift objects.
