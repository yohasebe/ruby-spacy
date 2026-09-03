# Syntax Tree Gallery

Trees drawn by `Doc#syntax_tree` with the [rsyntaxtree](https://github.com/yohasebe/rsyntaxtree) gem. The scripts in `examples/rsyntaxtree/` generate every image here.

Noun chunks are shaded grey; a chunk that is also a named entity is shaded orange and labeled with the entity type. The blue and green are rsyntaxtree's default palette, not marking of any kind. Phrase labels come from the head's POS tag, so they follow whatever annotation scheme the model uses. Both are explained in the [README](../README.md#syntax-trees).

## English (`en_core_web_sm`)

Projection, the default style:

![English projection](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_en_projection.png)

Chunks style:

![English chunks](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_en_chunks.png)

With morphology (a shorter sentence — the tables are tall):

![English morphology](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_en_morphology.png)

## Japanese (`ja_core_news_sm`)

Projection, with PERSON and GPE highlighted:

![Japanese projection](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_ja_projection.png)

Chunks style:

![Japanese chunks](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_ja_chunks.png)

## Russian (`ru_core_news_sm`)

No noun chunk iterator, so `style: :chunks` is unavailable.

![Russian projection](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_ru_projection.png)

With morphology — Russian marks case, gender, animacy, aspect, and voice:

![Russian morphology](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_ru_morphology.png)

## German (`de_core_news_sm`)

![German projection](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_de_projection.png)

## Chinese (`zh_core_web_sm`)

No noun chunk iterator, so `style: :chunks` is unavailable.

![Chinese projection](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_zh_projection.png)

## Arabic (right-to-left)

spaCy ships no Arabic pipeline, so this tree was parsed with [Stanza](https://stanfordnlp.github.io/stanza/) via [spacy-stanza](https://github.com/explosion/spacy-stanza) and wrapped with `Spacy::Language.new(py_nlp:)`. Right-to-left languages are drawn mirrored automatically. This pipeline has no noun chunks, so nothing is shaded. See `examples/rsyntaxtree/syntax_tree_ar.rb`.

![Arabic projection](https://github.com/yohasebe/ruby-spacy/blob/main/examples/rsyntaxtree/outputs/tree_ar_projection.png)
