# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yabeda/httpx/version"

Gem::Specification.new do |spec|
  spec.name          = "yabeda-httpx"
  spec.version       = Yabeda::Httpx::VERSION
  spec.authors       = ["Jon David Schober"]
  spec.email         = ["jon@getdatanamic.com"]

  spec.summary       = "Yabeda plugin for monitoring HTTPX external HTTP requests"
  spec.description   = "Yabeda plugin that instruments HTTPX HTTP client with request metrics including duration histograms, request counts, and error tracking"
  spec.homepage      = "https://github.com/jondavidschober/yabeda-httpx"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/jondavidschober/yabeda-httpx"
    spec.metadata["changelog_uri"] = "https://github.com/jondavidschober/yabeda-httpx/blob/main/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "yabeda", "~> 0.6"
  spec.add_dependency "httpx", ">= 1.2.0"

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
