module Sequenced
  class Sequence < ActiveRecord::Base
    belongs_to :sequencer, :polymorphic => true
    
    def self.advance(sequencer, sequenced_type)
      
    end
  end
end