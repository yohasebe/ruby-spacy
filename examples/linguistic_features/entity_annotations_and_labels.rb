require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "San Francisco considers banning sidewalk delivery robots" 
doc = nlp.read(sentence)

headings = ["text", "ent_iob", "ent_iob_", "ent_type_"]
rows = []

doc.each do |ent|
  rows << [ent.text, ent.ent_iob, ent.ent_iob_, ent.ent_type_]
end

table = Terminal::Table.new rows: rows, headings: headings
print table
