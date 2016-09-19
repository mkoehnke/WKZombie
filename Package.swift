import PackageDescription

let package = Package(
  name: "WKZombie",
  targets: [
      Target(name: "WKZombie"),
      Target(name: "Example", dependencies:["WKZombie"])
  ],
  dependencies: [
	   .Package(url: "https://github.com/mkoehnke/hpple.git", Version(0,2,2))
  ]
)
