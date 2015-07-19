
######################### Configure Webhooks
require './webhook'
use Sinatra::Application

######################### Configure Sidekiq (Protected area)

require 'sidekiq'
require 'sidekiq/web'
Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDIS_SERVER_URL'] }
end


#register callback /auth/github/callback
require 'sinatra_auth_github'

configure do
  set :github_options, {
                         :scopes    => "user",
                         :client_id => ENV['GITHUB_KEY'],
                         :secret    => ENV['GITHUB_SECRET']
                     }
  register Sinatra::Auth::Github
end
module Sidekiq
  class Web
    include Sinatra::Auth::Github::Helpers
    before do
        authenticate!
        github_organization_authenticate!(ENV['GITHUB_ORG'])
    end

    get '/logout' do
      logout!
    end
  end
end

map '/sidekiq' do
  use Rack::Session::Cookie, :secret => ENV['RACK_SESSION_COOKIE']
  run Sidekiq::Web
end


