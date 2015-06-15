require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['REDIS_SERVER_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDIS_SERVER_URL'] }
end

class SpoutWorker
  include Sidekiq::Worker
end