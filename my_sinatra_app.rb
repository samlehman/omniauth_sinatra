# my_sinatra_app.rb
# run with rackup
require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'omniauth'
require 'omniauth-oauth2'

class MySinatraApp < Sinatra::Base
  before do
    redirect request.url.sub('http', 'https') unless request.secure?
  end

  SETUP_PROC = lambda do |env|
    request = Rack::Request.new(env)
    env['omniauth.strategy'].options[:client_id] = ENV['SPOTX_CLIENT_ID']
    env['omniauth.strategy'].options[:client_secret] = ENV['SPOTX_CLIENT_SECRET']
  end

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :windowslive, ENV['MICROSOFT_CLIENT_ID'], ENV['MICROSOFT_CLIENT_SECRET'],
      {
        name: "bingads",
        scope: "https://ads.microsoft.com/ads.manage offline_access"
      }

    provider :windowslive, ENV['MICROSOFT_CLIENT_ID'], ENV['MICROSOFT_CLIENT_SECRET'],
      {
        name: "onedrive",
        scope: "files.read.all offline_access"
      }

    provider :snapchat, ENV['SNAPCHAT_CLIENT_ID'], ENV['SNAPCHAT_CLIENT_SECRET'],
      {
        name: "snapchat",
        scope: "snapchat-marketing-api"
      }

    provider :spot_x_publisher_platform, :setup => SETUP_PROC
  end

  get '/' do
    <<-HTML
    <a href='/auth/bingads'>Sign in with Bing</a>
    <a href='/auth/onedrive'>Sign in with OneDrive</a>
    <a href='/auth/snapchat'>Sign in with Snapchat</a>
    <a href='/auth/spot_x_publisher_platform'>Sign in with Spot X</a>
    HTML
  end

  get '/test' do
    "Hello World"
  end

  get '/auth/bingads/callback' do
    auth = request.env['omniauth.auth']

    auth.to_s
  end

  get '/auth/onedrive/callback' do
    auth = request.env['omniauth.auth']

    auth.to_s
  end

  get '/auth/snapchat/callback' do
    auth = request.env['omniauth.auth']

    auth.to_s
  end

  get '/auth/spot_x_publisher_platform/callback' do
    auth = request.env['omniauth.auth']

    auth.to_s
  end
end

module OmniAuth
  module Strategies
    class Windowslive < OmniAuth::Strategies::OAuth2
      AUTH_URL = "https://login.microsoftonline.com"

      option :name, 'windowslive'

      option :client_options, {
        site:          AUTH_URL,
        authorize_url: "#{AUTH_URL}/common/oauth2/v2.0/authorize",
        token_url:     "#{AUTH_URL}/common/oauth2/v2.0/token"
      }

      uid do
        access_token.params["user_id"]
      end

      info do
        { name: uid } # only mandatory field
      end

      extra do
        {}
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end

    class SpotXPublisherPlatform < OmniAuth::Strategies::OAuth2
      BASE_SPOTXCHANGE_URL = 'https://auth.spotx.tv/oauth2'
      option :name, 'spot_x_publisher_platform'
      option :client_options, {
            :site          =>   BASE_SPOTXCHANGE_URL,
            :authorize_url => "#{BASE_SPOTXCHANGE_URL}/auth",
            :token_url     => "#{BASE_SPOTXCHANGE_URL}/token"
          }

      # had to override the default build_access_token behavior
      # because the spotx token URL sends us a none-standard
      # access token hash that the low level parsing code doesn't know how to handle
      def build_access_token
        super
      rescue => e
        json = e.message[MATCH_ACCESS_TOKEN_JSON,1]
        hash = Yajl::Parser.parse(json, symbolize_keys: true)
        params = hash.fetch(:value).fetch(:data)
        ::OAuth2::AccessToken.from_hash(client, params)
      end

      #######
      #
      # Omniauth (in 3.0.0?) made a change to allow query_params onto the request string.
      # There is some debate as to violation of the spec or now, regardless, the change stuck.
      #
      # So omniauth-oauth2 moved to 1.4.0 and broke lots of downstream provider gems
      # as well as our implementation of SpotX
      #
      # Read more here: https://github.com/intridea/omniauth-oauth2/issues/81
      #
      # This means that this strategy needs to define its own callback_url that
      # leaves off the query_params
      #
      #####
      def callback_url
        full_host + script_name + callback_path
      end

      private

      MATCH_ACCESS_TOKEN_JSON = /\: \n(.+)/
    end

    class Snapchat < OmniAuth::Strategies::OAuth2
      option :name, "snapchat"

      option :client_options, {
        site:          'https://adsapi.snapchat.com',
        authorize_url: 'https://accounts.snapchat.com/login/oauth2/authorize',
        token_url:     'https://accounts.snapchat.com/login/oauth2/access_token'
      }

      uid { raw_info['me']['id'] }

      info do
        {
          email: raw_info['me']['email'],
          organization_id: raw_info['me']['organization_id'],
          display_name: raw_info['me']['display_name'],
          member_status: raw_info['me']['member_status']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        raw_info_url = "https://adsapi.snapchat.com/v1/me"
        @raw_info ||= access_token.get(raw_info_url).parsed
      end
    end
  end
end


