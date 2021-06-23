# ruby-spacy

An wrapper module for using [spaCy](https://spacy.io/) natural language processing library from the Ruby programming language using PyCall

----

## Preparation

To use `ruby-spacy`, which uses [PyCall](https://github.com/mrkn/pycall.rb), make sure that the `enable-shared` option is enabled in your Python installation. You can use [pyenv](https://github.com/pyenv/pyenv) to install any version of Python you like. Do it as follows to install Python 3.5.9 for instance:

```shell
$ env CONFIGURE_OPTS="--enable-shared" pyenv install 3.5.9
```

If you use the python installation locally:

```shell
$ pyenv local 3.5.9 
```

Or if you use the python installation globally:

```shell
$ pyenv global 3.5.9
```

Then, you can install [spaCy](https://spacy.io/) in any way you like. For example, if you use `pip`, you can do the following.

```shell
$ pip install spacy
```

Then install trained models/pipelines. For a starter, `en_core_web_sm` is useful to process text in English. (If you use word vector functionalites of spaCy, install `en_core_web_sm`, `en_core_web_lg` or `en_core_web_trf` instead.)

```shell
$ python -m spacy download en_core_web_sm
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

headings = [1,2,3,4,5,6,7,8,9,10]
row = []

doc.each do |token|
  row << token.text
end

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

headings = ["text", "lemma", "pos", "tag", "dep", "shape", "is_alpha", "is_stop"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_, token.shape_, token.is_alpha, token.is_stop]
end

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

headings = ["text", "lemma", "pos", "tag", "dep", "shape", "is_alpha", "is_stop"]
rows = []

doc.each do |token|
  rows << [token.text, token.lemma_, token.pos_, token.tag_, token.dep_, token.shape_, token.is_alpha, token.is_stop]
end

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

**Dependency Example**

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

![](./../examples/get_started/outputs/test_dep.svg)


**Dependency Visualization Example**

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

![](./../examples/get_started/outputs/test_dep_compact.svg)

### Named Entities 

→ [spaCy 101](https://spacy.io/usage/spacy-101#annotations-ner)

**Named Entities Example**

```ruby
require "ruby-spacy"
require "terminal-table"

nlp = Spacy::Language.new("en_core_web_sm")
doc =nlp.read("Apple is looking at buying U.K. startup for $1 billion")

headings = ["text", "start_char", "end_char", "label"]
rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label_]
end

table = Terminal::Table.new rows: rows, headings: headings
puts table
```

**Output**

| text       | start_char | end_char | label |
|:-----------|-----------:|---------:|:------|
| Apple      | 0          | 5        | ORG   |
| U.K.       | 27         | 31       | GPE   |
| $1 billion | 44         | 54       | MONEY |

**Named Entity Visualization Example**

```ruby
require "ruby-spacy"

nlp = Spacy::Language.new("en_core_web_sm")

sentence ="When Sebastian Thrun started working on self-driving cars at Google in 2007, few people outside of the company took him seriously." 
doc = nlp.read(sentence)

ent_html = doc.displacy(style: 'ent')

File.open(File.join(File.dirname(__FILE__), "test_ent.html"), "w") do |file|
  file.write(ent_html)
end
```

**Output**

<div class="entities" style="line-height: 2.5; direction: ltr">When 
<mark class="entity" style="background: #aa9cfc; padding: 0.45em 0.6em; margin: 0 0.25em; line-height: 1; border-radius: 0.35em;">
    Sebastian Thrun
    <span style="font-size: 0.8em; font-weight: bold; line-height: 1; border-radius: 0.35em; vertical-align: middle; margin-left: 0.5rem">PERSON</span>
</mark>
 started working on self-driving cars at Google in 
<mark class="entity" style="background: #bfe1d9; padding: 0.45em 0.6em; margin: 0 0.25em; line-height: 1; border-radius: 0.35em;">
    2007
    <span style="font-size: 0.8em; font-weight: bold; line-height: 1; border-radius: 0.35em; vertical-align: middle; margin-left: 0.5rem">DATE</span>
</mark>
, few people outside of the company took him seriously.</div>

**Named Entity Example (Japanese)**

```ruby
require( "ruby-spacy")
require "terminal-table"

nlp = Spacy::Language.new("ja_core_news_lg")

sentence = "任天堂は1983年にファミコンを14,800円で発売した。"
doc = nlp.read(sentence)

headings = ["text", "start", "end", "label"]
rows = []

doc.ents.each do |ent|
  rows << [ent.text, ent.start_char, ent.end_char, ent.label_]
end

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

headings = ["text", "has_vector", "vector_norm", "is_oov"]
rows = []

doc.each do |token|
  rows << [token.text, token.has_vector, token.vector_norm, token.is_oov]
end

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
require( "ruby-spacy")

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
----

## Author

Yoichiro Hasebe [<yohasebe@gmail.com>]

## License

This library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

