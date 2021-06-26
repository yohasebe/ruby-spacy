require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")
doc = nlp.read("dog cat banana afskfsd")

headings = ["text", "has_vector", "vector_norm", "is_oov"]
rows = []

doc.each do |token|
  rows << [token.text, token.has_vector, token.vector_norm, token.is_oov]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +---------+------------+-------------------+--------+
# | text    | has_vector | vector_norm       | is_oov |
# +---------+------------+-------------------+--------+
# | dog     | true       | 7.033673286437988 | false  |
# | cat     | true       | 6.680818557739258 | false  |
# | banana  | true       | 6.700014114379883 | false  |
# | afskfsd | false      | 0.0               | true   |
# +---------+------------+-------------------+--------+
