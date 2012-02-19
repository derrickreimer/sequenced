module Sequenced
  class SequencedError < RuntimeError; end
  class InvalidScopeError < SequencedError; end
end