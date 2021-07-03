require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Autonomous cars shift insurance liability toward manufacturers")


results = []

doc.each do |token|
  if token.pos_ == "VERB"
    token.children.each do |child|
      if child.dep_ == "nsubj"
        results << child.head.text
      end
    end
  end
end

puts results.to_s

# ["shift"]

