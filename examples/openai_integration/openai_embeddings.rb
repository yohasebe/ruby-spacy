# frozen_string_literal: true

require "ruby-spacy"

api_key = ENV["OPENAI_API_KEY"]
nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Vladimir Nabokov was a Russian-American novelist, poet, translator and entomologist.")

# default model : text-embedding-ada-002
res = doc.openai_embeddings(access_token: api_key)

puts res

# -0.00208362
# -0.01645165
# 0.0110955965
# 0.012802119
# 0.0012175755
# ...
