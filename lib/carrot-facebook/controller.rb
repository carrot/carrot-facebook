include ActionView::Helpers::TagHelper

module Carrot
  module Facebook
    module Controller
      extend ActiveSupport::Concern

      def top_redirect_to(*args)
        if request.env[:is_facebook_app]
          @redirect_url = [ENV["FACEBOOK_APP_URL"], url_for(*args)].join

          render :layout => false, :inline => %Q{
            <html><head>
              <script type="text/javascript">
                window.top.location.href = #{@redirect_url.to_json};
              </script>
              <noscript>
                <meta http-equiv="refresh" content="0;url=#{@redirect_url}" />
                <meta http-equiv="window-target" content="_top" />
              </noscript>
            </head></html>
          }.html_safe
        else
          redirect_to(*args)
        end
      end
    end
  end
end
