# ruby-spacy

A wrapper module for using [spaCy](https://spacy.io/) natural language processing library from the Ruby programming language using PyCall

----

## Preparation

To use `ruby-spacy`, which uses [PyCall](https://github.com/mrkn/pycall.rb), make sure that the `enable-shared` option is enabled in your Python installation. You can use [pyenv](https://github.com/pyenv/pyenv) to install any version of Python you like. Do it as follows to install Python 3.5.9 for instance:

```shell
$ env CONFIGURE_OPTS="--enable-shared" pyenv install 3.8.5
```

If you use the python installation locally:

```shell
$ pyenv local 3.8.5 
```

Or if you use the python installation globally:

```shell
$ pyenv global 3.8.5 
```

Then, you can install [spaCy](https://spacy.io/) in any way you like. For example, if you use `pip`, you can do the following.

```shell
$ pip install spacy
```

Then install trained models/pipelines. For a starter, `en_core_web_sm` is useful to process text in English. (If you use word vector functionalites of spaCy, also install `en_core_web_lg`)

```shell
$ python -m spacy download en_core_web_sm
```
See [Spacy: Models & Languages](https://spacy.io/usage/models) for models in other languages. To install a large model for the Japanese language, for instance, download the package as follows:

```shell
$ python -m spacy download ja_core_news_lg
```

----

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-spacy'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ruby-spacy

----

## Usage

See Examples below.

----

## Examples

The following are basically Python to Ruby translations of examples from [spaCy 101](https://spacy.io/usage/spacy-101). <u>For more examples, look inside the `examples` folder.</u>

### Tokenization

→ [spaCy 101](https://spacy.io/usage/spacy-101#annotations-token)

**Tokenization Example**

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

**Output**

| 1     | 2  | 3       | 4  | 5      | 6    | 7       | 8   | 9 | 10 | 11      |
|:-----:|:--:|:-------:|:--:|:------:|:----:|:-------:|:---:|:-:|:--:|:-------:|
| Apple | is | looking | at | buying | U.K. | startup | for | $ | 1  | billion |

### Part-of-speech Tags and Dependencies

→ [spaCy 101](https://spacy.io/usage/spacy-101#annotations-pos-deps)

**POS Example**

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc = nlp.read("Apple is looking at buying U.K. startup for $1 billion")

rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_, token.shape_, token.is_alpha, token.is_stop]
end

headings = ["text", "lemma", "pos", "tag", "dep", "shape", "is_alpha", "is_stop"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

**Output**

| text    | lemma   | pos   | tag | dep      | shape | is_alpha | is_stop |
|:--------|:--------|:------|:----|:---------|:------|:---------|:--------|
| Apple   | Apple   | PROPN | NNP | nsubj    | Xxxxx | true     | false   |
| is      | be      | AUX   | VBZ | aux      | xx    | true     | true    |
| looking | look    | VERB  | VBG | ROOT     | xxxx  | true     | false   |
| at      | at      | ADP   | IN  | prep     | xx    | true     | true    |
| buying  | buy     | VERB  | VBG | pcomp    | xxxx  | true     | false   |
| U.K.    | U.K.    | PROPN | NNP | dobj     | X.X.  | false    | false   |
| startup | startup | NOUN  | NN  | advcl    | xxxx  | true     | false   |
| for     | for     | ADP   | IN  | prep     | xxx   | true     | true    |
| $       | $       | SYM   | $   | quantmod | $     | false    | false   |
| 1       | 1       | NUM   | CD  | compound | d     | false    | false   |
| billion | billion | NUM   | CD  | pobj     | xxxx  | true     | false   |

**POS Example (Japanese)**

```ruby
require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")
doc = nlp.read("任天堂は1983年にファミリー・コンピュータを14,800円で発売した。")

rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_, token.shape_, token.is_alpha, token.is_stop]
end

headings = ["text", "lemma", "pos", "tag", "dep", "shape", "is_alpha", "is_stop"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

**Output**

| text       | lemma      | pos   | tag                      | dep    | shape  | is_alpha | is_stop |
|:-----------|:-----------|:------|:-------------------------|:-------|:-------|:---------|:--------|
| 任天堂     | 任天堂     | PROPN | 名詞-固有名詞-一般       | nsubj  | xxx    | true     | false   |
| は         | は         | ADP   | 助詞-係助詞              | case   | x      | true     | true    |
| 1983       | 1983       | NUM   | 名詞-数詞                | nummod | dddd   | false    | false   |
| 年         | 年         | NOUN  | 名詞-普通名詞-助数詞可能 | obl    | x      | true     | false   |
| に         | に         | ADP   | 助詞-格助詞              | case   | x      | true     | true    |
| ファミコン | ファミコン | NOUN  | 名詞-普通名詞-一般       | obj    | xxxx   | true     | false   |
| を         | を         | ADP   | 助詞-格助詞              | case   | x      | true     | true    |
| 14,800     | 14,800     | NUM   | 名詞-数詞                | fixed  | dd,ddd | false    | false   |
| 円         | 円         | NOUN  | 名詞-普通名詞-助数詞可能 | obl    | x      | true     | false   |
| で         | で         | ADP   | 助詞-格助詞              | case   | x      | true     | true    |
| 発売       | 発売       | VERB  | 名詞-普通名詞-サ変可能   | ROOT   | xx     | true     | false   |
| し         | する       | AUX   | 動詞-非自立可能          | aux    | x      | true     | true    |
| た         | た         | AUX   | 助動詞                   | aux    | x      | true     | true    |
| 。         | 。         | PUNCT | 補助記号-句点            | punct  | 。     | false    | false   |

### Visualizing Dependency

→ [spaCy Visualizers](https://spacy.io/usage/visualizers)

**Dependency Visualization Example**

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

**Output**

![](https://github.com/yohasebe/ruby-spacy/blob/main/examples/get_started/outputs/test_dep.svg)


**Dependency Visualization Example (Compact)**

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

**Output**

![](https://github.com/yohasebe/ruby-spacy/blob/main/examples/get_started/outputs/test_dep_compact.svg)

### Named Entities 

→ [spaCy 101](https://spacy.io/usage/spacy-101#annotations-ner)

**Named Entities Example**

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc =nlp.read("Apple is looking at buying U.K. startup for $1 billion")

rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label_]
end

headings = ["text", "start_char", "end_char", "label"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

**Output**

| text       | start_char | end_char | label |
|:-----------|-----------:|---------:|:------|
| Apple      | 0          | 5        | ORG   |
| U.K.       | 27         | 31       | GPE   |
| $1 billion | 44         | 54       | MONEY |

**Named Entity Example (Japanese)**

```ruby
require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "任天堂は1983年にファミコンを14,800円で発売した。"
doc = nlp.read(sentence)

rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label_]
end

headings = ["text", "start", "end", "label"]
table = Terminal::Table.new rows: rows, headings: headings
print table
```

**Output**

| text       | start | end | label   |
|:-----------|------:|----:|:--------|
| 任天堂     | 0     | 3   | ORG     |
| 1983年     | 4     | 9   | DATE    |
| ファミコン | 10    | 15  | PRODUCT |
| 14,800円   | 16    | 23  | MONEY   |

### Word Vectors and Similarity

→ [spaCy 101](https://spacy.io/usage/spacy-101#vectors-similarity)

These functionalities need a larger pipeline package than the one that ends in `sm`:

```shell
$ python -m spacy download en_core_web_lg
```

**Word Vector Example**

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
**Output**

| text    | has_vector | vector_norm | is_oov |
|:--------|:-----------|:------------|:-------|
| dog     | true       | 7.0336733   | false  |
| cat     | true       | 6.6808186   | false  |
| banana  | true       | 6.700014    | false  |
| afskfsd | false      | 0.0         | true   |

**Similarity Example**

```ruby
require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_lg")
doc1 = nlp.read("I like salty fries and hamburgers.")
doc2 = nlp.read("Fast food tastes very good.")

puts "Doc 1: " + doc1
puts "Doc 2: " + doc2
puts "Similarity: #{doc1.similarity(doc2)}"

```

**Output**

```text
Doc 1: I like salty fries and hamburgers.
Doc 2: Fast food tastes very good.
Similarity: 0.7687607012190486
```
**Similarity Example (Japanese)**

```ruby
require "ruby-spacy"

nlp = Spacy::Language.new("ja_core_news_lg")
ja_doc1 = nlp.read("今日は雨ばっかり降って、嫌な天気ですね。")
puts "doc1: #{ja_doc1.text}"
ja_doc2 = nlp.read("あいにくの悪天候で残念です。")
puts "doc2: #{ja_doc2.text}"
puts "Similarity: #{ja_doc1.similarity(ja_doc2)}"
```

**Output**

```text
doc1: 今日は雨ばっかり降って、嫌な天気ですね。
doc2: あいにくの悪天候で残念です。
Similarity: 0.8684192637149641
```

**Word Vector Calculation Example**

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_lg")

tokyo = nlp.get_lexeme("Tokyo")
japan = nlp.get_lexeme("Japan")
france = nlp.get_lexeme("France")

query = tokyo.vector - japan.vector + france.vector

rows = []

results = nlp.most_similar(query, 10)
results.each do |lexeme|
  rows << [lexeme[:key], lexeme[:text], lexeme[:score],]
end

headings = ["key", "text", "score"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

**Output**

| key                  | text        | score              |
|:---------------------|:------------|:-------------------|
| 1432967385481565694  | FRANCE      | 0.8346999883651733 |
| 6613816697677965370  | France      | 0.8346999883651733 |
| 4362406852232399325  | france      | 0.8346999883651733 |
| 1637573253267610771  | PARIS       | 0.7703999876976013 |
| 15322182186497800017 | paris       | 0.7703999876976013 |
| 10427160276079242800 | Paris       | 0.7703999876976013 |
| 975948890941980630   | TOULOUSE    | 0.6381999850273132 |
| 7944504257273452052  | Toulouse    | 0.6381999850273132 |
| 9614730213792621885  | toulouse    | 0.6381999850273132 |
| 8515538464606421210  | marseille   | 0.6370999813079834 |


**Word Vector Calculation Example (Japanese)**

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

tokyo = nlp.get_lexeme("東京")
japan = nlp.get_lexeme("日本")
france = nlp.get_lexeme("フランス")

query = tokyo.vector - japan.vector + france.vector

rows = []

results = nlp.most_similar(query, 10)
results.each do |lexeme|
  rows << [lexeme[:key], lexeme[:text], lexeme[:score],]
end

headings = ["key", "text", "score"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

**Output**

| key                  | text           | score              |
|:---------------------|:---------------|:-------------------|
| 12090003238699662352 | パリ           | 0.7376999855041504 |
| 18290786970454458111 | フランス       | 0.7221999764442444 |
| 9360021637096476946  | 東京           | 0.6697999835014343 |
| 2437546359230213520  | ストラスブール | 0.631600022315979  |
| 13988178952745813186 | リヨン         | 0.5939000248908997 |
| 10427160276079242800 | Paris          | 0.574400007724762  |
| 5562396768860926997  | ベルギー       | 0.5683000087738037 |
| 15029176915627965481 | ニース         | 0.5679000020027161 |
| 9750625950625019690  | アルザス       | 0.5644999742507935 |
| 2381640614569534741  | 南仏           | 0.5547999739646912 |

----

## Author

Yoichiro Hasebe [<yohasebe@gmail.com>]

## License

This library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

