require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")

puts "Pipeline: " + nlp.pipe_names.to_s

doc = nlp.read("I was reading the paper.")

token = doc[0]

puts "Morph features of the first word: " + token.morph.to_s
puts "PronType of the word: " + token.morph.get("PronType").to_s
