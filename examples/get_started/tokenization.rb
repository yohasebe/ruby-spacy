require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = [1,2,3,4,5,6,7,8,9,10,11]
row = []

doc.each do |token|
  row << token.text
end

table = Terminal::Table.new rows: [row], headings: headings
puts table

# +-------+----+---------+----+--------+------+---------+-----+---+----+---------+
# | 1     | 2  | 3       | 4  | 5      | 6    | 7       | 8   | 9 | 10 | 11      |
# +-------+----+---------+----+--------+------+---------+-----+---+----+---------+
# | Apple | is | looking | at | buying | U.K. | startup | for | $ | 1  | billion |
# +-------+----+---------+----+--------+------+---------+-----+---+----+---------+
