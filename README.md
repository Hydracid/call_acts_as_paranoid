# paranoia_support

## Installation

`gem 'paranoia_support', require: false, github: 'hydracid/paranoia_support'`

## .rubocop.yml example

```
ParanoiaSupport/CallActsAsParanoid:
  Superclass:
    - ApplicationRecord
  Enabled: true
  Include:
    - app/models/**/**.rb
```

## Usage

find column (ex. `:deleted_at`) from annotation comment, and write `acts_as_paranoid` method inside model class.

`$ bundle exec annotate`

`$ bundle exec rubocop`

`$ bundle exec rubocop -a`
