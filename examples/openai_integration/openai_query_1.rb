# frozen_string_literal: true

# add path to ruby-spacy lib to load path
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "ruby-spacy"

api_key = ENV["OPENAI_API_KEY"]
nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("The Beatles released 12 studio albums")

# default parameter values
# max_tokens: 1000
# temperature: 0.7
# model: "gpt-4o-mini"
res = doc.openai_query(access_token: api_key, prompt: "Translate the text to Japanese.")

puts res

# ビートルズは12枚のスタジオアルバムをリリースしました。
