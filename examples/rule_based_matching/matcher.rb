require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")

pattern = [[{LOWER: "hello"}, {IS_PUNCT: true}, {LOWER: "world"}]]

matcher = nlp.matcher
matcher.add("HelloWorld", pattern)

doc = nlp.read("Hello, world! Hello world!")
matches = matcher.match(doc)

matches.each do | match_id, range |
  string_id = nlp.vocab_string_lookup(match_id)
  span = doc.span(range)
  puts "#{match_id}, #{string_id}, #{range.to_s}, #{span.text}"
end

