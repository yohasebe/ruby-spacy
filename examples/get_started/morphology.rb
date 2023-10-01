# frozen_string_literal: true

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = %w[text shape is_alpha is_stop morphology]
rows = []

doc.each do |token|
  morph = token.morphology.map do |k, v|
    "#{k} = #{v}"
  end.join("\n")
  # end.join("<br />")
  rows << [token.text, token.shape, token.is_alpha, token.is_stop, morph]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +---------+-------+----------+---------+-----------------+
# | text    | shape | is_alpha | is_stop | morphology      |
# +---------+-------+----------+---------+-----------------+
# | Apple   | Xxxxx | true     | false   | NounType = Prop |
# |         |       |          |         | Number = Sing   |
# | is      | xx    | true     | true    | Mood = Ind      |
# |         |       |          |         | Number = Sing   |
# |         |       |          |         | Person = 3      |
# |         |       |          |         | Tense = Pres    |
# |         |       |          |         | VerbForm = Fin  |
# | looking | xxxx  | true     | false   | Aspect = Prog   |
# |         |       |          |         | Tense = Pres    |
# |         |       |          |         | VerbForm = Part |
# | at      | xx    | true     | true    |                 |
# | buying  | xxxx  | true     | false   | Aspect = Prog   |
# |         |       |          |         | Tense = Pres    |
# |         |       |          |         | VerbForm = Part |
# | U.K.    | X.X.  | false    | false   | NounType = Prop |
# |         |       |          |         | Number = Sing   |
# | startup | xxxx  | true     | false   | Number = Sing   |
# | for     | xxx   | true     | true    |                 |
# | $       | $     | false    | false   |                 |
# | 1       | d     | false    | false   | NumType = Card  |
# | billion | xxxx  | true     | false   | NumType = Card  |
# +---------+-------+----------+---------+-----------------+
