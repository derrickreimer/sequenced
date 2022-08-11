require 'sequenced/generator'
require 'sequenced/acts_as_sequenced'

ActiveSupport.on_load(:active_record) do
  include Sequenced::ActsAsSequenced
end
