require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text", "lemma", "pos", "tag", "dep"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_]
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
