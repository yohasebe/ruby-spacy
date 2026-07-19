# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("This is a sentence. This is another sentence.")

puts "doc has annotation SENT_START: #{doc.has_annotation("SENT_START")}"

doc.sents.each do |sent|
  puts sent.text
end

# doc has annotation SENT_START: true
# This is a sentence.
# This is another sentence.
