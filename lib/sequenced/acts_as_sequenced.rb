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
      #           :on     - The Symbol representing the object (or instance method
      #                     that returns the object) on which the sequential ID 
      #                     should be scoped (default: nil)
      #           :column - The Symbol representing the column
      #                     (or method) that stores the sequential ID 
      #                     (default: :sequential_id)
      #
      # Examples
      #   
      #   class Answer < ActiveRecord::Base
      #     belongs_to :question
      #     acts_as_sequenced :on => :question
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
        
        # Validate uniqueness of sequential ID within the given scope
        #
        # Removed for now, since this requires knowledge of the foreign key
        # for the association. This is too limiting, since there is no
        # need to absolutely require an association be set up.
        # Users are welcome to manually add this validation to their models.
        #
        # validates self.sequenced_column, :uniqueness => { :scope => foreign_key }
        
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
        on = self.class.sequenced_on
        column = self.class.sequenced_column
        sequencer = on.nil? ? nil : load_sequencer(on)
        
        unless self.respond_to?(column)
          raise Sequenced::SequencedError.new("Sequential ID column does not exist")
        end
        
        # Fetch the next ID unless it is already defined
        unless self.send(column).is_a?(Integer)
          sequential_id = Sequenced::Sequence.advance(self.class.to_s, sequencer)
          self.send(:"#{column}=", sequential_id)
        end
      end
      
      # Internal: Fetches the sequencer object.
      #
      # key - The Symbol representation of the method that returns
      #       the sequencer object
      #
      # Returns the sequencer Object.
      # Raises Sequenced::SequencedError if the method is not defined, 
      #   does not exist, or is not persisted.
      def load_sequencer(key)
        unless self.respond_to?(key)
          raise Sequenced::SequencedError.new("Sequencer column or method ##{key.to_s} does not exist")
        end
        
        sequencer = self.send(key)
        
        unless sequencer.present?
          raise Sequenced::SequencedError.new("Sequencer column or method ##{key.to_s} is undefined")
        end
        
        unless sequencer.respond_to?(:id) && sequencer.id.present?
          raise Sequenced::SequencedError.new("Sequencer object #id is undefined")
        end
        
        return sequencer
      end
    end
  end
end