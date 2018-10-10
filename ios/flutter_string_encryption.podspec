#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_string_encryption'
  s.version          = '0.0.1'
  s.summary          = 'Cross-platform string encryption using common best-practices'
  s.description      = <<-DESC
Cross-platform string encryption using common best-practices
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'SCrypto', '~> 2.0'
  s.static_framework = true

  s.ios.deployment_target = '9.0'
end
