require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute_accessors'
require 'pry'
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
        unless defined?(sequenced_options)
          include Sequenced::ActsAsSequenced::InstanceMethods

          cattr_accessor :sequenced_options
          self.sequenced_options = []

          before_save :set_sequential_ids
        end

        sequenced_options << options
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
