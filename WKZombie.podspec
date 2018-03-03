Pod::Spec.new do |s|

  s.name         = "WKZombie"
  s.version      = "1.1.1"
  s.summary      = "WKZombie is a Swift library for iOS/OSX to browse websites without the need of User Interface or API."

  s.description  = <<-DESC
                   WKZombie is a Swift library for iOS/OSX to navigate within websites and collect data without the need of User Interface or API, also known as Headless Browser.
                   In addition, it can be used to run automated tests, take snapshots or manipulate websites using Javascript.
                   DESC

  s.homepage     = "https://github.com/mkoehnke/WKZombie"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = "Mathias Köhnke"

  s.ios.deployment_target = '10.3'
  s.osx.deployment_target = '10.12'

  s.source       = { :git => "https://github.com/mkoehnke/WKZombie.git", :tag => s.version.to_s }

  s.source_files  = "Sources/WKZombie/*.{swift}"
  s.exclude_files = "Sources/Exclude"

  s.requires_arc = true

  s.dependency 'hpple', '0.2.0' 

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end
