# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "I live in New York"
doc = nlp.read(sentence)

puts "Before: #{doc.tokens.map(&:text).join(", ")}"

doc.retokenize(3, 4)

puts "After: #{doc.tokens.map(&:text).join(", ")}"

# Before: I, live, in, New, York
# After: I, live, in, New York
