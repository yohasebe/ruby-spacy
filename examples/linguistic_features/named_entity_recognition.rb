require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "Apple is looking at buying U.K. startup for $1 billion"
doc = nlp.read(sentence)

headings = ["text", "start", "end", "label"]
rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label_]
end

table = Terminal::Table.new rows: rows, headings: headings
print table
