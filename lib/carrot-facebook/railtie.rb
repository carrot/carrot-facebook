require 'carrot-facebook/middleware'
require 'carrot-facebook/view_helpers'

module Carrot
  module Facebook
    class Railtie < Rails::Railtie
      initializer "carrot.facebook.middleware" do |app|
        app.middleware.use Middleware
      end

      initializer "carrot.facebook.view_helpers" do
        ActionView::Base.send :include, ViewHelpers
      end
    end
  end
end
