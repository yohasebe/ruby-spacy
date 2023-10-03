# frozen_string_literal: true

require_relative "lib/ruby-spacy/version"

Gem::Specification.new do |spec|
  spec.name        = "ruby-spacy"
  spec.version     = Spacy::VERSION
  spec.authors     = ["Yoichiro Hasebe"]
  spec.email       = ["yohasebe@gmail.com"]

  spec.summary     = "A wrapper module for using spaCy natural language processing library from the Ruby programming language using PyCall"
  spec.description = <<~DESC
    ruby-spacy is a wrapper module for using spaCy from the Ruby programming language via PyCall. This module aims to make it easy and natural for Ruby programmers to use spaCy. This module covers the areas of spaCy functionality for using many varieties of its language models, not for building ones.
  DESC

  spec.homepage      = "https://github.com/yohasebe/ruby-spacy"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "solargraph"

  spec.add_dependency "numpy", "~> 0.4.0"
  spec.add_dependency "pycall", "~> 1.5.1"
  spec.add_dependency "ruby-openai"
  spec.add_dependency "terminal-table", "~> 3.0.1"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
