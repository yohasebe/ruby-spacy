# ruby-spacy

❕ This project is **work-in-progress** and is provided as-is. There may be breaking changes committed to this repository without notice.

## Overview 

**ruby-spacy** is a wrapper module for using [spaCy](https://spacy.io/) from the Ruby programming language via [PyCall](https://github.com/mrkn/pycall.rb). This module aims to make it easy and natural for Ruby programmers to use spaCy. This module covers the areas of spaCy functionality for _using_ many varieties of its language models, not for _building_ ones.

|    | Functionality                                      |
|:---|:---------------------------------------------------|
| ✅ | Tokenization, lemmatization, sentence segmentation |
| ✅ | Part-of-speech tagging and dependency parsing      |
| ✅ | Named entity recognition                           |
| ✅ | Syntactic dependency visualization                 |
| ✅ | Access to pre-trained word vectors                 |

## Installation of prerequisites

Make sure that the `enable-shared` option is enabled in your Python installation. You can use [pyenv](https://github.com/pyenv/pyenv) to install any version of Python you like. Install Python 3.8.5, for instance, using pyenv with `enable-shared` as follows:

```shell
$ env CONFIGURE_OPTS="--enable-shared" pyenv install 3.8.5
```

Don't forget to make it accessible from your working directory.

```shell
$ pyenv local 3.8.5 
```

Or alternatively:

```shell
$ pyenv global 3.8.5 
```

Then, install [spaCy](https://spacy.io/). If you use `pip`, the following command will do:

```shell
$ pip install spacy
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

🔖 [spaCy: Tokenization](https://spacy.io/usage/spacy-101#annotations-token)

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

### Part-of-speech tagging

🔖 [spaCy: Part-of-speech tags and dependencies](https://spacy.io/usage/spacy-101#annotations-pos-deps)

🔖 [POS and morphology tags](https://github.com/explosion/spaCy/blob/master/spacy/glossary.py)

Ruby code: 

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

Output:

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

### Part-of-speech tagging (Japanese)

Ruby code: 

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

Output:

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

### Visualizing dependency

🔖 [spaCy: Visualizers](https://spacy.io/usage/visualizers)

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

🔖 [spaCy: Named entities](https://spacy.io/usage/spacy-101#annotations-ner)

Ruby code: 

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
  rows << [ent.text, ent.start_char, ent.end_char, ent.label_]
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

🔖 [spaCy: Word vectors and similarity](https://spacy.io/usage/spacy-101#vectors-similarity)

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

puts "Doc 1: " + doc1
puts "Doc 2: " + doc2
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

rows = []

results = nlp.most_similar(query, 10)
results.each do |lexeme|
  rows << [lexeme[:key], lexeme[:text], lexeme[:score],]
end

headings = ["key", "text", "score"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

Output:

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

rows = []

results = nlp.most_similar(query, 10)
results.each do |lexeme|
  rows << [lexeme[:key], lexeme[:text], lexeme[:score],]
end

headings = ["key", "text", "score"]
table = Terminal::Table.new rows: rows, headings: headings
puts table
```

Output:

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


## Author

Yoichiro Hasebe [<yohasebe@gmail.com>]


## Acknowlegments

I would like to thank the following open source projects and their creators for making this project possible:

- [explosion/spaCy](https://github.com/explosion/spaCy)
- [mrkn/pycall.rb](https://github.com/mrkn/pycall.rb)

## License

This library is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

