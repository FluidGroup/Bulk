Pod::Spec.new do |s|
  s.name             = "Bulk"
  s.version          = "0.7.0"
  s.summary          = "Bulk is pipeline based powerful & flexible logging framework"
  s.homepage         = "https://github.com/muukii/Bulk"
  s.license          = 'MIT'
  s.author           = { "muukii" => "muukii.app@gmail.com" }
  s.source           = { :git => "https://github.com/muukii/Bulk.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/muukii_app'

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.default_subspec = 'Bulk'
  s.swift_version = '5.1'
  s.weak_frameworks = ['Combine']

  s.subspec 'Bulk' do |ss|
    ss.source_files = 'Sources/Bulk/**/*.swift'    
  end

  s.subspec 'RxBulk' do |ss|
    ss.source_files = 'Sources/RxBulk/**/*.swift'    
    ss.dependency 'RxSwift', '~> 5.0.0'
    ss.dependency 'Bulk/Bulk'  
  end

  s.subspec 'BulkLogger' do |ss|
    ss.source_files = 'Sources/BulkLogger/**/*.swift'    
    ss.dependency 'Bulk/Bulk'
  end
end
