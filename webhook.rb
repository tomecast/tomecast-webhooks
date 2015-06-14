#!/usr/bin/env ruby

require 'sinatra'
require 'rack-superfeedr'
require 'logger'


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

Rack::Superfeedr.host = ENV['HOST']
Rack::Superfeedr.port = settings.port


use Rack::Superfeedr do |superfeedr|

  superfeedr.on_notification do |feed_id, body, url, request|
    logger.info "------"
    logger.info feed_id # You need to have supplied one upon subscription
    logger.info "------"
    logger.info body # The body of the notification, a JSON or ATOM string, based on the subscription. Use the Rack::Request object for details
    logger.info "------"
    logger.info url # The feed url
    logger.info "------"
  end

end

# Maybe serve the data you saved from Superfeedr's handler.
get '/hi' do
  "Hello World!"
end
post '/superfeedr' do
  logger.info params
  "success"
end

#thin start -p 8080