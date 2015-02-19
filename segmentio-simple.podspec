Pod::Spec.new do |s|
  s.name             = "segmentio-simple"
  s.version          = "0.1.0"
  s.summary          = "This is a very minimal library for interacting with Segment."
  s.homepage         = "https://github.com/neonichu/segmentio-simple"
  s.license          = 'MIT'
  s.author           = { "Boris Bügling" => "boris@buegling.com" }
  s.source           = { :git => "https://github.com/neonichu/segmentio-simple.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/NeoNacho'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'

  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'Foundation'
  s.ios.frameworks = 'UIKit'
end
