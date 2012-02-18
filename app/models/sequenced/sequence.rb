module Sequenced
  class Sequence < ActiveRecord::Base
    # Internal: Advance the sequence safely for a given
    # sequencer
    #
    # sequenced_type - A String or Class representing the class
    #                  of the sequenced object
    # sequencer      - An Object by which the sequence is scoped
    #                  (default: nil)
    #
    # Examples:
    #
    #   question = Question.first
    #   Sequence.advance("Answer", question)
    #   # => 3
    #   Sequence.advance(Answer, question)
    #   # => 4
    #
    # Returns the Integer of the next sequential ID
    # Raises ActiveRecord error if the save failed or
    #   Sequenced::SequencedError if the sequencer does not
    #   respond to #id
    def self.advance(sequenced_type, sequencer = nil)
      sequenced_type = sequenced_type.to_s
          
      Sequence.transaction do
        s = self.where(:sequenced_type => sequenced_type)
        
        # Explictly query for the sequencer object (or lack thereof)
        if sequencer.nil?
          s = s.where("sequencer_id IS NULL AND sequencer_type IS NULL")
        elsif sequencer.respond_to?(:id) 
          s = s.where(:sequencer_id => sequencer.id, :sequencer_type => sequencer.class.to_s)
        else
          raise Sequenced::SequencedError("Sequencer does not respond to #id")
        end
        
        # Load the sequence with a row-level lock
        sequence = s.lock(true).first
        
        # Increment if the sequence exists, or create a new
        # sequence record if it does not exist
        if sequence.present?
          next_id = sequence.last_id + 1
          sequence.last_id = next_id
          sequence.save!
        else
          sequence = Sequence.build(:sequenced_type => sequenced_type, :sequencer => sequencer, :last_id => 1)
          sequence.save!
          next_id = 1
        end
        
        return next_id
      end
    end
  end
end