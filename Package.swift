import PackageDescription

let package = Package(
    name: "PySwift",
    targets: [
        Target(
            name: "PySwift_ObjC",
            dependencies:[]),
        Target(
            name: "PySwift",
            dependencies:["PySwift_ObjC"]),
        Target(
            name: "PySwift_Demo",
            dependencies: [.Target(name: "PySwift")])
    ],
    dependencies: []
)

