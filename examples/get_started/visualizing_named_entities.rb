# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "When Sebastian Thrun started working on self-driving cars at Google in 2007, few people outside of the company took him seriously."
doc = nlp.read(sentence)

ent_html = doc.displacy(style: "ent")

File.open(File.join(File.dirname(__FILE__), "test_ent.html"), "w") do |file|
  file.write(ent_html)
end
