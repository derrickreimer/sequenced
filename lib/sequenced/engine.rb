module Sequenced
  class Engine < Rails::Engine
    initialize "sequenced.load_app_instance_data" do |app|
      Sequenced.setup do |config|
        config.app_root = app.root
      end
    end
  end
end