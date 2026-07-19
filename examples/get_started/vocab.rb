# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("I love coffee")

pp doc.vocab.strings["coffee"]
pp doc.vocab.strings[3_197_928_453_018_144_401]

# 3197928453018144401
# "coffee"
