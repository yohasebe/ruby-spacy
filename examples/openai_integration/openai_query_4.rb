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
res = doc.openai_query(
  access_token: api_key,
  model: "gpt-4",
  prompt: "Generate a tree diagram from the text using given token data. Use the following bracketing style: [S [NP [Det the] [N cat]] [VP [V sat] [PP [P on] [NP the mat]]]"
)

puts res

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
