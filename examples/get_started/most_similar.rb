require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")

tokyo = nlp.get_lexeme("Tokyo")
japan = nlp.get_lexeme("Japan")
france = nlp.get_lexeme("France")

query = tokyo.vector - japan.vector + france.vector

headings = ["key", "text", "score"]
rows = []

results = nlp.most_similar(query, 20)
results.each do |lexeme|
  rows << [lexeme[:key], lexeme[:text], lexeme[:score],]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

# +----------------------+-------------+--------------------+
# | key                  | text        | score              |
# +----------------------+-------------+--------------------+
# | 1432967385481565694  | FRANCE      | 0.8346999883651733 |
# | 6613816697677965370  | France      | 0.8346999883651733 |
# | 4362406852232399325  | france      | 0.8346999883651733 |
# | 1637573253267610771  | PARIS       | 0.7703999876976013 |
# | 15322182186497800017 | paris       | 0.7703999876976013 |
# | 10427160276079242800 | Paris       | 0.7703999876976013 |
# | 975948890941980630   | TOULOUSE    | 0.6381999850273132 |
# | 7944504257273452052  | Toulouse    | 0.6381999850273132 |
# | 9614730213792621885  | toulouse    | 0.6381999850273132 |
# | 8515538464606421210  | marseille   | 0.6370999813079834 |
# | 8215995793762630878  | Marseille   | 0.6370999813079834 |
# | 12360854743603227406 | MARSEILLE   | 0.6370999813079834 |
# | 8339539946446536307  | Bordeaux    | 0.6096000075340271 |
# | 17690237501437860177 | BORDEAUX    | 0.6096000075340271 |
# | 13936807859007616770 | bordeaux    | 0.6096000075340271 |
# | 8731576325682930212  | prague      | 0.6075000166893005 |
# | 11722746441803481839 | PRAGUE      | 0.6075000166893005 |
# | 1133963107690000953  | Prague      | 0.6075000166893005 |
# | 16693216792428069950 | SWITZERLAND | 0.6068000197410583 |
# | 6936121537367717968  | switzerland | 0.6068000197410583 |
# +----------------------+-------------+--------------------+
