Pod::Spec.new do |s|
  s.name         = 'CropShape'
  s.version      = '2.0.0'
  s.summary      = 'Crop an image to a specified shape.'
  s.description  = 'Swift library that crops a UIImage to a specified shape.'
  s.homepage     = 'https://github.com/finolaire/CropShape'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'finolaire' => 'lvshitianxia@outlook.com' }
  s.source       = { :git => 'https://github.com/finolaire/CropShape.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*.swift'
  s.resource_bundles = {
    'CropShape' => ['Resources/en.lproj/*.strings', 'Resources/zh-Hans.lproj/*.strings']
  }
  s.frameworks = 'UIKit', 'SwiftUI'
end
