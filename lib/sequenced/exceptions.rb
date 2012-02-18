module Sequenced
  class SequencedError < RuntimeError
  end
  
  class AttributeError < SequencedError
  end
end