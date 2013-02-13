module Carrot
  module Facebook
    module Controller
      extend ActiveSupport::Concerns

      def top_redirect_to(*args)
        @redirect_url = url_for(*args)
        render :layout => false, :inline => <<-HTML
          <html><head>
            <script type="text/javascript">
              window.top.location.href = <%= @redirect_url.to_json -%>;
            </script>
            <noscript>
              <meta http-equiv="refresh" content="0;url=<%=h @redirect_url %>" />
              <meta http-equiv="window-target" content="_top" />
            </noscript>
          </head></html>
        HTML
      end
    end
  end
en
