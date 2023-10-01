# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

api_key = ENV["OPENAI_API_KEY"]
nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Vladimir Nabokov was a")

# default parameter values
# max_tokens: 1000
# temperature: 0.7
# model: "gpt-3.5-turbo-0613"
res = doc.openai_completion(access_token: api_key)
puts res

# Russian-American novelist and lepidopterist. He was born in 1899 in St. Petersburg, Russia, and later emigrated to the United States in 1940. Nabokov is best known for his novel "Lolita," which was published in 1955 and caused much controversy due to its controversial subject matter. Throughout his career, Nabokov wrote many other notable works, including "Pale Fire" and "Ada or Ardor: A Family Chronicle." In addition to his writing, Nabokov was also a passionate butterfly collector and taxonomist, publishing several scientific papers on the subject. He passed away in 1977, leaving behind a rich literary legacy.
