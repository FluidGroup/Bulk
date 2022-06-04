Pod::Spec.new do |s|
  s.name             = "Bulk"
  s.version          = "0.7.0"
  s.summary          = "Bulk is a library for buffering the objects. Pipeline(Sink) receives the object and emits the object bulked."
  s.homepage         = "https://github.com/muukii/Bulk"
  s.license          = 'MIT'
  s.author           = { "muukii" => "muukii.app@gmail.com" }
  s.source           = { :git => "https://github.com/muukii/Bulk.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/muukii_app'

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.default_subspec = 'Bulk'
  s.swift_version = '5.6'
  s.weak_frameworks = ['Combine']

  s.subspec 'Bulk' do |ss|
    ss.source_files = 'Sources/Bulk/**/*.swift'    
  end

  s.subspec 'BulkLogger' do |ss|
    ss.source_files = 'Sources/BulkLogger/**/*.swift'    
    ss.dependency 'Bulk/Bulk'
  end
end
