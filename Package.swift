import PackageDescription

let package = Package(
    name: "Shkadov",
    dependencies: [
    	.Package(url: "https://github.com/jkolb/FieryCrucible", majorVersion: 2),
    	.Package(url: "https://github.com/jkolb/FranticApparatus", majorVersion: 6),
    	.Package(url: "https://github.com/jkolb/Lilliput", majorVersion: 4),
    	.Package(url: "https://github.com/jkolb/Swiftish", majorVersion: 2),
    ]
)
