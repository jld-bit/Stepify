// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Stepify",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "Stepify", targets: ["Stepify"])
    ],
    targets: [
        .executableTarget(
            name: "Stepify",
            path: "StepifyApp"
        )
    ]
)
