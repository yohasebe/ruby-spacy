require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")

tokyo = nlp.get_lexeme("Tokyo")
japan = nlp.get_lexeme("Japan")
france = nlp.get_lexeme("France")

query = tokyo.vector - japan.vector + france.vector

headings = ["rank", "text", "score"]
rows = []

results = nlp.most_similar(query, 20)
results.each_with_index do |lexeme, i|
  index = (i + 1).to_s
  rows << [index, lexeme.text, lexeme.score]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +------+-------------+--------------------+
# | rank | text        | score              |
# +------+-------------+--------------------+
# | 1    | FRANCE      | 0.8346999883651733 |
# | 2    | France      | 0.8346999883651733 |
# | 3    | france      | 0.8346999883651733 |
# | 4    | PARIS       | 0.7703999876976013 |
# | 5    | paris       | 0.7703999876976013 |
# | 6    | Paris       | 0.7703999876976013 |
# | 7    | TOULOUSE    | 0.6381999850273132 |
# | 8    | Toulouse    | 0.6381999850273132 |
# | 9    | toulouse    | 0.6381999850273132 |
# | 10   | marseille   | 0.6370999813079834 |
# | 11   | Marseille   | 0.6370999813079834 |
# | 12   | MARSEILLE   | 0.6370999813079834 |
# | 13   | Bordeaux    | 0.6096000075340271 |
# | 14   | BORDEAUX    | 0.6096000075340271 |
# | 15   | bordeaux    | 0.6096000075340271 |
# | 16   | prague      | 0.6075000166893005 |
# | 17   | PRAGUE      | 0.6075000166893005 |
# | 18   | Prague      | 0.6075000166893005 |
# | 19   | SWITZERLAND | 0.6068000197410583 |
# | 20   | switzerland | 0.6068000197410583 |
# +------+-------------+--------------------+
