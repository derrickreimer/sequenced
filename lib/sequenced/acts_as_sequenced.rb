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
      #           :scope           - The Symbol representing the object on 
      #                              which the sequential ID should be scoped 
      #                              (default: nil)
      #           :column          - The Symbol representing the column
      #                              (or method) that stores the sequential ID 
      #                              (default: :sequential_id)
      #           :foreign_key     - The Symbol representing the foreign key
      #                              column of the scope model (default: {scope}_id)
      #           :skip_validation - The Boolean value indicating whether
      #                              uniqueness validations should be skipped
      #                              (default: false)
      #
      # Examples
      #   
      #   class Answer < ActiveRecord::Base
      #     belongs_to :question
      #     acts_as_sequenced :scope => :question
      #   end
      #
      # Returns nothing.
      def acts_as_sequenced(options = {})
        # Remove extraneous options
        options.slice!(:scope, :column, :foreign_key, :skip_validation)
        
        # Set defaults
        options[:scope] ||= nil
        options[:column] ||= :sequential_id
        options[:foreign_key] ||= :"#{self.sequence_scope.to_s}_id"
        options[:skip_validation] ||= false
        
        # Create class accessor for sequenced options
        cattr_accessor :sequenced_options
        self.sequenced_options = options
        
        # Define ActiveRecord callback
        before_save :set_sequential_id
        
        # Validate uniqueness of sequential ID within the given scope
        unless options[:skip_validation]
          validates options[:column], :uniqueness => { :scope => options[:foreign_key] }
        end
        
        # Include instance & singleton methods
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
        column    = self.class.sequenced_options[:column]
        sequencer = load_sequencer
        
        unless self.respond_to?(column)
          raise Sequenced::SequencedError.new("Sequential ID column does not exist")
        end
        
        # Fetch the next ID unless it is already defined
        unless self.send(column).is_a?(Integer) && sequential_id_is_unique?
          begin
            sequential_id = Sequenced::Sequence.advance(self.class.to_s, sequencer)
            self.send(:"#{column}=", sequential_id)
          end until sequential_id_is_unique?
        end
      end
      
      # Internal: Fetches the sequencer object.
      #
      # Returns the sequencer Object or nil.
      # Raises Sequenced::SequencedError if the method is not defined, 
      #   does not exist, or is not persisted.
      def load_sequencer
        return unless scope = self.class.sequenced_options[:scope]
        
        unless self.respond_to?(scope)
          raise Sequenced::SequencedError.new("Sequencer column or method ##{key.to_s} is undefined")
        end
        
        sequencer = self.send(scope)
        
        unless sequencer.present?
          raise Sequenced::SequencedError.new("Sequencer object ##{key.to_s} is blank")
        end
        
        unless sequencer.respond_to?(:id) && sequencer.id.present?
          raise Sequenced::SequencedError.new("Sequencer object #id is blank")
        end
        
        return sequencer
      end
      
      # Internal: Checks the uniqueness of the sequential ID.
      #
      # Returns Boolean status of uniqueness.
      def sequential_id_is_unique?
        sid_column = self.class.sequenced_options[:column]
        sid_value  = self.send(id_column)
        fk_column = self.class.sequenced_options[:foreign_key]
        fk_value  = self.send(fk_column)
        self.class.where(sid_column => sid_value, fk_column => fk_value).count > 0 ? false : true
      end
    end
  end
end