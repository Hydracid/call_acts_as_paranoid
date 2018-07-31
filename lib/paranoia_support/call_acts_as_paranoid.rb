# frozen_string_literal: true

module ParanoiaSupport
  # run `annotate`, add schema comments to your models.
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
    include RuboCop::Cop::Alignment
    MSG = 'call `acts_as_paranoid`.'.freeze

    def_node_matcher :class_definition, <<-PATTERN
      (class (const _ _) $_ ...)
    PATTERN
    def_node_search :acts_as_paranoid_exists?, '(send nil? :acts_as_paranoid ...)'

    def on_class(node)
      class_definition(node) do |k|
        next unless k.is_a?(RuboCop::AST::Node)
        add_offense(node) if superklazzez.include?(k.const_name) && uncalled?(node)
      end
    end

    def autocorrect(node)
      source, range = class_source_range node
      indent = SPACE * (indentation_width + /^\s*/.match(source).to_a.map(&:length).first)
      lambda do |corrector|
        corrector.replace(range, source + "\n" + indent + acts_as_paranoid_method)
      end
    end

    private

    def class_source(node)
      line = node.loc.keyword.line
      node.source_range.source_buffer.source_line(line)
    end

    def class_source_range(node)
      source = class_source node
      start_pos = node.source_range.begin_pos
      end_pos = node.source_range.begin_pos + source.length
      range = Parser::Source::Range.new(@processed_source.buffer, start_pos, end_pos)
      [source, range]
    end

    def indentation_width
      configured_indentation_width || 2
    end

    def acts_as_paranoid_method
      ['acts_as_paranoid', cop_config['MethodArgumentsString']].compact.join(' ')
    end

    def superklazzez
      @superklazzez ||= Array(cop_config['Superclass'])
    end

    def uncalled?(node)
      detect_annotated_deleted_at? && !acts_as_paranoid_exists?(node)
    end

    def detect_annotated_deleted_at?
      @processed_source.comments.each do |comment|
        return true if comment.text.match?(/^#\s+deleted_at\s+\:datetime/)
      end
      false
    end
  end
end
