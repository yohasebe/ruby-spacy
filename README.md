# 💎 ruby-spacy

## Overview 

**ruby-spacy** is a wrapper module for using [spaCy](https://spacy.io/) from the Ruby programming language via [PyCall](https://github.com/mrkn/pycall.rb). This module aims to make it easy and natural for Ruby programmers to use spaCy. This module covers the areas of spaCy functionality for _using_ many varieties of its language models, not for _building_ ones.

|    | Functionality                                      |
|:---|:---------------------------------------------------|
| ✅ | Tokenization, lemmatization, sentence segmentation |
| ✅ | Part-of-speech tagging and dependency parsing      |
| ✅ | Named entity recognition                           |
| ✅ | Syntactic dependency visualization                 |
| ✅ | Access to pre-trained word vectors                 |
| ✅ | OpenAI Chat/Completion/Embeddings API integration  |

Current Version: `0.2.2`

- Addressed installation issues in some environments

## Installation of prerequisites

**IMPORTANT**: Make sure that the `enable-shared` option is enabled in your Python installation. You can use [pyenv](https://github.com/pyenv/pyenv) to install any version of Python you like. Install Python 3.10.6, for instance, using pyenv with `enable-shared` as follows:

```shell
$ env CONFIGURE_OPTS="--enable-shared" pyenv install 3.10.6
```

Remember to make it accessible from your working directory. It is recommended that you set `global` to the version of python you just installed.

```shell
$ pyenv global 3.10.6 
```

Then, install [spaCy](https://spacy.io/). If you use `pip`, the following command will do:

```shell
$ pip install spacy
```

⚠️ **Note**: The ruby-spacy visualization feature currently only works if spaCy 3.6.x is installed, not if the latest version, 3.7, is installed. To install spaCy 3.6.x instead, do the following:

```shell
$ pip install 'spaCy<3.7'
```

Install trained language models. For a starter, `en_core_web_sm` will be the most useful to conduct basic text processing in English. However, if you want to use advanced features of spaCy, such as named entity recognition or document similarity calculation, you should also install a larger model like `en_core_web_lg`.


```shell
$ python -m spacy download en_core_web_sm
$ python -m spacy download en_core_web_lg
```

See [Spacy: Models & Languages](https://spacy.io/usage/models) for other models in various languages. To install models for the Japanese language, for instance, you can do it as follows:

```shell
$ python -m spacy download ja_core_news_sm
$ python -m spacy download ja_core_news_lg
```

## Installation of ruby-spacy

Add this line to your application's Gemfile:

```ruby
gem 'ruby-spacy'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ruby-spacy

## Usage

See [Examples](#examples) below.

## Examples

Many of the following examples are Python-to-Ruby translations of code snippets in [spaCy 101](https://spacy.io/usage/spacy-101). For more examples, look inside the `examples` directory.

### Tokenization

→ [spaCy: Tokenization](https://spacy.io/usage/spacy-101#annotations-token)

Ruby code: 

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")

doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

row = []

doc.each do |token|
  row << token.text
end

headings = [1,2,3,4,5,6,7,8,9,10]
table = Terminal::Table.new rows: [row], headings: headings

puts table
```

Output:

| 1     | 2  | 3       | 4  | 5      | 6    | 7       | 8   | 9 | 10 | 11      |
|:-----:|:--:|:-------:|:--:|:------:|:----:|:-------:|:---:|:-:|:--:|:-------:|
| Apple | is | looking | at | buying | U.K. | startup | for | $ | 1  | billion |

### Part-of-speech and dependency

→ [spaCy: Part-of-speech tags and dependencies](https://spacy.io/usage/spacy-101#annotations-pos-deps)

Ruby code: 

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text", "lemma", "pos", "tag", "dep"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma, token.pos, token.tag, token.dep]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
```

Output:

| text    | lemma   | pos   | tag | dep      |
|:--------|:--------|:------|:----|:---------|
| Apple   | Apple   | PROPN | NNP | nsubj    |
| is      | be      | AUX   | VBZ | aux      |
| looking | look    | VERB  | VBG | ROOT     |
| at      | at      | ADP   | IN  | prep     |
| buying  | buy     | VERB  | VBG | pcomp    |
| U.K.    | U.K.    | PROPN | NNP | dobj     |
| startup | startup | NOUN  | NN  | advcl    |
| for     | for     | ADP   | IN  | prep     |
| $       | $       | SYM   | $   | quantmod |
| 1       | 1       | NUM   | CD  | compound |
| billion | billion | NUM   | CD  | pobj     |

### Part-of-speech and dependency (Japanese)

Ruby code: 

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")
doc = nlp.read("任天堂は1983年にファミコンを14,800円で発売した。")

headings = ["text", "lemma", "pos", "tag", "dep"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma, token.pos, token.tag, token.dep]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
```

Output:

| text       | lemma      | pos   | tag                      | dep    |
|:-----------|:-----------|:------|:-------------------------|:-------|
| 任天堂     | 任天堂     | PROPN | 名詞-固有名詞-一般       | nsubj  |
| は         | は         | ADP   | 助詞-係助詞              | case   |
| 1983       | 1983       | NUM   | 名詞-数詞                | nummod |
| 年         | 年         | NOUN  | 名詞-普通名詞-助数詞可能 | obl    |
| に         | に         | ADP   | 助詞-格助詞              | case   |
| ファミコン | ファミコン | NOUN  | 名詞-普通名詞-一般       | obj    |
| を         | を         | ADP   | 助詞-格助詞              | case   |
| 14,800     | 14,800     | NUM   | 名詞-数詞                | fixed  |
| 円         | 円         | NOUN  | 名詞-普通名詞-助数詞可能 | obl    |
| で         | で         | ADP   | 助詞-格助詞              | case   |
| 発売       | 発売       | VERB  | 名詞-普通名詞-サ変可能   | ROOT   |
| し         | する       | AUX   | 動詞-非自立可能          | aux    |
| た         | た         | AUX   | 助動詞                   | aux    |
| 。         | 。         | PUNCT | 補助記号-句点            | punct  |

### Morphology 

→ [POS and morphology tags](https://github.com/explosion/spaCy/blob/master/spacy/glossary.py)

Ruby code:

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text", "shape", "is_alpha", "is_stop", "morphology"]
rows = []

doc.each do |token|
  morph = token.morphology.map do |k, v|
    "#{k} = #{v}"
  end.join("\n")
  rows << [token.text, token.shape, token.is_alpha, token.is_stop, morph]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table

```

Output:

| text    | shape | is_alpha | is_stop | morphology                                                                          |
|:--------|:------|:---------|:--------|:------------------------------------------------------------------------------------|
| Apple   | Xxxxx | true     | false   | NounType = Prop<br />Number = Sing                                                  |
| is      | xx    | true     | true    | Mood = Ind<br />Number = Sing<br />Person = 3<br />Tense = Pres<br />VerbForm = Fin |
| looking | xxxx  | true     | false   | Aspect = Prog<br />Tense = Pres<br />VerbForm = Part                                |
| at      | xx    | true     | true    |                                                                                     |
| buying  | xxxx  | true     | false   | Aspect = Prog<br />Tense = Pres<br />VerbForm = Part                                |
| U.K.    | X.X.  | false    | false   | NounType = Prop<br />Number = Sing                                                  |
| startup | xxxx  | true     | false   | Number = Sing                                                                       |
| for     | xxx   | true     | true    |                                                                                     |
| $       | $     | false    | false   |                                                                                     |
| 1       | d     | false    | false   | NumType = Card                                                                      |
| billion | xxxx  | true     | false   | NumType = Card                                                                      |

### Visualizing dependency

⚠️ **Note**: This feature currently only works on spaCy 3.6 (not on 3.7)

→ [spaCy: Visualizers](https://spacy.io/usage/visualizers)

Ruby code: 

```ruby
require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "Autonomous cars shift insurance liability toward manufacturers"
doc = nlp.read(sentence)

dep_svg = doc.displacy(style: "dep", compact: false)

File.open(File.join("test_dep.svg"), "w") do |file|
  file.write(dep_svg)
end
```

Output:

![](https://github.com/yohasebe/ruby-spacy/blob/main/examples/get_started/outputs/test_dep.svg)

### Visualizing dependency (compact)

⚠️ **Note**: This feature currently only works on spaCy 3.6 (not on 3.7)

Ruby code: 

```ruby
require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")

sentence = "Autonomous cars shift insurance liability toward manufacturers"
doc = nlp.read(sentence)

dep_svg = doc.displacy(style: "dep", compact: true)

File.open(File.join("test_dep_compact.svg"), "w") do |file|
  file.write(dep_svg)
end
```

Output:

![](https://github.com/yohasebe/ruby-spacy/blob/main/examples/get_started/outputs/test_dep_compact.svg)

### Named entity recognition

→ [spaCy: Named entities](https://spacy.io/usage/spacy-101#annotations-ner)

Ruby code: 

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc =nlp.read("Apple is looking at buying U.K. startup for $1 billion")

rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label]
end

headings = ["text", "start_char", "end_char", "label"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

Output:

| text       | start_char | end_char | label |
|:-----------|-----------:|---------:|:------|
| Apple      | 0          | 5        | ORG   |
| U.K.       | 27         | 31       | GPE   |
| $1 billion | 44         | 54       | MONEY |

### Named entity recognition (Japanese)

Ruby code: 

```ruby
require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "任天堂は1983年にファミコンを14,800円で発売した。"
doc = nlp.read(sentence)

rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label]
end

headings = ["text", "start", "end", "label"]
table = Terminal::Table.new rows: rows, headings: headings
print table
```

Output:

| text       | start | end | label   |
|:-----------|------:|----:|:--------|
| 任天堂     | 0     | 3   | ORG     |
| 1983年     | 4     | 9   | DATE    |
| ファミコン | 10    | 15  | PRODUCT |
| 14,800円   | 16    | 23  | MONEY   |

### Checking availability of word vectors

→ [spaCy: Word vectors and similarity](https://spacy.io/usage/spacy-101#vectors-similarity)

Ruby code: 

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")
doc = nlp.read("dog cat banana afskfsd")

rows = []

doc.each do |token|
  rows << [token.text, token.has_vector, token.vector_norm, token.is_oov]
end

headings = ["text", "has_vector", "vector_norm", "is_oov"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

Output:

| text    | has_vector | vector_norm | is_oov |
|:--------|:-----------|:------------|:-------|
| dog     | true       | 7.0336733   | false  |
| cat     | true       | 6.6808186   | false  |
| banana  | true       | 6.700014    | false  |
| afskfsd | false      | 0.0         | true   |

### Similarity calculation

Ruby code: 

```ruby
require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_lg")
doc1 = nlp.read("I like salty fries and hamburgers.")
doc2 = nlp.read("Fast food tastes very good.")

puts "Doc 1: " + doc1.text
puts "Doc 2: " + doc2.text
puts "Similarity: #{doc1.similarity(doc2)}"

```

Output:

```text
Doc 1: I like salty fries and hamburgers.
Doc 2: Fast food tastes very good.
Similarity: 0.7687607012190486
```

### Similarity calculation (Japanese)

Ruby code: 

```ruby
require "ruby-spacy"

nlp = Spacy::Language.new("ja_core_news_lg")
ja_doc1 = nlp.read("今日は雨ばっかり降って、嫌な天気ですね。")
puts "doc1: #{ja_doc1.text}"
ja_doc2 = nlp.read("あいにくの悪天候で残念です。")
puts "doc2: #{ja_doc2.text}"
puts "Similarity: #{ja_doc1.similarity(ja_doc2)}"
```

Output:

```text
doc1: 今日は雨ばっかり降って、嫌な天気ですね。
doc2: あいにくの悪天候で残念です。
Similarity: 0.8684192637149641
```

### Word vector calculation

**Tokyo - Japan + France = Paris ?**

Ruby code: 

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")

tokyo = nlp.get_lexeme("Tokyo")
japan = nlp.get_lexeme("Japan")
france = nlp.get_lexeme("France")

query = tokyo.vector - japan.vector + france.vector

headings = ["rank", "text", "score"]
rows = []

results = nlp.most_similar(query, 10)
results.each_with_index do |lexeme, i|
  index = (i + 1).to_s
  rows << [index, lexeme.text, lexeme.score]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
```

Output:

| rank | text        | score              |
|:-----|:------------|:-------------------|
| 1    | FRANCE      | 0.8346999883651733 |
| 2    | France      | 0.8346999883651733 |
| 3    | france      | 0.8346999883651733 |
| 4    | PARIS       | 0.7703999876976013 |
| 5    | paris       | 0.7703999876976013 |
| 6    | Paris       | 0.7703999876976013 |
| 7    | TOULOUSE    | 0.6381999850273132 |
| 8    | Toulouse    | 0.6381999850273132 |
| 9    | toulouse    | 0.6381999850273132 |
| 10   | marseille   | 0.6370999813079834 |


### Word vector calculation (Japanese)

**東京 - 日本 + フランス = パリ ?**

Ruby code: 

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

tokyo = nlp.get_lexeme("東京")
japan = nlp.get_lexeme("日本")
france = nlp.get_lexeme("フランス")

query = tokyo.vector - japan.vector + france.vector

headings = ["rank", "text", "score"]
rows = []

results = nlp.most_similar(query, 10)
results.each_with_index do |lexeme, i|
  index = (i + 1).to_s
  rows << [index, lexeme.text, lexeme.score]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
```

Output:

| rank | text           | score              |
|:-----|:---------------|:-------------------|
| 1    | パリ           | 0.7376999855041504 |
| 2    | フランス       | 0.7221999764442444 |
| 3    | 東京           | 0.6697999835014343 |
| 4    | ストラスブール | 0.631600022315979  |
| 5    | リヨン         | 0.5939000248908997 |
| 6    | Paris          | 0.574400007724762  |
| 7    | ベルギー       | 0.5683000087738037 |
| 8    | ニース         | 0.5679000020027161 |
| 9    | アルザス       | 0.5644999742507935 |
| 10   | 南仏           | 0.5547999739646912 |


## OpenAI API Integration

Easily leverage GPT models within ruby-spacy by using an OpenAI API key. When constructing prompts for the `Doc::openai_query` method, you can incorporate various token properties from the document. These properties are retrieved through function calls and seamlessly integrated into your prompt (`gpt-3.5-turbo-0613` or greater is needed). The available properties include:

- `surface`
- `lemma`
- `tag`
- `pos` (part of speech)
- `dep` (dependency)
- `ent_type` (entity type)
- `morphology`

### GPT Prompting 1

Ruby code:

```ruby

require "ruby-spacy"

api_key = ENV["OPENAI_API_KEY"]
nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("The Beatles released 12 studio albums")

# default parameter values
# max_tokens: 1000
# temperature: 0.7
# model: "gpt-3.5-turbo-0613"
res1 = doc.openai_query(
  access_token: api_key,
  prompt: "Translate the text to Japanese."
)
puts res1
```

Output:

> ビートルズは12枚のスタジオアルバムをリリースしました。

### GPT Prompting 2

Ruby code: 

```ruby
require "ruby-spacy"

api_key = ENV["OPENAI_API_KEY"]
nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("The Beatles released 12 studio albums")

res = doc.openai_query(
  access_token: api_key,
  prompt: "Extract the topic of the document and list five entities, including the topic itself, that can be considered highly relevant to that topic."
)
```

Output:

> Topic: The Beatles' studio albums
> 
> Relevant entities:
> 1. The Beatles
> 2. Studio albums
> 3. Music
> 4. Band
> 5. Rock music
> 6. Pop music
> 7. John Lennon
> 8. Paul McCartney
> 9. George Harrison
> 10. Ringo Starr

### GPT Prompting 3

Ruby code: 

```ruby
require "ruby-spacy"

api_key = ENV["OPENAI_API_KEY"]
nlp = Spacy::Language.new("en_core_web_sm")

res = doc.openai_query(
  access_token: api_key,
  model: "gpt-4",
  prompt: "Generate a tree diagram from the text in the following style: [S [NP [Det the] [N cat]] [VP [V sat] [PP [P on] [NP the mat]]]"
)
puts res
```

Output:

```
[S
  [NP
    [Det The]
    [N Beatles]
  ]
  [VP
    [V released]
    [NP
      [Num 12]
      [N
        [N studio]
        [N albums]
      ]
    ]
  ]
]
```

### GPT Text Completion

Ruby code:

```ruby
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
```

Output:

> Russian-American novelist and lepidopterist. He was born in 1899 in St. Petersburg, Russia, and later emigrated to the United States in 1940. Nabokov is best known for his novel "Lolita," which was published in 1955 and caused much controversy due to its controversial subject matter. Throughout his career, Nabokov wrote many other notable works, including "Pale Fire" and "Ada or Ardor: A Family Chronicle." In addition to his writing, Nabokov was also a passionate butterfly collector and taxonomist, publishing several scientific papers on the subject. He passed away in 1977, leaving behind a rich literary legacy.

### Text Embeddings

Ruby code:

```ruby
require "ruby-spacy"

api_key = ENV["OPENAI_API_KEY"]
nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Vladimir Nabokov was a Russian-American novelist, poet, translator and entomologist.")

# default model: text-embedding-ada-002
res = doc.openai_embeddings(access_token: api_key)

puts res
```

Output:

```
-0.00208362
-0.01645165
 0.0110955965
 0.012802119
 0.0012175755
 ...
```

## Author

Yoichiro Hasebe [<yohasebe@gmail.com>]


## Acknowlegments

I would like to thank the following open source projects and their creators for making this project possible:

- [explosion/spaCy](https://github.com/explosion/spaCy)
- [mrkn/pycall.rb](https://github.com/mrkn/pycall.rb)

## License

This library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
