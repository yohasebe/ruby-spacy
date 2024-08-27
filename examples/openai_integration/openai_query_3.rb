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
res = doc.openai_query(
  access_token: api_key,
  prompt: "List token data of each of the words used in the sentence. Add 'meaning' property and value (brief semantic definition) to each token data. Output as a JSON object.",
  max_tokens: 1000,
  temperature: 0.7,
  model: "gpt-4o-mini"
)

puts res

# {
#   "tokens": [
#     {
#       "surface": "The",
#       "lemma": "the",
#       "pos": "DET",
#       "tag": "DT",
#       "dep": "det",
#       "ent_type": "",
#       "morphology": "{'Definite': 'Def', 'PronType': 'Art'}",
#       "meaning": "Used to refer to one or more people or things already mentioned or assumed to be common knowledge"
#     },
#     {
#       "surface": "Beatles",
#       "lemma": "beatle",
#       "pos": "NOUN",
#       "tag": "NNS",
#       "dep": "nsubj",
#       "ent_type": "GPE",
#       "morphology": "{'Number': 'Plur'}",
#       "meaning": "A British rock band formed in Liverpool in 1960"
#     },
#     {
#       "surface": "released",
#       "lemma": "release",
#       "pos": "VERB",
#       "tag": "VBD",
#       "dep": "ROOT",
#       "ent_type": "",
#       "morphology": "{'Tense': 'Past', 'VerbForm': 'Fin'}",
#       "meaning": "To make something available or known to the public"
#     },
#     {
#       "surface": "12",
#       "lemma": "12",
#       "pos": "NUM",
#       "tag": "CD",
#       "dep": "nummod",
#       "ent_type": "CARDINAL",
#       "morphology": "{'NumType': 'Card'}",
#       "meaning": "A number representing a quantity"
#     },
#     {
#       "surface": "studio",
#       "lemma": "studio",
#       "pos": "NOUN",
#       "tag": "NN",
#       "dep": "compound",
#       "ent_type": "",
#       "morphology": "{'Number': 'Sing'}",
#       "meaning": "A place where creative work is done"
#     },
#     {
#       "surface": "albums",
#       "lemma": "album",
#       "pos": "NOUN",
#       "tag": "NNS",
#       "dep": "dobj",
#       "ent_type": "",
#       "morphology": "{'Number': 'Plur'}",
#       "meaning": "A collection of musical or spoken recordings"
#     }
#   ]
# }
