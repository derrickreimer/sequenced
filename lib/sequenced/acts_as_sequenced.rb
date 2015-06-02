require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute_accessors'

module Sequenced
  module ActsAsSequenced
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Public: Defines ActiveRecord callbacks to set a sequential ID scoped
      # on a specific class.
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
        cattr_accessor :sequenced_options
        self.sequenced_options = options

        before_save :set_sequential_id
        include Sequenced::ActsAsSequenced::InstanceMethods
      end
    end

    module InstanceMethods
      def set_sequential_id
        self.class.with_table_lock do
          Sequenced::Generator.new(self, self.class.base_class.sequenced_options).set
        end
      end
    end
  end
end
