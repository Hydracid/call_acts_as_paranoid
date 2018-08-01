# frozen_string_literal: true

module ParanoiaSupport
  # run `annotate`, add schema comments to your models before.
  # https://github.com/ctran/annotate_models
  #
  # @example
  #   # bad
  #   # Table name: foo
  #   #  deleted_at :datetime
  #   class Foo < ApplicationRecord
  #   end
  #
  #   # good
  #   # Table name: foo
  #   #  deleted_at :datetime
  #   class Foo < ApplicationRecord
  #     acts_as_paranoid
  #   end
  class CallActsAsParanoid < RuboCop::Cop::Cop
    # https://github.com/rubocop-hq/rubocop/commit/816568658b25275e427ff953aae7a7cd84489b8e#diff-791417dd66c35e3240d7cec5c5cb4700
    if defined?(RuboCop::Cop::Alignment)
      include RuboCop::Cop::Alignment
    else
      include RuboCop::Cop::AutocorrectAlignment
    end

    MSG = 'call `acts_as_paranoid`.'.freeze
    DEFAULT_COLUMN = 'deleted_at'.freeze

    def_node_matcher :class_definition, <<-PATTERN
      (class (const _ _) (const _ _) ...)
    PATTERN
    def_node_search :acts_as_paranoid_found?, '(send nil? :acts_as_paranoid ...)'

    # https://github.com/rubocop-hq/rubocop/commit/a1893ba57b43d793c15bd66f6db47950ae2ef7bc#diff-bb699bbdd39f9057a30af6f90468ef1d
    def add_offense(node)
      return super(node, :expression) if Gem::Version.new(RuboCop::Version::STRING) < Gem::Version.new('0.52')
      super node
    end

    def on_class(node)
      class_definition(node) do
        _, superklazz, = *node
        next unless superklazz.is_a?(RuboCop::AST::Node)
        add_offense(node) if corrective_class?(superklazz.const_name, node)
      end
    end

    def autocorrect(node)
      _, superklazz, = *node
      class_def_source_range(node) do |base_indent, source, range|
        method_indent = SPACE * (indentation_width + base_indent.length)
        lambda do |corrector|
          corrector.replace(range, source + "\n" + method_indent + acts_as_paranoid_method(superklazz.const_name))
        end
      end
    end

    private

    def corrective_class?(const_name, node)
      target_superklazzez.include?(const_name) &&
        detect_annotated_column?(const_name) && !acts_as_paranoid_found?(node)
    end

    def target_superklazzez
      @target_superklazzez ||= Array(cop_config['Superclass']).map { |a| a.is_a?(Hash) ? a['Class'] : a }
    end

    def column(const_name)
      Array(cop_config['Superclass'])
        .select { |a| a.is_a?(Hash) && a['Class'] == const_name && a['Column'] }.map { |a| a['Column'] }
        .first || DEFAULT_COLUMN
    end

    def detect_annotated_column?(const_name)
      regexp = /^#\s+#{Regexp.escape(column(const_name))}\s+\:datetime/
      @processed_source.comments.each do |comment|
        return true if regexp.match comment.text
      end
      false
    end

    def class_def_source(node)
      line = node.loc.keyword.line
      source = node.source_range.source_buffer.source_line(line)
      yield(/^\s*/.match(source).to_a.first, source)
    end

    def class_def_source_range(node)
      class_def_source(node) do |indent, source|
        start_pos = node.source_range.begin_pos - indent.length
        range = Parser::Source::Range.new(@processed_source.buffer, start_pos, start_pos + source.length)
        yield indent, source, range
      end
    end

    def indentation_width
      configured_indentation_width || 2
    end

    def acts_as_paranoid_method(const_name)
      ['acts_as_paranoid', arguments_string(const_name)].compact.join(' ')
    end

    def arguments_string(const_name)
      Array(cop_config['Superclass'])
        .select { |a| a.is_a?(Hash) && a['Class'] == const_name && a['MethodArgumentsString'] }
        .map { |a| a['MethodArgumentsString'] }
        .first || cop_config['MethodArgumentsString']
    end
  end
end
