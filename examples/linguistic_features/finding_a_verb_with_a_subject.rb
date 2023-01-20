# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Autonomous cars shift insurance liability toward manufacturers")

results = []

doc.each do |token|
  results << token.head.text if token.dep_ == "nsubj" && token.head.pos_ == "VERB"
end

puts results.to_s

# ["shift"]
