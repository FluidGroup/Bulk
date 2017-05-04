Pod::Spec.new do |s|
  s.name             = "Bulk"
  s.version          = "0.1.0"
  s.summary          = "Bulk is pipeline based powerful & flexible logging framework"
  s.homepage         = "https://github.com/muukii/Bulk"
  s.license          = 'MIT'
  s.author           = { "muukii" => "m@muukii.me" }
  s.source           = { :git => "https://github.com/muukii/Bulk.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/muukii0803'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Sources/Bulk/*.swift'
end
