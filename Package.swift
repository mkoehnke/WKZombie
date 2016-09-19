import PackageDescription

let package = Package(
  name: "WKZombie",
  targets: [],
  dependencies: [
	.Package(url: "https://github.com/mkoehnke/hpple.git", Version(0,2,2))
  ]
)
