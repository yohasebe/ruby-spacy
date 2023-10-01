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

res2 = doc.openai_query(access_token: api_key, prompt: "Elaborate on the statement in the text")

puts res2

# The statement refers to the fact that The Beatles, an iconic British rock band formed in 1960, released 12 original studio albums during their active years. This does not include live albums, compilations, EPs, or post-breakup releases. Their studio albums, which were all commercial successes, feature some of their most famous songs and have had a major influence on popular music. The 12 studio albums include:

# 1. Please Please Me (1963)
# 2. With the Beatles (1963)
# 3. A Hard Day’s Night (1964)
# 4. Beatles for Sale (1964)
# 5. Help! (1965)
# 6. Rubber Soul (1965)
# 7. Revolver (1966)
# 8. Sgt. Pepper’s Lonely Hearts Club Band (1967)
# 9. The Beatles (also known as the White Album) (1968)
# 10. Yellow Submarine (1969)
# 11. Abbey Road (1969)
# 12. Let It Be (1970)

# Each album showcased the band’s evolving musical style and lyrical sophistication, ranging from their early rock and roll sound to the more experimental and complex compositions in their later years.

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
