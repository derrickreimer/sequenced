require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute_accessors'

module Sequenced
  module ActsAsSequenced
    DEFAULT_OPTIONS = {
      column: :sequential_id,
      start_at: 1
    }.freeze
    SequencedColumnExists = Class.new(StandardError)

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Public: Defines ActiveRecord callbacks to set a sequential ID scoped
      # on a specific class.
      #
      # Can be called multiple times to add hooks for different column names.
      #
      # options - The Hash of options for configuration:
      #           :scope    - The Symbol representing the columm on which the
      #                       sequential ID should be scoped (default: nil)
      #           :column   - The Symbol representing the column that stores the
      #                       sequential ID (default: :sequential_id)
      #           :start_at - The Integer value at which the sequence should
      #                       start (default: 1)
      #           :skip     - Skips the sequential ID generation when the lambda
      #                       expression evaluates to nil. Gets passed the
      #                       model object
      #
      # Examples
      #
      #   class Answer < ActiveRecord::Base
      #     belongs_to :question
      #     acts_as_sequenced :scope => :question_id
      #   end
      #
      # Returns nothing.
      def acts_as_sequenced(options = {})
        unless defined?(sequenced_options)
          include Sequenced::ActsAsSequenced::InstanceMethods

          mattr_accessor :sequenced_options, instance_accessor: false
          self.sequenced_options = []

          before_save :set_sequential_ids
        end

        options = DEFAULT_OPTIONS.merge(options)
        column_name = options[:column]

        if sequenced_options.any? {|options| options[:column] == column_name}
          raise(SequencedColumnExists, <<-MSG.squish)
            Tried to set #{column_name} as sequenced but there was already a
            definition here. Did you accidentally call acts_as_sequenced
            multiple times on the same column?
          MSG
        else
          sequenced_options << options
        end
      end
    end

    module InstanceMethods
      def set_sequential_ids
        self.class.base_class.sequenced_options.each do |options|
          Sequenced::Generator.new(self, options).set
        end
      end
    end
  end
end
