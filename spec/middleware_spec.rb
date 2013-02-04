require 'spec_helper'

describe Carrot::Facebook::Middleware do
  before(:all) do
    @headers              = { 'Content-Type' => 'text/html' }
    @app                  = lambda { |env| [200, @headers, []] }
    @valid_facebook_data  = {
                              algorithm: 'HMAC-SHA256',
                              issued_at: 1331665894,
                              page: {
                                id: '137739982942274',
                                liked: false,
                                admin: true
                              },
                              user: {
                                country: 'us',
                                locale: 'en_US',
                                age: {
                                  min: 21
                                }
                              }
                            }
  end

  context 'when a normal GET request is received' do
    before(:all) do
      @request  = Rack::MockRequest.env_for('/', lint: true, fatal: true,  method: 'GET')
      @response = Carrot::Facebook::Middleware.new(@app).call(@request)
    end

    it 'should be a GET request' do
      expect(@request['REQUEST_METHOD']).to eq 'GET'
    end

    it 'should keep the headers intact' do
      expect(@response[1]).to eq @headers
    end

    it 'should be successful' do
      expect(@response[0]).to eq 200
    end

    it 'should not be considered a canvas application' do
      expect(@request[:is_iframe_app]).to be_false
    end
  end

  context "when a normal POST request is received" do
    before(:all) do
      @request  = Rack::MockRequest.env_for('/', lint: true, fatal: true, method: 'POST')
      @response = Carrot::Facebook::Middleware.new(@app).call(@request)
    end

    it 'should be a POST request' do
      expect(@request['REQUEST_METHOD']).to eq 'POST'
    end

    it 'should keep the headers intact' do
      expect(@response[1]).to eq @headers
    end

    it 'should be successful' do
      expect(@response[0]).to eq 200
    end

    it 'should not be considered a canvas application' do
      expect(@request[:is_iframe_app]).to be_false
    end
  end

  context "when is a canvas app and sends an invalid signed_request" do
    before(:all) do
      @signed_request = 'signed_request=kUbujwbyaKAS3EMLSolZki1mJtuzY5-XUrchNN.eyJhbGdvcml0aG0iORtaW4iOnRydWV9LCJ1c2VyIjp7ImNvdW50cnkiOiJ1cyIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9f'
      @request        = Rack::MockRequest.env_for('/', lint: true, fatal: true,  method: 'POST', input: @signed_request)
      @response       = Carrot::Facebook::Middleware.new(@app).call(@request)
    end

    it 'should be converted to a GET request' do
      expect(@request['REQUEST_METHOD']).to eq 'GET'
    end

    it 'should keep the headers intact' do
      expect(@response[1]).to eq @headers
    end

    it 'should be successful' do
      expect(@response[0]).to eq 200
    end

    it 'should not be considered a canvas application' do
      expect(@request[:is_iframe_app]).to be_true
    end

    it 'should correctly set :facebook_data' do
      expect(@request[:facebook_data]).to be_nil
    end
  end

  #pending 'test invalid app data'

  context "when is a canvas app and sends a valid signed_request" do
    before(:all) do
      @signed_request = 'signed_request=kUbujwbyaKAS3EMLSolZki1mJtuzY5-XUrchNN3MVyI.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTMzMTY2NTg5NCwicGFnZSI6eyJpZCI6IjEzNzczOTk4Mjk0MjI3NCIsImxpa2VkIjpmYWxzZSwiYWRtaW4iOnRydWV9LCJ1c2VyIjp7ImNvdW50cnkiOiJ1cyIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fX0'
      @request        = Rack::MockRequest.env_for('/', lint: true, fatal: true,  method: 'POST', input: @signed_request)
      @response       = Carrot::Facebook::Middleware.new(@app).call(@request)
    end

    it 'should be converted to a GET request' do
      expect(@request['REQUEST_METHOD']).to eq 'GET'
    end

    it 'should keep the headers intact' do
      expect(@response[1]).to eq @headers
    end

    it 'should be successful' do
      expect(@response[0]).to eq 200
    end

    it 'should not be considered a canvas application' do
      expect(@request[:is_iframe_app]).to be_true
    end

    it 'should correctly set :facebook_data' do
      expect(@request[:facebook_data]).to eq @valid_facebook_data.merge({ issued_at: 1331665894, app_data: nil })
    end
  end

  context "when is a canvas app and sends a valid signed_request with app_data" do
    before(:all) do
      @data           = @valid_facebook_data.merge({ issued_at: 1331669185, app_data: { path: '/page/terms' } })
      @signed_request = "signed_request=#{encode_signed_request(@data)}"
      @request        = Rack::MockRequest.env_for('/', lint: true, fatal: true,  method: 'POST', input: @signed_request)
      @response       = Carrot::Facebook::Middleware.new(@app).call(@request)
    end

    it 'should be converted to a GET request' do
      expect(@request['REQUEST_METHOD']).to eq 'GET'
    end

    it 'should keep the headers intact' do
      expect(@response[1]).to eq @headers
    end

    it 'should be successful' do
      expect(@response[0]).to eq 200
    end

    it 'should not be considered a canvas application' do
      expect(@request[:is_iframe_app]).to be_true
    end

    it 'should correctly set :facebook_data' do
      expect(@request[:facebook_data]).to eq @data
    end
  end

  context "when sending parameters in the request" do
    before(:all) do
      @data           = @valid_facebook_data.merge({ issued_at: 1331669185, app_data: { path: '/page/terms', params: { foo: 'bar' } } })
      @signed_request = "signed_request=#{encode_signed_request(@data)}"
      @request        = Rack::MockRequest.env_for('/', lint: true, fatal: true,  method: 'POST', input: @signed_request)
      @response       = Carrot::Facebook::Middleware.new(@app).call(@request)
    end

    it 'should properly set parameters passed to app_data within the signed request' do
      expect(@request[:facebook_data]).to eq @data
    end
    
    it 'should recognize the params object within app_data' do
      @request[:facebook_data][:app_data][:params].should == {foo: 'bar'}
    end
  end
end
