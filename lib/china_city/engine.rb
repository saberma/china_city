module ChinaCity
  class Engine < ::Rails::Engine
    isolate_namespace ChinaCity

    config.generators do |g|
      g.test_framework      :rspec,        fixture: false
      # g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
      g.view_specs false
    end
  end
end
