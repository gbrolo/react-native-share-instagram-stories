  require "json"

  package = JSON.parse(File.read(File.join(__dir__, "../package.json")))
  version = package["version"]

  Pod::Spec.new do |s|
    s.name         = "RNShareInstagramStories"
    s.version      = version
    s.summary      = package["description"]
    s.homepage     = "https://github.com/abnerf/react-native-share-instagram-stories"
    s.license      = "MIT"
    s.description  = "React-Native support for Instagram Stories"
    s.license      = package["license"]
    s.author       = { "Abner Silva" => "abner@work.co" }
    s.platform     = :ios, "8.0"
    s.source       = { :git => "https://github.com/workco/react-native-adbmobile.git", :tag => "master" }
    s.source_files = "*.{h,m}"
    s.requires_arc = true

    s.dependency "React"
end


