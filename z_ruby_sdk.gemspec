Gem::Specification.new do |spec|
  spec.name = 'z_ruby_sdk'
  spec.version = '1.0'
  spec.date = '2012-12-01'
  spec.summary = 'Zuora Ruby SDK for REST API support'
  spec.description = 'Ruby SDK released Alpha version - NOT FOR PRODUCTION.'
  spec.email = 'joe.chan@zuora.com'
  spec.homepage = 'http://www.zuora.com'
  spec.author = 'Joseph Chan'
  spec.files = Dir["lib/**/*", "samples/**/*", "config/**/*"]
  spec.has_rdoc = true
  spec.rubyforge_project = "zuora-rest-ruby"
  spec.extra_rdoc_files = ['README.md', 'LICENSE']
  spec.add_runtime_dependency "httpclient", ">= 2.3.1"
  spec.add_runtime_dependency "json_pure", ">= 1.7.6"
  spec.add_runtime_dependency "hashie", ">= 1.2.0"
  spec.add_runtime_dependency "awesome_print", ">= 1.1.0"
end
