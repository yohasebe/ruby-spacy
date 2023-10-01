# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion.")

headings = %w[text lemma pos tag dep]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma, token.pos, token.tag, token.dep]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +---------+---------+-------+-----+----------+
# | text    | lemma   | pos   | tag | dep      |
# +---------+---------+-------+-----+----------+
# | Apple   | Apple   | PROPN | NNP | nsubj    |
# | is      | be      | AUX   | VBZ | aux      |
# | looking | look    | VERB  | VBG | ROOT     |
# | at      | at      | ADP   | IN  | prep     |
# | buying  | buy     | VERB  | VBG | pcomp    |
# | U.K.    | U.K.    | PROPN | NNP | dobj     |
# | startup | startup | NOUN  | NN  | advcl    |
# | for     | for     | ADP   | IN  | prep     |
# | $       | $       | SYM   | $   | quantmod |
# | 1       | 1       | NUM   | CD  | compound |
# | billion | billion | NUM   | CD  | pobj     |
# +---------+---------+-------+-----+----------+
