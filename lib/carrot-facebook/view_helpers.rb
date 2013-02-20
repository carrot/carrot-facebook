include ActionView::Helpers::TagHelper

module Carrot
  module Facebook
    module ViewHelpers
      #extend ActionView::Helpers::AssetTagHelper
      # Public: Generates a user's Facebook avatar.
      #
      # fb_id - The String of the Facebook user's ID.
      # type  - The Symbol of the desired image size.
      #         [:square (50x50), :small (50xN), :normal (100xN), :large (200xN)]
      #
      # Examples
      #
      # fb_avatar('1234567890', :normal)
      #   # => "//graph.facebook.com/1234567890/picture?type=normal"
      #
      # Returns the generated Facebook URL.
      def fb_avatar(fb_id = nil, type = :square)
        if fb_id
          "//graph.facebook.com/#{fb_id}/picture?type=#{type}"
        end
      end

      # Public: Display a user's Facebook avatar.
      #
      # fb_id - The String of the Facebook user's ID.
      # type  - The Symbol of the desired image size.
      #         [:square (50x50), :small (50xN), :normal (100xN), :large (200xN)]
      #
      # Examples
      #
      # fb_avatar_tag('1234567890', :normal)
      #   # => '<img alt="Facebook Avatar for User 1234567890" src="//graph.facebook.com/1234567890/picture?type=normal" />'
      #
      # Returns the image tag for the Facebook user's avatar.
      def fb_avatar_tag(fb_id = nil, type = :square)
        if fb_id
          tag(:img, src: fb_avatar(fb_id, type), alt: "Facebook Avatar for User #{fb_id}")
        end
      end

      # Public: Generate Facebook's Javascript
      #
      # options - A Hash potentially consisting of two keys:
      #           app_id - A String denoting the Facebook App ID (Also accepts ENV["FACEBOOK_APP_ID"])
      #           xfbml  - A Boolean denoting whether XFBML should be rendered upon pageload
      #
      # Examples
      #
      #   fb_js
      #   fb_js(app_id: '1234567890')
      #   fb_js(xfbml: false)
      #   fb_js(app_id: '1234567890', xfbml: false)
      #
      # Returns and initializes the Facebook Javascript SDK
      def fbjs(*options)
        opts = { :app_id => ENV['FACEBOOK_APP_ID'], :xfbml => true }
        opts.merge!(options.first) unless options.empty?

        %Q{
          <div id="fb-root"></div>
          <script src="//connect.facebook.net/en_US/all.js"></script>
          <script>
            FB.init({ appId: '#{opts[:app_id]}', xfbml: '#{opts[:xfbml]}' });
          </script>
        }.html_safe
      end

      def auto_grow(timer = true)
        content_tag(:script, "FB.Canvas.setAutoGrow(#{timer});")
      end
    end
  end
end
