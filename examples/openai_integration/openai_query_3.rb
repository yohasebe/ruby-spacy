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
# model: "gpt-3.5-turbo-0613"
res = doc.openai_query(access_token: api_key, prompt: "List detailed morphology data of each of the word used in the sentence")

puts res

# Here is the detailed morphology data for each word in the sentence:
# 
# 1. Token: "The"
#    - Surface: "The"
#    - Lemma: "the"
#    - Part-of-speech: Determiner (DET)
#    - Tag: DT
#    - Dependency: Determiner (det)
#    - Entity type: None
#    - Morphology: {'Definite': 'Def', 'PronType': 'Art'}
# 
# 2. Token: "Beatles"
#    - Surface: "Beatles"
#    - Lemma: "beatle"
#    - Part-of-speech: Noun (NOUN)
#    - Tag: NNS
#    - Dependency: Noun subject (nsubj)
#    - Entity type: GPE (Geopolitical Entity)
#    - Morphology: {'Number': 'Plur'}
# 
# 3. Token: "released"
#    - Surface: "released"
#    - Lemma: "release"
#    - Part-of-speech: Verb (VERB)
#    - Tag: VBD
#    - Dependency: Root
#    - Entity type: None
#    - Morphology: {'Tense': 'Past', 'VerbForm': 'Fin'}
# 
# 4. Token: "12"
#    - Surface: "12"
#    - Lemma: "12"
#    - Part-of-speech: Numeral (NUM)
#    - Tag: CD
#    - Dependency: Numeric modifier (nummod)
#    - Entity type: Cardinal number (CARDINAL)
#    - Morphology: {'NumType': 'Card'}
# 
# 5. Token: "studio"
#    - Surface: "studio"
#    - Lemma: "studio"
#    - Part-of-speech: Noun (NOUN)
#    - Tag: NN
#    - Dependency: Compound
#    - Entity type: None
#    - Morphology: {'Number': 'Sing'}
# 
# 6. Token: "albums"
#    - Surface: "albums"
#    - Lemma: "album"
#    - Part-of-speech: Noun (NOUN)
#    - Tag: NNS
#    - Dependency: Direct object (dobj)
#    - Entity type: None
#    - Morphology: {'Number': 'Plur'}
