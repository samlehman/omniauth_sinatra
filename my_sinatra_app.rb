# my_sinatra_app.rb
# run with rackup
require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'omniauth'
require 'omniauth-oauth2'

class MySinatraApp < Sinatra::Base
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
  end

  get '/' do
    <<-HTML
    <a href='/auth/bingads'>Sign in with Bing</a>
    <a href='/auth/onedrive'>Sign in with OneDrive</a>
    <a href='/auth/snapchat'>Sign in with Snapchat</a>
    HTML
  end

  get '/test' do
    "Hello World"
  end

  get '/auth/bingads/callback' do
    auth = request.env['omniauth.auth']

    puts auth
  end

  get '/auth/onedrive/callback' do
    auth = request.env['omniauth.auth']

    puts auth
  end

  get '/auth/snapchat/callback' do
    auth = request.env['omniauth.auth']

    puts auth
  end
end

module OmniAuth
  module Strategies
    class Snapchat < OmniAuth::Strategies::OAuth2

      option :name, "snapchat"

      option :client_options, {
        :site          => 'https://adsapi.snapchat.com',
        :authorize_url => 'https://accounts.snapchat.com/login/oauth2/authorize',
        :token_url     => 'https://accounts.snapchat.com/login/oauth2/access_token'
      }

      uid{ raw_info['me']['id'] }

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
  end
end


