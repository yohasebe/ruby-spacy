# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "Apple is looking at buying U.K. startup for $1 billion"
doc = nlp.read(sentence)

headings = %w[text start end label]
rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +------------+-------+-----+-------+
# | text       | start | end | label |
# +------------+-------+-----+-------+
# | Apple      | 0     | 5   | ORG   |
# | U.K.       | 27    | 31  | GPE   |
# | $1 billion | 44    | 54  | MONEY |
# +------------+-------+-----+-------+
