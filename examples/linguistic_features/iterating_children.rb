# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Autonomous cars shift insurance liability toward manufacturers")

results = []

doc.each do |token|
  next unless token.pos_ == "VERB"

  token.children.each do |child|
    results << child.head.text if child.dep_ == "nsubj"
  end
end

puts results

# ["shift"]
