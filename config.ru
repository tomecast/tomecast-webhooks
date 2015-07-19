
######################### Configure Webhooks
require './webhook'
use Sinatra::Application

######################### Configure Sidekiq (Protected area)

require 'sidekiq'
require 'sidekiq/web'
Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDIS_SERVER_URL'] }
end
map '/sidekiq' do
  use Rack::Session::Cookie
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'foo' && password == 'bar'
  end

  run Sidekiq::Web
end
