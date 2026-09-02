# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in ruby-spacy.gemspec
gemspec

group :development do
  gem "github-markup"
  gem "redcarpet"
end

# Used only for rendering in Doc#syntax_tree / Span#syntax_tree tests.
# Kept in its own group so CI jobs without the pango/rsvg system libraries
# can exclude it with BUNDLE_WITHOUT=rendering.
group :rendering do
  gem "rsyntaxtree", ">= 2.4.0", require: false
end
