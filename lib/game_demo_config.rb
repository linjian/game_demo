module GameDemoConfig
  class << self
    def get(key)
      config[key.to_sym]
    end

    def config
      @game_demo_config = nil if ENV["RAILS_ENV"] == "development"
      config_file = File.join(Rails.root, "config/game_demo_config.yml")
      @game_demo_config ||= YAML.load(File.read(config_file)).symbolize_keys
    end
  end

  module Helper

    def config_class_methods(*args)
      class_name = self.name

      singleton_class.class_eval do
        args.each do |method|
          method = method.to_sym
          if method_defined?(method)
            $stderr.puts "WARNING: Possible conflict: #{class_name}.#{method} already exists"
          else
            define_method method do
              GameDemoConfig.get(method)
            end
          end
        end # of each
      end
    end

  end
end

module ActiveRecord
  class Base
    extend GameDemoConfig::Helper
  end
end
