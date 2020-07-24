Pod::Spec.new do |s|
  s.name         = "OwlKit"
  s.version      = "1.1.2"
  s.summary      = "A declarative type-safe framework for building fast and flexible list with Tables & Collections"
  s.description  = <<-DESC
    Owl offers a data-driven declarative approach for building fast & flexible list in iOS. It supports both UICollectionView & UITableView; UIStackView is on the way!.
  DESC
  s.homepage     = "https://github.com/malcommac/Owl"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "hello@danielemargutti.com" }
  s.social_media_url   = "https://twitter.com/danielemargutti"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/malcommac/Owl.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*.swift"
  s.frameworks  = "UIKit"
  s.swift_version = "5.0"
end
