Pod::Spec.new do |s|
  s.name         = "OwlKit"
  s.version      = "1.0.0"
  s.summary      = ""
  s.description  = <<-DESC
    Your description here.
  DESC
  s.homepage     = "https://github.com/malcommac/Owl"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "hello@danielemargutti.com" }
  s.social_media_url   = ""
  s.ios.deployment_target = "10.0"
  s.source       = { :git => "https://github.com/malcommac/Owl.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
