require 'rails/railtie'
module InlineSvg
  class Railtie < ::Rails::Railtie
    initializer "inline_svg.action_view" do |app|
      ActiveSupport.on_load :action_view do
        require "inline_svg/action_view/helpers"
        include InlineSvg::ActionView::Helpers
      end
    end

    config.after_initialize do |app|
      InlineSvg.configure do |config|
        # In default Rails apps, this will be a fully operational
        # Sprockets::Environment instance
        # Only set this when a user-configured asset finder has not been
        # configured already.
        if config.asset_finder.nil?
          if assets = app.instance_variable_get(:@assets)
            config.asset_finder = assets
          elsif defined?(Webpacker)
            config.asset_finder = InlineSvg::WebpackAssetFinder
          end
        end
      end
    end
  end
end
