module Sequenced
  class SequencedError < RuntimeError
  end
  
  class NoMethodError < SequencedError
  end
end