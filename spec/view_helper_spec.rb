require 'spec_helper'
#include Carrot::Facebook::ViewHelpers
#include ActionView::Helpers::TagHelper

#require 'action_view'
#require 'active_support'

include Carrot::Facebook::ViewHelpers
#include ActionView::Helpers
#include ActionView::Helpers::TagHelper

describe Carrot::Facebook::ViewHelpers, :type => :helper do
  let(:helper) { Carrot::Facebook::ViewHelpers }

  context "#fb_avatar" do
    it "should output a default URL with a 'square' format" do
      output = helper.fb_avatar('tmilewski')
      expect(output).to match /\?type=square\z/
    end

    it "should output a URL for a 'large' format" do
      output = helper.fb_avatar('tmilewski', :large)
      expect(output).to match /\?type=large\z/
    end

    it "should accept a Facebook ID as an Integer and output a formatted URL" do
      output = helper.fb_avatar(8201087)
      expect(output).to match /.com\/8201087\//
    end

    it "should accept a Facebook ID as a String and output a formatted URL" do
      output = helper.fb_avatar('tmilewski')
      expect(output).to match /.com\/tmilewski\//
    end

    it "should not raise an error if a Facebook ID isn't provided" do
      expect(helper.fb_avatar).to_not raise_error(ArgumentError)
    end

    it "should return nil if a Facebook ID isn't provided" do
      expect(helper.fb_avatar).to be_nil
    end
  end

  context "#fb_avatar_tag" do
    it "should output the URL within an image tag" do
      output = helper.fb_avatar_tag('tmilewski')
      expect(output.to_str).to eq '<img alt="Facebook Avatar for User tmilewski" src="//graph.facebook.com/tmilewski/picture?type=square" />'
    end

    it "should not raise an error if a Facebook ID isn't provided" do
      expect(helper.fb_avatar_tag).to_not raise_error(ArgumentError)
    end

    it "should return nil if a Facebook ID isn't provided" do
      expect(helper.fb_avatar_tag).to be_nil
    end
  end

  context "#fb_js" do
    it "should output the correct JS using ENV variables" do
      ENV.stub(:[]).with("FACEBOOK_APP_ID").and_return("asdf")
      output = helper.fbjs
      expect(output).to match /appId: 'asdf'/
      expect(output).to match /xfbml: 'true'/
    end

    it "should allow an override of the ENV variable" do
      ENV.stub(:[]).with("FACEBOOK_APP_ID").and_return("asdf")
      output = helper.fbjs(:app_id => "qwerty")
      expect(output).to match /appId: 'qwerty'/
    end

    it "should allow a user to disable XFBML rendering" do
      output = helper.fbjs(:app_id => "qwerty", :xfbml => false)
      expect(output).to match /appId: 'qwerty'/
      expect(output).to match /xfbml: 'false'/
    end
  end

  context "#facepile" do
    it "should raise error if url is not provided" do
      expect { helper.facepile }.to raise_error
    end

    it "should not raise error if ENV variable is provided" do
      ENV.stub(:[]).with("FACEBOOK_APP_URL").and_return("asdf")
      expect { helper.facepile }.to_not raise_error
    end

    it "should not raise error if :href parameter is provided" do
      expect { helper.facepile(href: "http://carrotcreative.com/") }.to_not raise_error
    end

    it "should correctly set output HTML" do
      ENV.stub(:[]).with("FACEBOOK_APP_URL").and_return("http://carrotcreative.com/")
      expect(helper.facepile).to match /data-href="http:\/\/carrotcreative.com\//
      expect(helper.facepile(max_rows: 2)).to match /data-max-rows="2"/
      expect(helper.facepile(width: 400)).to match /data-width="400"/
      expect(helper.facepile(show_count: false)).to match /data-show-count="false"/
    end
  end
end
