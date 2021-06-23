# frozen_string_literal: true

require_relative "lib/ruby-spacy/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby-spacy"
  spec.version       = Spacy::VERSION
  spec.authors       = ["Yoichiro Hasebe"]
  spec.email         = ["yohasebe@gmail.com"]

  spec.summary       = "An wrapper module for using spaCy natural language processing library from the Ruby programming language using PyCall"
  spec.description   = "An wrapper module for using [spaCy](https://spacy.io/) natural language processing library from the Ruby programming language using PyCall"
  spec.homepage      = "https://github.com/yohasebe/ruby-spacy"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "pycall", "~> 1.4.0"
  spec.add_dependency "terminal-table"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
