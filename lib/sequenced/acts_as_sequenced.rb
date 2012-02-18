# Required for cattr_accessor macro
require 'active_support/core_ext/class/attribute_accessors'

module Sequenced
  module ActsAsSequenced
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # Defines ActiveRecord callbacks to set a sequential ID scoped 
      # on a specific class.
      #
      # options - The Hash of options for configuration:
      #           :on     - The Class on which the sequential ID
      #                     should be scoped (default: nil)
      #           :column - The Symbol representing the column
      #                     (or method) that stores the sequential ID 
      #                     (default: :sequential_id)
      #
      # Examples
      #   
      #   class Answer < ActiveRecord::Base
      #     acts_as_sequenced :on => Question, :column => :custom_sequential_id
      #   end
      #
      # Returns nothing.
      def acts_as_sequenced(options = {})
        # Create sequenced column accessor and assign option or default
        cattr_accessor :sequenced_on
        self.sequenced_on = options[:on] || nil
        
        # Create sequenced column accessor and assign option or default
        cattr_accessor :sequenced_column
        self.sequenced_column = options[:column] || :sequential_id
        
        # Define ActiveRecord callback
        before_save :set_sequential_id
        
        # Validate uniqueness of sequential ID
        validates self.sequenced_column, :uniqueness => { :scope => self.sequenced_on }
        
        # Include instance methods
        include Sequenced::ActsAsSequenced::InstanceMethods
      end
    end
    
    module InstanceMethods
      # Internal: Fetches the next sequential ID and assigns it to 
      # the sequential ID column if the sequential id is not already
      # defined.
      #
      # Returns nothing. 
      def set_sequential_id(options = {})
        column = self.class.sequenced_column
        
        unless self.respond_to?(column)
          raise Sequenced::AttributeError.new("Method ##{column} not found")
        end
        
        if self.send(column).blank?
          
        end
      end
    end
  end
end