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
  request.body.rewind #- not sure if this is breaking the json parse.
  payload = JSON.parse(request.body.read,:symbolize_names => true)
  logger.info "PAYLOAD: #{JSON.pretty_generate(payload)}"

  if !payload.has_key?(:items)
    logger.warn 'ignored: nothing to process (no "items" key)'
    return 'ignored: nothing to process'
  end
  podcast_title = params['podcast_name'].force_encoding("utf-8")
  payload[:items].each do |item|
    episode_title = item[:title].force_encoding("utf-8")
    episode_url = item[:standardLinks][:enclosure][0][:href].force_encoding("utf-8")
    pubdate = Time.at(item[:published]).utc.to_datetime.rfc3339.force_encoding("utf-8")
    description = item[:summary].force_encoding("utf-8")

    #push to queue
    logger.info 'QUEUING'
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
