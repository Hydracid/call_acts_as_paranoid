# frozen_string_literal: true

require 'spec_helper'
require 'paranoia_support/call_acts_as_paranoid'

RSpec.describe ParanoiaSupport::CallActsAsParanoid do
  subject(:cop) do
    described_class.new(config)
  end

  describe 'when arguments corrected' do
    let(:config) do
      RuboCop::Config
        .new(
          'ParanoiaSupport/CallActsAsParanoid' => {
            'Superclass' => %w[ApplicationRecord]
          }
        )
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        #  deleted_at :datetime
        class Foo < ApplicationRecord
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ call `acts_as_paranoid`.
        end
      RUBY
    end
  end

  describe 'when autocorrect' do
    let(:source) do
      <<-RUBY.strip_indent
        #  deleted_at :datetime
        class Foo < ApplicationRecord
        end
      RUBY
    end

    context 'with basic options' do
      let(:config) do
        RuboCop::Config
          .new(
            'ParanoiaSupport/CallActsAsParanoid' => {
              'Superclass' => %w[ApplicationRecord]
            }
          )
      end
      let(:expected) do
        <<-RUBY.strip_indent
          #  deleted_at :datetime
          class Foo < ApplicationRecord
            acts_as_paranoid
          end
        RUBY
      end

      it 'corrected' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq expected
      end
    end

    context 'with MethodArgumentsString option' do
      let(:config) do
        RuboCop::Config
          .new(
            'ParanoiaSupport/CallActsAsParanoid' => {
              'Superclass' => %w[ApplicationRecord],
              'MethodArgumentsString' => 'column: :supended_at'
            }
          )
      end
      let(:expected) do
        <<-RUBY.strip_indent
          #  deleted_at :datetime
          class Foo < ApplicationRecord
            acts_as_paranoid column: :supended_at
          end
        RUBY
      end

      it 'corrected' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq expected
      end
    end

    context 'with complex options' do
      let(:config) do
        RuboCop::Config
          .new(
            'ParanoiaSupport/CallActsAsParanoid' => {
              'Superclass' => [{ 'Class' => 'ApplicationRecord', 'Column' => 'supended_at' }],
              'MethodArgumentsString' => 'column: :supended_at'
            }
          )
      end
      let(:source) do
        <<-RUBY.strip_indent
          #  supended_at :datetime
          class Foo < ApplicationRecord
          end
        RUBY
      end
      let(:expected) do
        <<-RUBY.strip_indent
          #  supended_at :datetime
          class Foo < ApplicationRecord
            acts_as_paranoid column: :supended_at
          end
        RUBY
      end

      it 'corrected' do
        corrected = autocorrect_source(source)
        expect(corrected).to eq expected
      end
    end
  end

  describe 'when arguments incorrected' do
    let(:config) do
      RuboCop::Config
        .new(
          'ParanoiaSupport/CallActsAsParanoid' => {
            'Superclass' => %w[ApplicationRecord]
          }
        )
    end

    it 'does not annotated.' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class Foo < ApplicationRecord
        end
      RUBY
    end

    it 'does not inherited.' do
      expect_no_offenses(<<-RUBY.strip_indent)
        #  deleted_at :datetime
        class Foo < Bar
        end
      RUBY
    end

    it 'already called.' do
      expect_no_offenses(<<-RUBY.strip_indent)
        #  deleted_at :datetime
        class Foo < ApplicationRecord
          acts_as_paranoid
        end
      RUBY
    end
  end
end
