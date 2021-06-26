require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "私の父は寿司が好きだ。"
doc = nlp.read(sentence)

headings = ["text", "dep", "n_lefts", "n_rights", "ancestors"]
rows = []

root = doc.tokens.select do |t|
  # need to compare token and its head using their indices
  t.i == t.head.i
end.first

puts "The sentence: " + sentence

# subject = Spacy::Token.new(root.lefts[0])
subject = Spacy::Token.new(root.lefts[0])

puts "The root of the sentence is: " + root.text
puts "The subject of the sentence is: " + subject.text

subject.subtree.each do |descendant|
  # need to convert "ancestors" object from a python generator to a ruby array
  ancestors = Spacy::generator_to_array(descendant.ancestors)
  rows << [descendant.text, descendant.dep_, descendant.n_lefts, descendant.n_rights, ancestors]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# The sentence: 私の父は寿司が好きだ。
# The root of the sentence is: 好き
# The subject of the sentence is: 父
# +------+------------+---------+----------+----------------+
# | text | dep        | n_lefts | n_rights | ancestors      |
# +------+------------+---------+----------+----------------+
# | 私   | nmod       | 0       | 1        | [父, 好き]     |
# | の   | case       | 0       | 0        | [私, 父, 好き] |
# | 父   | dislocated | 1       | 1        | [好き]         |
# | は   | case       | 0       | 0        | [父, 好き]     |
# +------+------------+---------+----------+----------------+
