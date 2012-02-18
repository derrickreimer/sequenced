require 'active_support/dependencies'
require 'active_support/core_ext/class/attribute_accessors'
require 'sequenced/exceptions'
require 'sequenced/acts_as_sequenced'

module Sequenced
  mattr_accessor :app_root
  
  def self.setup
    yield self
  end
end

ActiveRecord::Base.send(:include, Sequenced::ActsAsSequenced)
require "sequenced/engine"