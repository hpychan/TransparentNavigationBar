Pod::Spec.new do |spec|
  spec.name         = 'TransparentNavigationBar'
  spec.version      = '1.0.0'
  spec.platform     = :ios, '7.0'
  spec.summary      = 'Transparent NavigationBar for iOS'
  spec.homepage     = 'https://github.com/hpychan/TransparentNavigationBar'
  spec.author       = { 'Henry Chan' => 'henry@henrychan.me' }
  spec.source       = { :git => 'https://github.com/hpychan/TransparentNavigationBar.git', :tag => "v#{spec.version}" }
  spec.description  = 'Transparent Navigation Bar for iOS support enlarging image view and reappearance offset'
  spec.source_files = 'TransparentNavigationBar/*.{h,m}'
  spec.requires_arc = true
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
end
