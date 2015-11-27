Pod::Spec.new do |s|

  s.name         = "Headless"
  s.version      = "1.0.0"
  s.summary      = "A tiny library for automating interaction with websites without a user interface."

  s.description  = <<-DESC
                   A tiny library for automating interaction with websites without a user interface — written in Swift.
                   DESC

  s.homepage     = "https://github.com/mkoehnke/Headless"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = "Mathias Köhnke"

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/mkoehnke/Headless.git", :tag => s.version.to_s }

  s.source_files  = "Classes", "Classes/**/*.{swift}"
  s.exclude_files = "Classes/Exclude"

  s.requires_arc = true

  s.dependency 'hpple', '0.2.0'

end
