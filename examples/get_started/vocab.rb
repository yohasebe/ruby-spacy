require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("I love coffee")

pp doc.vocab.strings["coffee"]
pp doc.vocab.strings[3197928453018144401]
