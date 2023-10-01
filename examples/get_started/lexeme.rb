# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("I love coffee")

headings = %w[text shape prefix suffix is_alpha is_digit]
rows = []

doc.each do |word|
  lexeme = nlp.vocab(word.text)
  rows << [lexeme.text, lexeme.shape, lexeme.prefix, lexeme.suffix, lexeme.is_alpha, lexeme.is_digit]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +--------+-------+--------+--------+----------+----------+
# | text   | shape | prefix | suffix | is_alpha | is_digit |
# +--------+-------+--------+--------+----------+----------+
# | I      | X     | I      | I      | true     | false    |
# | love   | xxxx  | l      | ove    | true     | false    |
# | coffee | xxxx  | c      | fee    | true     | false    |
# +--------+-------+--------+--------+----------+----------+
