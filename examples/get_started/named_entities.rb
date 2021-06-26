require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc =nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text", "start_char", "end_char", "label"]
rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label_]
end

table = Terminal::Table.new rows: rows, headings: headings

puts table

# +------------+------------+----------+-------+
# | text       | start_char | end_char | label |
# +------------+------------+----------+-------+
# | Apple      | 0          | 5        | ORG   |
# | U.K.       | 27         | 31       | GPE   |
# | $1 billion | 44         | 54       | MONEY |
# +------------+------------+----------+-------+
