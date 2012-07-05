require 'sequenced/acts_as_sequenced'

ActiveRecord::Base.send(:include, Sequenced::ActsAsSequenced)