# ruby-spacy

An adapter code to use [spaCy](https://spacy.io/) NLP library from Ruby using PyCall

----

### Prerequisites

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

After that, you can install [spaCy](https://spacy.io/) in any way you like. For example, if you use `pip`, you can do the following.

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

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

----

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

