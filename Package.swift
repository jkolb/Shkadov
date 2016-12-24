import PackageDescription

let package = Package(
    name: "Shkadov",
    targets: [
    	Target(name: "Logger", dependencies: ["Platform"]),
    	Target(name: "Platform", dependencies: ["Utility"]),
    	Target(name: "Utility", dependencies: []),
    ],
    dependencies: [
    	.Package(url: "https://github.com/jkolb/FieryCrucible", majorVersion: 2),
    	.Package(url: "https://github.com/jkolb/FranticApparatus", majorVersion: 6),
    	.Package(url: "https://github.com/jkolb/Lilliput", majorVersion: 4),
    	.Package(url: "https://github.com/jkolb/Swiftish", majorVersion: 2),
    ]
)

#if os(macOS)
	package.targets.append(Target(name: "Darwin", dependencies: ["Platform"]))
	package.targets.append(Target(name: "POSIX", dependencies: ["Platform"]))
	package.targets.append(Target(name: "Shkadov", dependencies: ["Platform"]))
	package.exclude.append("Sources/Linux")
	package.exclude.append("Sources/XCB")
#elseif os(Linux)
	package.targets.append(Target(name: "Linux", dependencies: ["Platform"]))
	package.targets.append(Target(name: "POSIX", dependencies: ["Platform"]))
	package.targets.append(Target(name: "XCB", dependencies: ["Platform"]))
	package.targets.append(Target(name: "Shkadov", dependencies: ["Platform", "XCB"]))
	package.dependencies.append(.Package(url: "https://github.com/jkolb/ShkadovXCB", majorVersion: 1))
	package.exclude.append("Sources/Darwin")
#endif
