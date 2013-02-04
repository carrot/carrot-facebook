require "rails/all"
require "json"
require "base64"
require "openssl"
require "carrot-facebook"

module Helpers
  def encode_signed_request(options)
    encoded_data      = Base64.urlsafe_encode64( options.to_json ).tr('=', '')
    digestor          = OpenSSL::Digest::Digest.new('sha256')
    signature         = OpenSSL::HMAC.digest( digestor, '', encoded_data )
    encoded_signature = Base64.strict_encode64( signature ).tr("+/", "-_")
    encoded_signature = encoded_signature.tr('=', '')

    "#{encoded_signature}.#{encoded_data}"
  end
end

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = :documentation
  config.include Helpers
end