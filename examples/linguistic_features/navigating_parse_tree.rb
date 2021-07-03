require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

lemmatizer = nlp.get_pipe("lemmatizer")
puts "Lemmatizer mode: " + lemmatizer.mode

doc = nlp.read("Autonomous cars shift insurance liability toward manufacturers")

headings = ["text", "dep", "head text", "head pos", "children"]
rows = []

doc.each do |token|
  rows << [token.text, token.dep, token.head.text, token.head.pos, token.children.map(&:text).join(", ")]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# Lemmatizer mode: rule
# +---------------+----------+-----------+----------+-------------------------+
# | text          | dep      | head text | head pos | children                |
# +---------------+----------+-----------+----------+-------------------------+
# | Autonomous    | amod     | cars      | NOUN     |                         |
# | cars          | nsubj    | shift     | VERB     | Autonomous              |
# | shift         | ROOT     | shift     | VERB     | cars, liability, toward |
# | insurance     | compound | liability | NOUN     |                         |
# | liability     | dobj     | shift     | VERB     | insurance               |
# | toward        | prep     | shift     | VERB     | manufacturers           |
# | manufacturers | pobj     | toward    | ADP      |                         |
# +---------------+----------+-----------+----------+-------------------------+
