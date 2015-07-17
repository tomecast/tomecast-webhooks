#!/usr/bin/env ruby

require 'sinatra'
require 'logger'
require 'json'
require 'time'
require_relative 'jobs'

access_logger = ::Logger.new(STDOUT)
access_logger.level = ::Logger::WARN



configure do
  use ::Rack::CommonLogger, access_logger
  enable :dump_errors
  enable :show_exceptions

end


# Maybe serve the data you saved from Superfeedr's handler.
get '/hi' do
  "Hello World!"
end

post '/superfeedr/:podcast_name' do
  request.body.rewind
  payload = JSON.parse(request.body.read,:symbolize_names => true)
  logger.info "PAYLOAD: #{payload}"

  if !payload.has_key?(:items)
    return 'ignored: nothing to process'
  end
  podcast_title = params['podcast_name']
  payload[:items].each do |item|
    episode_title = item[:title]
    episode_url = item[:standardLinks][:enclosure][0][:href]
    pubdate = Time.at(item[:published]).utc.to_datetime.rfc3339
    description = item[:summary]

    #push to queue
    logger.info podcast_title
    logger.info episode_title
    logger.info episode_url
    logger.info pubdate
    logger.info description
    #podcast_title, episode_title, episode_url, pubdate, description=''

    Sidekiq::Client.enqueue(SpoutWorker, podcast_title,episode_title,episode_url,pubdate,description)
  end

  return 'success'
end
