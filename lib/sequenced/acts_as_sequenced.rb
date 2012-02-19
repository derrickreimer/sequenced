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
        # Remove extraneous options
        options.slice!(:scope, :column, :start_at)
        
        # Set defaults
        options[:column]   ||= :sequential_id
        options[:start_at] ||= 1
        
        # Create class accessor for sequenced options
        cattr_accessor :sequenced_options
        self.sequenced_options = options
        
        # Specify ActiveRecord callback
        before_save :set_sequential_id
        include Sequenced::ActsAsSequenced::InstanceMethods
      end
    end
    
    module InstanceMethods
      # Internal: Fetches the next sequential ID and assigns it to 
      # the sequential ID column if the sequential id is not already
      # defined.
      #
      # Returns nothing.
      # Raises Sequenced::InvalidAttributeError if
      #   1) The specified scope method is undefined,
      #   2) The specified scope method returns nil, or
      #   3) The sequential ID column is undefined.
      def set_sequential_id
        scope  = self.class.sequenced_options[:scope]
        column = self.class.sequenced_options[:column]
        
        if scope.present?
          if !self.respond_to?(scope)
            raise Sequenced::InvalidAttributeError.new("Method ##{scope.to_s} is undefined")
          elsif self.send(scope).nil?
            raise Sequenced::InvalidAttributeError.new("Method ##{scope.to_s} returned nil unexpectedly")
          end
        end
        
        unless self.respond_to?(column)
          raise Sequenced::InvalidAttributeError.new("Method ##{column.to_s} is undefined")
        end
        
        # Fetch the next ID unless it is already defined
        self.send(:"#{column}=", next_sequential_id) until sequential_id_is_unique?
      end
      
      # Internal: Obtain the next sequential ID
      #
      # Returns Integer.
      # Raises Sequenced::InvalidAttributeError if the last sequential ID is not
      #   an Integer.
      def next_sequential_id
        scope    = self.class.sequenced_options[:scope]
        column   = self.class.sequenced_options[:column]
        start_at = self.class.sequenced_options[:start_at]
        
        q = self.class.unscoped.where("#{column.to_s} IS NOT NULL").order("#{column.to_s} DESC")
        q = q.where(scope => self.send(scope)) if scope.is_a?(Symbol)
        
        return start_at unless last_record = q.first
        last_id = last_record.send(column)
        
        unless last_id.is_a?(Integer)
          raise Sequenced::InvalidAttributeError("Last sequential ID is not an Integer")
        end
        
        last_id + 1 > start_at ? last_id + 1 : start_at
      end
      
      # Internal: Checks the uniqueness of the sequential ID.
      #
      # Returns Boolean status of uniqueness.
      def sequential_id_is_unique?
        scope  = self.class.sequenced_options[:scope]
        column = self.class.sequenced_options[:column]
        return false unless self.send(column).is_a?(Integer)
        
        q = self.class.unscoped.where(column => self.send(column))
        q = q.where(scope => self.send(scope)) if scope.is_a?(Symbol)
        q = q.where("NOT id = ?", self.id) if self.persisted?
        
        q.count > 0 ? false : true
      end
    end
  end
end