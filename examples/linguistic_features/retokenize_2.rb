# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

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
