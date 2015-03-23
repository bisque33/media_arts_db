# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'media_arts_db/version'

Gem::Specification.new do |spec|
  spec.name          = "media_arts_db"
  spec.version       = MediaArtsDb::VERSION
  spec.authors       = ["bisque"]
  spec.email         = ["bisque33@gmail.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  end

  spec.summary       = %q{media_arts_db is data access wrapper for http://mediaarts-db.jp/}
  spec.description   = %q{media_arts_db is to be able to data access easily from http://mediaarts-db.jp/}
  spec.homepage      = "https://github.com/bisque33/media_arts_db"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "addressable"
end
