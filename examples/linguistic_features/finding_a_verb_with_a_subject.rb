require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Autonomous cars shift insurance liability toward manufacturers")


results = []

doc.each do |token|
  if token.dep_ == "nsubj" && token.head.pos_ == "VERB"
    results << token.head
  end
end

pp results.to_s

