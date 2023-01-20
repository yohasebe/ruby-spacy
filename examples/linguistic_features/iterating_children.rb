# frozen_string_literal: true

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

puts results.to_s

# ["shift"]
