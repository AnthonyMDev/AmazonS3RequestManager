Pod::Spec.new do |s|
  s.name = 'AmazonS3RequestManager'
  s.version = '0.6.0'
  s.license = 'MIT'
  s.summary = 'A Alamofire based request manager that serializes requests to the AWS S3 (Amazon Simple Storage Solution). Based on AFAmazonS3Manager'
  s.homepage = 'https://github.com/AnthonyMDev/AmazonS3RequestManager'
  s.social_media_url = 'http://twitter.com/AnthonyMDev'
  s.authors = { 'Anthony Miller' => 'AnthonyMDev@gmail.com' }
  s.frameworks = 'Foundation', 'MobileCoreServices'
  s.platform     = :osx, "10.9"
  s.source       = { :git => "https://github.com/frankrue/AmazonS3RequestManager.git", :tag => "0.0.1" }
  s.source_files  = "AmazonS3RequestManager/*"
  s.exclude_files = "AmazonS3RequestManager/Info.plist"
  s.requires_arc = true
  s.dependency 'Alamofire', '~> 2.0'
end
