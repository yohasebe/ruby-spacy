# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

api_key = ENV["OPENAI_API_KEY"]
nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("The Beatles were an English rock band formed in Liverpool in 1960.")

# default parameter values
# max_tokens: 1000
# temperature: 0.7
# model: "gpt-4o-mini"
res = doc.openai_query(access_token: api_key, prompt: "Extract the topic of the document and list 10 entities (names, concepts, locations, etc.) that are relevant to the topic.")

puts res

# Topic: The Beatles
# 
# Entities:
# 1. The Beatles (band)
# 2. English (nationality)
# 3. Rock band
# 4. Liverpool (city)
# 5. 1960 (year)
# 6. John Lennon (member)
# 7. Paul McCartney (member)
# 8. George Harrison (member)
# 9. Ringo Starr (member)
# 10. Music
