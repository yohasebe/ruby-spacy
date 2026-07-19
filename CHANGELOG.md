# Change Log

## 0.4.1 - 2026-07-19
### Fixed
- Gem packaging: normalize file permissions at build time so packaged files
  are world-readable (0644 / 0755). Version 0.4.0 shipped 11 owner-only
  (0600) files, which made the gem unusable after `sudo gem install`

## 0.3.0 - 2025-01-06
### Added
- Ruby 4.0 support
- `Doc#to_bytes` for serializing documents to binary format
- `Doc.from_bytes` for restoring documents from binary data
- `PhraseMatcher` class for efficient phrase matching
- `Language#phrase_matcher` helper method

### Changed
- Replaced `ruby-openai` gem with custom `OpenAIClient` implementation
- Updated default OpenAI model to `gpt-5-mini`
- Updated embeddings model to `text-embedding-3-small`
- Changed `max_tokens` parameter to `max_completion_tokens` (backward compatible)
- Added `fiddle` gem dependency (required for Ruby 4.0)

## 0.2.4 - 2024-12-11
### Changed
- Timeout and retry feature for `Spacy::Language.new`

## 0.2.3 - 2024-08-27
- Timeout option added to `Spacy::Language.new`
- Default OpenAI models updated to `gpt-4o-mini`

## 0.2.0 - 2022-10-02
### Added
- spaCy 3.7.0 supported
- `Doc#openai_query`
- `Doc#openai_completion`
- `Doc#openai_embeddings`

## 0.1.4.1 - 2021-07-06
- Test code refined
- `Spacy::Language::most_similar` returns an array of hash-based objects that accepts method calls

## 0.1.4 - 2021-06-26
### Added
- `Spacy::Lexeme` class

- `Spacy::Token#morpheme` method 
## 0.1.3 - 2021-06-26
- Code cleanup

## 0.1.2 - 2021-06-26
### Added
- `Spacy::Token#morpheme` method 

## 0.1.1 - 2021-06-26
- Project description fixed

## 0.1.0 - 2021-06-26
- Initial release
