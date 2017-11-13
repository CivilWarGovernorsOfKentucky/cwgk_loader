
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cwgk_loader/version"

Gem::Specification.new do |spec|
  spec.name          = "cwgk_loader"
  spec.version       = CwgkLoader::VERSION
  spec.authors       = ["Dazhi Jiao"]
  spec.email         = ["djiao@jhu.edu"]

  spec.summary       = %q{Upload XML documents to CWGK Omeka}
  spec.homepage      = "http://github.com/jiaola/cwgk_loader"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "git"
  spec.add_runtime_dependency "mysql2"
  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "dotenv"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
