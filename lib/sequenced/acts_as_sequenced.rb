require 'active_support/core_ext/hash/slice'

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
      # Raises Sequenced::SequencedError if the scope object or
      #   sequential ID column do not exist or if the sequence advancement
      #   fails.
      def set_sequential_id
        scope  = self.class.sequenced_options[:scope]
        column = self.class.sequenced_options[:column]
        
        if scope.present? && !self.respond_to?(scope)
          raise Sequenced::InvalidScopeError.new("Scope method does not exist")
        end
        
        unless self.respond_to?(column)
          raise Sequenced::SequencedError.new("Sequential ID column does not exist")
        end
        
        # Fetch the next ID unless it is already defined
        unless self.send(column).is_a?(Integer) && sequential_id_is_unique?
          begin
            self.send(:"#{column}=", next_sequential_id)
          end until sequential_id_is_unique?
        end
      end
      
      # Internal: Obtain the next sequential ID
      #
      # Returns Integer.
      def next_sequential_id
        scope    = self.class.sequenced_options[:scope]
        column   = self.class.sequenced_options[:column]
        start_at = self.class.sequenced_options[:start_at]
        
        q = self.class.order("#{column.to_s} DESC")
        q = q.where(scope => self.send(scope)) if scope.is_a?(Symbol)
        return start_at unless last_record = q.first
        
        last_id = last_record.send(column)
        if last_id.is_a?(Integer)
          last_id + 1 > start_at ? last_id + 1 : start_at
        else
          start_at
        end
      end
      
      # Internal: Checks the uniqueness of the sequential ID.
      #
      # Returns Boolean status of uniqueness.
      def sequential_id_is_unique?
        scope  = self.class.sequenced_options[:scope]
        column = self.class.sequenced_options[:column]
        q = self.class.where(column => self.send(column))
        q = q.where(scope => self.send(scope)) if scope.is_a?(Symbol)
        q = q.where("NOT id = ?", self.id) if self.persisted?
        q.count > 0 ? false : true
      end
    end
  end
end