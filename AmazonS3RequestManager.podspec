Pod::Spec.new do |s|
  s.name = 'AmazonS3RequestManager'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'An Alamofire Manager subclass for Amazon S3 requests.'
  s.homepage = 'https://github.com/AnthonyMDev/AmazonS3RequestManager'
  s.social_media_url = 'http://twitter.com/AnthonyMDev'
  s.authors = { 'Anthony Miller' => 'AnthonyMDev@gmail.com' }
  s.source = { :git => 'https://github.com/AnthonyMDev/AmazonS3RequestManager.git', :tag => s.version }
  s.frameworks = 'Foundation', 'MobileCoreServices'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AmazonS3RequestManager/*.{h,m,swift}'

  s.requires_arc = true

  s.dependency 'Alamofire', '~> 1.1'
end
