# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "San Francisco considers banning sidewalk delivery robots"
doc = nlp.read(sentence)

headings = %w[text ent_iob ent_iob_ ent_type_]
rows = []

doc.each do |ent|
  rows << [ent.text, ent.ent_iob, ent.ent_iob_, ent.ent_type]
end

table = Terminal::Table.new rows: rows, headings: headings
print table

# +-----------+---------+----------+-----------+
# | text      | ent_iob | ent_iob_ | ent_type_ |
# +-----------+---------+----------+-----------+
# | San       | 3       | B        | GPE       |
# | Francisco | 1       | I        | GPE       |
# | considers | 2       | O        |           |
# | banning   | 2       | O        |           |
# | sidewalk  | 2       | O        |           |
# | delivery  | 2       | O        |           |
# | robots    | 2       | O        |           |
# +-----------+---------+----------+-----------+
