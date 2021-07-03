require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "Credit and mortgage account holders must submit their requests"
doc = nlp.read(sentence)

headings = ["text", "dep", "n_lefts", "n_rights", "ancestors"]
rows = []

root = doc.tokens.select do |t|
  # need to compare token and its head using their indices
  t.i == t.head.i
end.first

puts "The sentence: " + sentence

subject = Spacy::Token.new(root.lefts[0])

puts "The root of the sentence is: " + root.text
puts "The subject of the sentence is: " + subject.text

subject.subtree.each do |descendant|
  # need to convert "ancestors" object from a python generator to a ruby array
  ancestors = Spacy::generator_to_array(descendant.ancestors)
  rows << [descendant.text, descendant.dep, descendant.n_lefts, descendant.n_rights, ancestors.map(&:text).join(", ")]
end

table = Terminal::Table.new rows: rows, headings: headings
print table

# The sentence: Credit and mortgage account holders must submit their requests
# The root of the sentence is: submit
# The subject of the sentence is: holders
# +----------+----------+---------+----------+----------------------------------+
# | text     | dep      | n_lefts | n_rights | ancestors                        |
# +----------+----------+---------+----------+----------------------------------+
# | Credit   | nmod     | 0       | 2        | holders, submit                  |
# | and      | cc       | 0       | 0        | Credit, holders, submit          |
# | mortgage | compound | 0       | 0        | account, Credit, holders, submit |
# | account  | conj     | 1       | 0        | Credit, holders, submit          |
# | holders  | nsubj    | 1       | 0        | submit                           |
# +----------+----------+---------+----------+----------------------------------+
