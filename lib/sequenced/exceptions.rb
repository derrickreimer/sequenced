module Sequenced
  class SequencedError < RuntimeError; end
  class InvalidAttributeError < SequencedError; end
end