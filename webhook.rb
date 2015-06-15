#!/usr/bin/env ruby

require 'sinatra'
require 'logger'
require 'json'
require 'time'

::Logger.class_eval { alias :write :'<<' }
access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)),'logs','access.log')
access_logger = ::Logger.new(access_log)
error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)),'logs','error.log'),"a+")
error_logger.sync = true


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

  podcast_title = params['podcast_name']
  payload[:items].each do |item|
    episode_title = item[:title]
    episode_url = item[:standardLinks][:enclosure][0][:href]
    pubdate = Time.at(item[:published]).utc.to_datetime
    description = item[:summary]

    #push to queue
    logger.info podcast_title
    logger.info episode_title
    logger.info episode_url
    logger.info pubdate
    logger.info description
    #podcast_title, episode_title, episode_url, pubdate, description=''
  end

  "success"
end
