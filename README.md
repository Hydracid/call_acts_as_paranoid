# paranoia_support

find a column (e.g. `:deleted_at`) from annotation comment, and write `acts_as_paranoid` method inside model class.

## Precondition

`gem 'rubocop'`

`gem 'annotate'`

`gem 'paranoia'`

## Installation

`gem 'paranoia_support', require: false, github: 'hydracid/paranoia_support'`

### .rubocop.yml example

```
ParanoiaSupport/CallActsAsParanoid:
  Superclass:
    - ApplicationRecord
  Enabled: true
  Include:
    - app/models/**/**.rb
```

## Usage

`$ bundle exec annotate`

`$ bundle exec rubocop`

`$ bundle exec rubocop -a`

```
@example
  # bad
  # Table name: foo
  #  deleted_at :datetime
  class Foo < ApplicationRecord
  end

  # good
  # Table name: foo
  #  deleted_at :datetime
  class Foo < ApplicationRecord
    acts_as_paranoid
  end
```
