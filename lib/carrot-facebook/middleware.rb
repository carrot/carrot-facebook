require 'yajl'

module Carrot
  module Facebook
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        request             = Rack::Request.new(env)
        env[:is_iframe_app] = false

        if request.POST and request.POST['signed_request']
          env["REQUEST_METHOD"] = 'GET'
          env[:is_iframe_app]   = true
          env[:facebook_data]   = parsed_signed_request(request.POST['signed_request'])

          if env[:facebook_data]
            if env[:facebook_data][:app_data].present?
              begin
                path_override                  = Yajl::Parser.parse(env[:facebook_data][:app_data], symbolize_keys: true) 
                env['PATH_INFO']               = path_override[:path] if path_override[:path]
                env['QUERY_STRING']            = path_override[:params].map { |params| params.join('=') }.join('&') if path_override[:params]
                env[:facebook_data][:app_data] = path_override
              rescue => e
                env[:facebook_data][:app_data] = env[:facebook_data][:app_data]
              end
            else
              env[:facebook_data][:app_data] = nil
            end
          end
        end

        @app.call(env)
      end

      private

      def parsed_signed_request(signed_request)
        begin
          p = signed_request.split('.')[1]
          Yajl::Parser.parse(Base64.decode64(p + "=" * (4 - p.size % 4)), symbolize_keys: true)
        rescue
          nil
        end
      end
    end
  end
end
