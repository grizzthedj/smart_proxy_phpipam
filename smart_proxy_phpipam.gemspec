
require File.expand_path('../lib/smart_proxy_phpipam/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'smart_proxy_phpipam'
  s.version = Proxy::Phpipam::VERSION

  s.summary = 'Smart proxy plugin for IPAM integration with phpIPAM'
  s.description = 'Smart proxy plugin for IPAM integration with phpIPAM'
  s.authors = ['Christopher Smith']
  s.email = 'chrisjsmith001@gmail.com'
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.files = Dir['{lib,settings.d,bundler.d}/**/*'] + s.extra_rdoc_files
  s.homepage = 'http://github.com/grizzthedj/smart_proxy_phpipam'
  s.license = 'GPL-3.0'
end
