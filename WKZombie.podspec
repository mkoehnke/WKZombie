Pod::Spec.new do |s|

  s.name         = "WKZombie"
  s.version      = "0.9.1"
  s.summary      = "WKZombie is a Swift library for iOS to navigate within websites and collect data without the need of User Interface or API, also known as Headless Browser."

  s.description  = <<-DESC
                   WKZombie is a Swift library for iOS to navigate within websites and collect data without the need of User Interface or API, also known as Headless Browser.
                   In addition, it can be used to run automated tests or manipulate websites using Javascript.
                   DESC

  s.homepage     = "https://github.com/mkoehnke/WKZombie"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = "Mathias Köhnke"

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/mkoehnke/WKZombie.git", :tag => s.version.to_s }

  s.subspec 'HTML' do |ss|
    ss.source_files = "Classes/HTML/*.{swift}"
  end

  s.subspec 'JSON' do |ss|
    ss.source_files = "Classes/JSON/*.{swift}"
  end

  s.source_files  = "Classes/*.{swift}"
  s.exclude_files = "Classes/Exclude"

  s.requires_arc = true

  s.dependency 'hpple', '0.2.0'
end
