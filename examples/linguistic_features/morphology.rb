require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

puts "Pipeline: " + nlp.pipe_names.to_s

doc = nlp.read("I was reading the paper.")

token = doc[0]

puts "Morph features of the first word: " + token.morph.to_s
puts "PronType of the word: " + token.morph.get("PronType").to_s

# Pipeline: ["tok2vec", "tagger", "parser", "ner", "attribute_ruler", "lemmatizer"]
# Morph features of the first word: Case=Nom|Number=Sing|Person=1|PronType=Prs
# PronType of the word: ['Prs']
