import PackageDescription

let package = Package(
    name: "PySwift",
    targets: [
        Target(
            name: "PySwift_None",
            dependencies:[]),
        Target(
            name: "PySwift",
            dependencies:["PySwift_None"]),
        Target(
            name: "PySwift_Demo",
            dependencies: [.Target(name: "PySwift")])
    ],
    dependencies: []
)

