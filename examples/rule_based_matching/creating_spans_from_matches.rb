require("./lib/ruby-spacy")
require 'terminal-table'

nlp = Spacy::Language.new("en_core_web_lg")
matcher = nlp.matcher
matcher.add("US_PRESIDENT", [[{LOWER: "barack"}, {LOWER: "obama"}]])
doc = nlp.read("Barack Obama was the 44th president of the United States")

# 1. Return (match_id, start, end) tuples
matches = matcher.match(doc)

matches.each do |match|
  match_id, range = match
  span = Spacy::Span.new(doc, range, {label: match_id})
  puts span.text + " / " + span.label_
end
