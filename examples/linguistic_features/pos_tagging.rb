# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = %w[text lemma pos tag dep shape is_alpha is_stop]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma, token.pos, token.tag, token.dep, token.shape, token.is_alpha, token.is_stop]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +---------+---------+-------+-----+----------+-------+----------+---------+
# | text    | lemma   | pos   | tag | dep      | shape | is_alpha | is_stop |
# +---------+---------+-------+-----+----------+-------+----------+---------+
# | Apple   | Apple   | PROPN | NNP | nsubj    | Xxxxx | true     | false   |
# | is      | be      | AUX   | VBZ | aux      | xx    | true     | true    |
# | looking | look    | VERB  | VBG | ROOT     | xxxx  | true     | false   |
# | at      | at      | ADP   | IN  | prep     | xx    | true     | true    |
# | buying  | buy     | VERB  | VBG | pcomp    | xxxx  | true     | false   |
# | U.K.    | U.K.    | PROPN | NNP | dobj     | X.X.  | false    | false   |
# | startup | startup | NOUN  | NN  | advcl    | xxxx  | true     | false   |
# | for     | for     | ADP   | IN  | prep     | xxx   | true     | true    |
# | $       | $       | SYM   | $   | quantmod | $     | false    | false   |
# | 1       | 1       | NUM   | CD  | compound | d     | false    | false   |
# | billion | billion | NUM   | CD  | pobj     | xxxx  | true     | false   |
# +---------+---------+-------+-----+----------+-------+----------+---------+
