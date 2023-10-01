# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")
matcher = nlp.matcher
matcher.add("US_PRESIDENT", [[{ LOWER: "barack" }, { LOWER: "obama" }]])
doc = nlp.read("Barack Obama was the 44th president of the United States")

matches = matcher.match(doc)

matches.each do |match|
  span = Spacy::Span.new(doc, start_index: match[:start_index], end_index: match[:end_index], options: { label: match[:match_id] })
  puts "#{span.text} / #{span.label}"
end

# Barack Obama / US_PRESIDENT
