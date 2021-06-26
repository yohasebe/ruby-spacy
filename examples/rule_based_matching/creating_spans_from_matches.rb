require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")
matcher = nlp.matcher
matcher.add("US_PRESIDENT", [[{LOWER: "barack"}, {LOWER: "obama"}]])
doc = nlp.read("Barack Obama was the 44th president of the United States")

matches = matcher.match(doc)

matches.each do |match|
  span = Spacy::Span.new(doc, start_index: match[:start_index], end_index: match[:end_index], options: {label: match[:match_id]})
  puts span.text + " / " + span.label_
end

# Barack Obama / US_PRESIDENT
