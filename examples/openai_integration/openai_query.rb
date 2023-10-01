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
res1 = doc.openai_query(access_token: api_key, prompt: "Translate the text to Japanese.")

puts res1

# ビートルズは12枚のスタジオアルバムをリリースしました。

res2 = doc.openai_query(access_token: api_key, prompt: "Extract the topic of the document and list up to 10 entities (names, concepts, locations, etc.) that are considered highly relevant to it.")

puts res2

# Topic: The Beatles' studio albums
# 
# Entities:
# 1. The Beatles
# 2. Studio albums
# 3. Music
# 4. Band
# 5. John Lennon
# 6. Paul McCartney
# 7. George Harrison
# 8. Ringo Starr
# 9. Abbey Road Studios
# 10. Rock music

res3 = doc.openai_query(
  access_token: api_key,
  model: "gpt-4",
  prompt: "Generate a tree diagram from the text in the following style: [S [NP [Det the] [N cat]] [VP [V sat] [PP [P on] [NP the mat]]]"
)

puts res3

# [S
#   [NP
#     [Det The]
#     [N Beatles]
#   ]
#   [VP
#     [V released]
#     [NP
#       [Num 12]
#       [N
#         [N studio]
#         [N albums]
#       ]
#     ]
#   ]
# ]
