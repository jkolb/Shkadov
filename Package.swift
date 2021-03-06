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
    package.targets.append(Target(name: "PlatformAppKit", dependencies: ["Platform", "PlatformMachO"]))
	package.targets.append(Target(name: "PlatformDarwin", dependencies: ["Platform"]))
	package.targets.append(Target(name: "PlatformFoundation", dependencies: ["Platform"]))
    package.targets.append(Target(name: "PlatformMachO", dependencies: ["Utility"]))
    package.targets.append(Target(name: "PlatformPOSIX", dependencies: ["Platform"]))
	package.targets.append(Target(name: "Shkadov", dependencies: ["Platform", "PlatformAppKit", "PlatformDarwin", "PlatformFoundation", "PlatformPOSIX", "Logger"]))
	package.exclude.append("Sources/PlatformXCB")
    package.exclude.append("Sources/Shkadov/LinuxBootstrap.swift")
#elseif os(Linux)
	package.targets.append(Target(name: "PlatformPOSIX", dependencies: ["Platform"]))
	package.targets.append(Target(name: "PlatformXCB", dependencies: ["Platform"]))
	package.targets.append(Target(name: "Shkadov", dependencies: ["Platform", "PlatformXCB", "PlatformPOSIX", "Logger"]))
	package.dependencies.append(.Package(url: "https://github.com/jkolb/ShkadovXCB", majorVersion: 1))
    package.exclude.append("Sources/PlatformAppKit")
	package.exclude.append("Sources/PlatformDarwin")
    package.exclude.append("Sources/PlatformMachO")
    package.exclude.append("Sources/Shkadov/macOSBootstrap.swift")
#endif
