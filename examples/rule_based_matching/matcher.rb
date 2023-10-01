# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")

pattern = [[{ LOWER: "hello" }, { IS_PUNCT: true }, { LOWER: "world" }]]

matcher = nlp.matcher
matcher.add("HelloWorld", pattern)

doc = nlp.read("Hello, world! Hello world!")
matches = matcher.match(doc)

matches.each do |match|
  string_id = nlp.vocab_string_lookup(match[:match_id])
  span = doc.span(match[:start_index]..match[:end_index])
  puts "#{string_id}, #{span.text}"
end

# HelloWorld, Hello, world
