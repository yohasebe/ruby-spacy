require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text", "shape", "is_alpha", "is_stop", "morphology"]
rows = []

doc.each do |token|
  morph = token.morphology.map do |k, v|
    "#{k} = #{v}"
  # end.join("\n")
  end.join("<br />")
  rows << [token.text, token.pos_, token.tag_, token.dep_, morph]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +---------+-------+----------+----------+-----------------+
# | text    | shape | is_alpha | is_stop  | morphology      |
# +---------+-------+----------+----------+-----------------+
# | Apple   | PROPN | NNP      | nsubj    | NounType = Prop |
# |         |       |          |          | Number = Sing   |
# | is      | AUX   | VBZ      | aux      | Mood = Ind      |
# |         |       |          |          | Number = Sing   |
# |         |       |          |          | Person = 3      |
# |         |       |          |          | Tense = Pres    |
# |         |       |          |          | VerbForm = Fin  |
# | looking | VERB  | VBG      | ROOT     | Aspect = Prog   |
# |         |       |          |          | Tense = Pres    |
# |         |       |          |          | VerbForm = Part |
# | at      | ADP   | IN       | prep     |                 |
# | buying  | VERB  | VBG      | pcomp    | Aspect = Prog   |
# |         |       |          |          | Tense = Pres    |
# |         |       |          |          | VerbForm = Part |
# | U.K.    | PROPN | NNP      | dobj     | NounType = Prop |
# |         |       |          |          | Number = Sing   |
# | startup | NOUN  | NN       | advcl    | Number = Sing   |
# | for     | ADP   | IN       | prep     |                 |
# | $       | SYM   | $        | quantmod |                 |
# | 1       | NUM   | CD       | compound | NumType = Card  |
# | billion | NUM   | CD       | pobj     | NumType = Card  |
# +---------+-------+----------+----------+-----------------+
