require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("This is a sentence. This is another sentence.")


puts "doc has annotation SENT_START: " + doc.has_annotation("SENT_START").to_s

doc.sents.each do |sent|
  puts sent.text
end

# doc has annotation SENT_START: true
# This is a sentence.
# This is another sentence.
