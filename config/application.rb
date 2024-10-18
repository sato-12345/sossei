require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # 既存の設定部分の下に、以下を追加
    config.generators do |g|
      g.helper false           # ヘルパーを自動生成しない
      g.assets false           # CSS, JavaScriptファイルを自動生成しない
      g.skip_routes true       # ルーティングを自動生成しない
      g.test_framework nil     # テストファイルを自動生成しない

      #〜〜中略〜〜
      class ActiveRecord::Base
        singleton_class.attr_accessor :timestamped_migrations
        self.timestamped_migrations = true
      end
    end
  end
end
